// lib/services/supabase_service.dart
// Thin wrapper around the Supabase client.
// All database and auth calls are routed through this service so the
// rest of the app never imports supabase_flutter directly.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_stats_model.dart';

class SupabaseService {
  // ── Supabase client singleton ────────────────────────────────────────────
  // Supabase.instance.client is safe to call after Supabase.initialize()
  // in main.dart.
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Creates a new user in Supabase Auth.
  /// [username] is stored in user_metadata so it survives without a
  /// separate profiles table.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  /// Verifies an email OTP (signup confirmation or password-reset flow).
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  /// Re-sends an OTP to the user's email address.
  static Future<void> resendOtp({
    required String email,
    required OtpType type,
  }) async {
    await _client.auth.resend(email: email, type: type);
  }

  /// Signs in with email + password and returns a session.
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth
        .signInWithPassword(email: email, password: password);
  }

  /// Ends the current Supabase session on this device.
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Shortcut accessors used throughout the app.
  static User?    get currentUser    => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;

  /// Sends a password-reset email (link / OTP depending on project config).
  static Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Updates the authenticated user's password to [newPassword].
  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Permanently deletes the current user account.
  ///
  /// Execution order:
  ///   1. Delete all rows in `game_stats` that belong to this user so a new
  ///      registration with the same email starts with zero history.
  ///   2. Delete all rows in `level_progress` (highest_unlocked_level) for
  ///      the same reason.
  ///   3. Call the `delete_user` RPC which removes the auth.users row via
  ///      a SECURITY DEFINER function on the Supabase side.
  ///   4. Always sign out in the `finally` block so the in-memory session is
  ///      cleared even if any step above throws.
  static Future<void> deleteAccount() async {
    final user = _client.auth.currentUser;
    try {
      if (user != null) {
        // Wipe game stats so re-registration starts from zero.
        await _client
            .from('game_stats')
            .delete()
            .eq('user_id', user.id);

        // Wipe level-progress rows so re-registration starts at Level 1.
        await _client
            .from('level_progress')
            .delete()
            .eq('user_id', user.id);
      }
      // Remove the auth record itself via a server-side RPC.
      await _client.rpc('delete_user');
    } finally {
      // Always clear the local Supabase session regardless of any errors
      // above — prevents auto-login on next app launch after deletion.
      await _client.auth.signOut();
    }
  }

  // ── Game Stats ───────────────────────────────────────────────────────────

  /// Upserts the player's aggregate game stats to Supabase.
  /// Uses `user_id` as the conflict key so there is always exactly one row
  /// per player.
  static Future<void> saveGameStats(GameStatsModel stats) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('game_stats').upsert(
      {
        'user_id':       user.id,
        'total_wins':    stats.totalWins,
        'total_losses':  stats.totalLosses,
        'total_matches': stats.totalMatches,
        'total_days':    stats.totalDays,
        'updated_at':    DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  /// Fetches the player's aggregate stats from Supabase.
  /// Returns null if no row exists yet (new account).
  static Future<GameStatsModel?> fetchGameStats() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final response = await _client
        .from('game_stats')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    if (response == null) return null;
    return GameStatsModel(
      totalWins:    (response['total_wins']    as int?) ?? 0,
      totalLosses:  (response['total_losses']  as int?) ?? 0,
      totalMatches: (response['total_matches'] as int?) ?? 0,
      totalDays:    (response['total_days']    as int?) ?? 1,
    );
  }

  // ── Level Progress ───────────────────────────────────────────────────────

  /// Saves [highestUnlockedLevel] to Supabase so progress persists across
  /// devices and after re-login.  Uses `user_id` as the upsert conflict key.
  static Future<void> saveLevelProgress(int highestUnlockedLevel) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('level_progress').upsert(
      {
        'user_id':               user.id,
        'highest_unlocked_level': highestUnlockedLevel,
        'updated_at':            DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

  /// Fetches the player's highest unlocked level from Supabase.
  /// Returns 1 (only Level 1 available) if no row exists yet.
  static Future<int> fetchLevelProgress() async {
    final user = _client.auth.currentUser;
    if (user == null) return 1;
    final response = await _client
        .from('level_progress')
        .select('highest_unlocked_level')
        .eq('user_id', user.id)
        .maybeSingle();
    if (response == null) return 1;
    return (response['highest_unlocked_level'] as int?) ?? 1;
  }
}
