// lib/services/supabase_service.dart
// FIX Bug 3: deleteAccount() now calls signOut() after deleting the user
// to clear the in-memory Supabase session and prevent auto-login after delete.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_stats_model.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ─────────────────────────────────────────────────────────────────

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

  static Future<void> resendOtp({
    required String email,
    required OtpType type,
  }) async {
    await _client.auth.resend(email: email, type: type);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth
        .signInWithPassword(email: email, password: password);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;
  static Session? get currentSession => _client.auth.currentSession;

  static Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// FIX Bug 3: Signs out AFTER deleting the account so the Supabase session
  /// is cleared from memory. Without signOut(), currentUser remains non-null
  /// even after the backend user is deleted, causing auto-login on next launch.
  static Future<void> deleteAccount() async {
    try {
      await _client.rpc('delete_user');
    } finally {
      // Always sign out even if rpc fails, to clear local session
      await _client.auth.signOut();
    }
  }

  // ── Game Stats ───────────────────────────────────────────────────────────

  static Future<void> saveGameStats(GameStatsModel stats) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('game_stats').upsert(
      {
        'user_id': user.id,
        'total_wins': stats.totalWins,
        'total_losses': stats.totalLosses,
        'total_matches': stats.totalMatches,
        'total_days': stats.totalDays,
        'updated_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id',
    );
  }

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
      totalWins: (response['total_wins'] as int?) ?? 0,
      totalLosses: (response['total_losses'] as int?) ?? 0,
      totalMatches: (response['total_matches'] as int?) ?? 0,
      totalDays: (response['total_days'] as int?) ?? 1,
    );
  }
}
