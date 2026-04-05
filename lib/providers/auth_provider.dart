import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  String _username = '';
  bool _isLoggedIn = false;
  bool _isReady = false;

  String get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  bool get isReady => _isReady;

  AuthProvider() {
    _loadAuthState();
  }

  // Load authentication state from storage and Supabase
  Future<void> _loadAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _username = prefs.getString(AppConstants.keyUsername) ?? '';

      // Check Supabase session
      final user = SupabaseService.currentUser;
      _isLoggedIn = user != null;

      if (_isLoggedIn && user?.userMetadata != null) {
        _username = user!.userMetadata!['username'] ?? _username;
      }
    } catch (e) {
      debugPrint('Error loading auth state: $e');
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  // ── Sign Up ───────────────────────────────────────────────────────────────

  /// Step 1: Sign up with email, password, and username.
  /// This creates the user in Supabase and sends an OTP if email confirmation is on.
  Future<String?> signUp(String email, String password, String username) async {
    try {
      if (!_isValidEmail(email)) return 'Please enter a valid email address';
      if (username.length < 3) return 'Username must be at least 3 characters';
      if (password.length < 8) return 'Password must be at least 8 characters';

      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        username: username,
      );

      // If user is created but not confirmed, we need to verify OTP.
      // If user is created and confirmed (auto-confirm on), we are logged in.
      if (response.user != null) {
        if (response.session != null) {
          // Auto-confirmed
          await _handleLoginSuccess(response.user!, username);
          return null;
        } else {
          // Needs confirmation
          return 'OTP_REQUIRED';
        }
      }
      return 'Sign up failed. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Signup error: $e');
      return 'An unexpected error occurred during sign up.';
    }
  }

  /// Step 2: Verify OTP for Signup.
  Future<String?> verifySignupOtp(
      String email, String token, String username) async {
    try {
      final response = await SupabaseService.verifyOtp(
        email: email,
        token: token,
        type: OtpType.signup,
      );

      if (response.user != null && response.session != null) {
        await _handleLoginSuccess(response.user!, username);
        return null; // Success
      }
      return 'Invalid or expired code. Please try again.';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Verify OTP error: $e');
      return 'Failed to verify code. Please try again.';
    }
  }

  /// Resend Signup OTP.
  Future<String?> resendSignupOtp(String email) async {
    try {
      await SupabaseService.resendOtp(email: email, type: OtpType.signup);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to resend code.';
    }
  }

  // ── Login ─────────────────────────────────────────────────────────────────

  Future<String?> login(String email, String password) async {
    try {
      final response = await SupabaseService.signIn(email, password);
      if (response.user != null && response.session != null) {
        final username =
            response.user!.userMetadata?['username'] ?? email.split('@')[0];
        await _handleLoginSuccess(response.user!, username);
        return null; // Success
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('email not confirmed')) {
        return 'EMAIL_NOT_CONFIRMED';
      }
      return e.message;
    } catch (e) {
      debugPrint('Login error: $e');
      return 'Login failed. Please check your credentials and try again.';
    }
    return 'Login failed. Please try again.';
  }

  // ── Forgot Password ───────────────────────────────────────────────────────

  Future<String?> sendPasswordReset(String email) async {
    try {
      if (!_isValidEmail(email)) return 'Please enter a valid email address';
      await SupabaseService.sendPasswordReset(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to send password reset email.';
    }
  }

  Future<String?> verifyRecoveryOtp(String email, String token) async {
    try {
      final response = await SupabaseService.verifyOtp(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
      return (response.user != null && response.session != null)
          ? null
          : 'Invalid code';
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Verification failed.';
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await SupabaseService.updatePassword(newPassword);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'Failed to update password.';
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

  // ── Delete Account ────────────────────────────────────────────────────────

  /// Permanently deletes the user account.
  /// Re-authenticates with password first before deleting for security.
  Future<String?> deleteAccount(String password) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return 'Not logged in.';

      final email = user.email ?? '';
      if (email.isEmpty) return 'Unable to verify account.';

      // Re-authenticate to confirm the user knows their password
      final reAuth = await SupabaseService.signIn(email, password);
      if (reAuth.user == null) return 'Incorrect password. Please try again.';

      // Delete the account via Supabase RPC function
      await SupabaseService.deleteAccount();

      // Clear local state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyUsername);
      await prefs.setBool(AppConstants.keyIsLoggedIn, false);

      _username = '';
      _isLoggedIn = false;
      notifyListeners();
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return 'Failed to delete account. Please try again.';
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _handleLoginSuccess(User user, String username) async {
    final prefs = await SharedPreferences.getInstance();
    _username = username;
    await prefs.setString(AppConstants.keyUsername, _username);
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    _isLoggedIn = true;
    notifyListeners();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }
}
