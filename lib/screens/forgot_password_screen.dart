import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../utils/constants.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Forgot Password — 3-step flow
/// Step 1 → Enter Email
/// Step 2 → Enter 6-digit OTP
/// Step 3 → Create New Password + Confirm Password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  int _step = 1; // 1 = Email, 2 = OTP, 3 = New Password
  bool _isLoading = false;
  int _timerSeconds = 0;
  Timer? _countdownTimer;
  String _verifiedEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() => _timerSeconds = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ── Step 1: Send OTP ──────────────────────────────────────────────────────

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      _showSnack('Please enter a valid email address', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ✅ FIXED: Gumagamit ng sendRecoveryOtp (shouldCreateUser: false)
      await SupabaseService.sendRecoveryOtp(email);
      _verifiedEmail = email;
      _startTimer();
      setState(() => _step = 2);
      _showSnack('Verification code sent to $email', Colors.green);
    } catch (e) {
      _showSnack('Failed to send code. Please try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 2: Verify OTP ────────────────────────────────────────────────────

  Future<void> _handleResendCode() async {
    if (_timerSeconds > 0) return;
    setState(() => _isLoading = true);
    try {
      // ✅ FIXED: Gumagamit ng sendRecoveryOtp para sa resend
      await SupabaseService.sendRecoveryOtp(_verifiedEmail);
      _startTimer();
      _showSnack('Code resent to $_verifiedEmail', Colors.green);
    } catch (e) {
      _showSnack('Failed to resend code. Please try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();

    if (code.isEmpty || code.length < 6) {
      _showSnack('Please enter the 6-digit code', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ✅ FIXED: OtpType.recovery ang gamitin para sa forgot password
      final isValid = await SupabaseService.verifyOtp(
        _verifiedEmail,
        code,
        type: OtpType.recovery,
      );
      if (!mounted) return;

      if (isValid) {
        setState(() => _step = 3);
        _showSnack('Code verified! Set your new password.', Colors.green);
      } else {
        _showSnack('Invalid or expired code. Please try again.', Colors.red);
      }
    } catch (e) {
      _showSnack('Verification failed. Please try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 3: Reset Password ────────────────────────────────────────────────

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Please fill in all fields', Colors.orange);
      return;
    }

    if (newPassword.length < 8) {
      _showSnack('Password must be at least 8 characters', Colors.orange);
      return;
    }

    if (newPassword != confirmPassword) {
      _showSnack('Passwords do not match', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseService.updatePassword(newPassword);
      if (!mounted) return;
      _showSnack('Password changed successfully!', Colors.green);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _showSnack('Failed to update password. Please try again.', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundWrapper(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  AppConstants.logoWithBg,
                  width: size.width * 0.22,
                  height: size.width * 0.22,
                ),
                SizedBox(height: size.height * 0.01),

                // Step indicator dots
                _buildStepIndicator(),
                SizedBox(height: size.height * 0.02),

                // Title + Subtitle
                Text(
                  _stepTitle(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                Text(
                  _stepSubtitle(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withAlpha(153),
                    fontSize: size.width * 0.035,
                  ),
                ),
                SizedBox(height: size.height * 0.03),

                // Step content
                if (_step == 1) _buildStep1(size),
                if (_step == 2) _buildStep2(size),
                if (_step == 3) _buildStep3(size),

                SizedBox(height: size.height * 0.025),

                // Action button
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan))
                    : GradientButton(
                        text: _buttonLabel(),
                        onPressed: _onButtonPressed(),
                      ),

                SizedBox(height: size.height * 0.02),

                // Back to Login link
                GestureDetector(
                  onTap: () {
                    if (_step > 1) {
                      setState(() {
                        _step--;
                        _otpController.clear();
                        _newPasswordController.clear();
                        _confirmPasswordController.clear();
                      });
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  },
                  child: Text(
                    _step > 1 ? '← Back' : 'Back to Login',
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Step Widgets ──────────────────────────────────────────────────────────

  Widget _buildStep1(Size size) {
    return GradientInputField(
      hintText: 'Email',
      controller: _emailController,
      prefixIcon: Icons.email,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildStep2(Size size) {
    return Column(
      children: [
        GradientInputField(
          hintText: '6-digit Code',
          controller: _otpController,
          prefixIcon: Icons.lock_clock,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: size.height * 0.015),
        GestureDetector(
          onTap: _timerSeconds > 0 ? null : _handleResendCode,
          child: Text(
            _timerSeconds > 0
                ? 'Resend code in ${_timerSeconds}s'
                : 'Didn\'t receive a code? Resend',
            style: TextStyle(
              color:
                  _timerSeconds > 0 ? Colors.white.withAlpha(100) : Colors.cyan,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(Size size) {
    return Column(
      children: [
        GradientInputField(
          hintText: 'New Password',
          controller: _newPasswordController,
          obscureText: true,
          prefixIcon: Icons.lock,
        ),
        SizedBox(height: size.height * 0.011),
        GradientInputField(
          hintText: 'Confirm Password',
          controller: _confirmPasswordController,
          obscureText: true,
          prefixIcon: Icons.lock_outline,
        ),
      ],
    );
  }

  // ── Step helpers ──────────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i + 1 == _step;
        final isDone = i + 1 < _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.cyan
                : isDone
                    ? Colors.cyan.withAlpha(150)
                    : Colors.white.withAlpha(60),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  String _stepTitle() {
    switch (_step) {
      case 1:
        return 'Forgot Password';
      case 2:
        return 'Verify Your Email';
      case 3:
        return 'Create New Password';
      default:
        return '';
    }
  }

  String _stepSubtitle() {
    switch (_step) {
      case 1:
        return 'Enter your email and we\'ll send\na 6-digit verification code.';
      case 2:
        return 'Enter the 6-digit code sent\nto $_verifiedEmail';
      case 3:
        return 'Your new password must be\nat least 8 characters long.';
      default:
        return '';
    }
  }

  String _buttonLabel() {
    switch (_step) {
      case 1:
        return 'SEND CODE';
      case 2:
        return 'VERIFY CODE';
      case 3:
        return 'SAVE PASSWORD';
      default:
        return '';
    }
  }

  VoidCallback _onButtonPressed() {
    switch (_step) {
      case 1:
        return _handleSendCode;
      case 2:
        return _handleVerifyOtp;
      case 3:
        return _handleResetPassword;
      default:
        return () {};
    }
  }
}
