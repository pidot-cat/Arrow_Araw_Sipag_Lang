import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/game_stats_model.dart';

/// All Supabase interactions are centralised here.
/// Tables required:
///   game_stats (user_id uuid PK/FK, total_wins int, total_losses int,
///               total_matches int, total_days int, updated_at timestamptz)
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Auth ─────────────────────────────────────────────────────────────────

  /// Sends a one-time password (OTP) to the given email.
  /// Supabase will send a 6-digit code — user enters it on signup.
  static Future<void> sendOtp(String email) async {
    await _client.auth.signInWithOtp(
      email: email,
      shouldCreateUser: true, // creates the user if they don't exist yet
      emailRedirectTo: null, // sends plain 6-digit code only, no magic link
    );
  }

  /// Signs up the user. Call AFTER OTP is verified.
  /// We use signUp here so that metadata (username) is stored.
  static Future<AuthResponse> signUp(
      String email, String password, String username) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  /// Verifies the OTP that Supabase sent to the email.
  /// Returns true if valid, false if wrong/expired.
  static Future<bool> verifyOtp(String email, String token) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
      return response.user != null;
    } catch (e) {
      return false;
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  /// Sends a password reset email. User receives a link/OTP to reset.
  static Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Updates the password of the currently authenticated user.
  /// Call this AFTER OTP has been verified (user is signed in via OTP).
  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
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
