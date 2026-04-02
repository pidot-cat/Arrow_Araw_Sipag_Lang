import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  String _username = '';
  bool _isLoggedIn = false;

  String get username => _username;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadAuthState();
  }

  // Load authentication state from storage and Supabase
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString(AppConstants.keyUsername) ?? '';

    // Check Supabase session
    final user = SupabaseService.currentUser;
    _isLoggedIn = user != null;

    if (_isLoggedIn && user?.userMetadata != null) {
      _username = user!.userMetadata!['username'] ?? _username;
    }

    notifyListeners();
  }

  // ── OTP for Signup ────────────────────────────────────────────────────────

  /// Sends a real 6-digit OTP from Supabase to the user's email.
  Future<void> sendOtp(String email) async {
    await SupabaseService.sendOtp(email);
  }

  /// Verifies the OTP entered by the user against Supabase.
  Future<bool> verifyOtp(String email, String token) async {
    return await SupabaseService.verifyOtp(email, token);
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    try {
      final response = await SupabaseService.signIn(email, password);
      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        _username =
            response.user!.userMetadata?['username'] ?? email.split('@')[0];
        await prefs.setString(AppConstants.keyUsername, _username);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);

        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  Future<bool> signUp(
    String email,
    String password,
    String confirmPassword,
    String username,
  ) async {
    if (password != confirmPassword || password.length < 8) return false;

    try {
      final response = await SupabaseService.signUp(email, password, username);
      if (response.user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUsername, username);
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);

        _username = username;
        _isLoggedIn = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Signup error: $e');
    }
    return false;
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  /// Sends a password reset email via Supabase.
  /// Returns true if the request was sent successfully.
  Future<bool> sendPasswordReset(String email) async {
    try {
      await SupabaseService.sendPasswordReset(email);
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    try {
      await SupabaseService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUsername);
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);

      _username = '';
      _isLoggedIn = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Logout error: $e');
    }
  }
}
