// lib/screens/forgot_password_screen.dart
// FIX Bug 4: Replaced misleading "code sent to email" snackbar with honest
//   "If that email is registered, a code was sent." message. Supabase
//   intentionally doesn't reveal whether an email exists (anti-enumeration),
//   so we match that behaviour in the UI rather than lying to the user.
// FIX Bug 5: All snackbar messages are now clear, consistent, and contextual.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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

  // FIX Bug 5: centralized, clear snackbar helper
  void _showSnack(String message, {required _SnackType type}) {
    if (!mounted) return;
    final Color bg;
    final IconData icon;
    switch (type) {
      case _SnackType.success:
        bg = const Color(0xFF1B5E20);
        icon = Icons.check_circle_outline;
        break;
      case _SnackType.error:
        bg = const Color(0xFFB71C1C);
        icon = Icons.error_outline;
        break;
      case _SnackType.warning:
        bg = const Color(0xFFE65100);
        icon = Icons.warning_amber_outlined;
        break;
      case _SnackType.info:
        bg = const Color(0xFF0D47A1);
        icon = Icons.info_outline;
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(message, style: const TextStyle(color: Colors.white))),
        ]),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 4),
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

  // FIX Bug 4: honest messaging — we don't know if the email is registered
  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showSnack('Please enter a valid email address.',
          type: _SnackType.warning);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.sendPasswordReset(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      _verifiedEmail = email;
      _startTimer();
      setState(() => _step = 2);
      // FIX: honest message — Supabase silently succeeds even for unknown emails
      _showSnack(
        'If "$email" is registered, a 6-digit code was sent. Check your inbox and spam folder.',
        type: _SnackType.info,
      );
    } else {
      _showSnack('Could not send code: $result', type: _SnackType.error);
    }
  }

  Future<void> _handleResendCode() async {
    if (_timerSeconds > 0) return;
    await _handleSendCode();
  }

  Future<void> _handleVerifyOtp() async {
    final code = _otpController.text.trim();
    if (code.isEmpty || code.length < 6) {
      _showSnack('Please enter the full 6-digit code.',
          type: _SnackType.warning);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.verifyRecoveryOtp(_verifiedEmail, code);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      setState(() => _step = 3);
      _showSnack('Code verified! Now set your new password.',
          type: _SnackType.success);
    } else {
      _showSnack('Invalid or expired code. Try requesting a new one.',
          type: _SnackType.error);
    }
  }

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showSnack('Please fill in both password fields.',
          type: _SnackType.warning);
      return;
    }
    if (newPassword.length < 8) {
      _showSnack('Password must be at least 8 characters long.',
          type: _SnackType.warning);
      return;
    }
    if (newPassword != confirmPassword) {
      _showSnack('Passwords do not match. Please re-enter.',
          type: _SnackType.error);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.updatePassword(newPassword);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      _showSnack('Password updated successfully!', type: _SnackType.success);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      _showSnack('Failed to update password: $result', type: _SnackType.error);
    }
  }

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
                Image.asset(AppConstants.logoWithBg,
                    width: size.width * 0.22, height: size.width * 0.22),
                SizedBox(height: size.height * 0.01),
                _buildStepIndicator(),
                SizedBox(height: size.height * 0.02),
                Text(_stepTitle(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: size.height * 0.008),
                Text(_stepSubtitle(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withAlpha(153),
                        fontSize: size.width * 0.035)),
                SizedBox(height: size.height * 0.03),
                if (_step == 1) _buildStep1(),
                if (_step == 2) _buildStep2(size),
                if (_step == 3) _buildStep3(size),
                SizedBox(height: size.height * 0.025),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan))
                    : GradientButton(
                        text: _buttonLabel(), onPressed: _onButtonPressed()),
                SizedBox(height: size.height * 0.02),
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
                  child: Text(_step > 1 ? '← Back' : 'Back to Login',
                      style: const TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() => GradientInputField(
        hintText: 'Email address',
        controller: _emailController,
        prefixIcon: Icons.email,
        keyboardType: TextInputType.emailAddress,
      );

  Widget _buildStep2(Size size) => Column(children: [
        GradientInputField(
          hintText: '6-digit verification code',
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
                color: _timerSeconds > 0
                    ? Colors.white.withAlpha(100)
                    : Colors.cyan,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]);

  Widget _buildStep3(Size size) => Column(children: [
        GradientInputField(
            hintText: 'New Password (min 8 chars)',
            controller: _newPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock),
        SizedBox(height: size.height * 0.011),
        GradientInputField(
            hintText: 'Confirm New Password',
            controller: _confirmPasswordController,
            obscureText: true,
            prefixIcon: Icons.lock_outline),
      ]);

  Widget _buildStepIndicator() => Row(
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

  String _stepTitle() {
    switch (_step) {
      case 1:
        return 'Forgot Password';
      case 2:
        return 'Check Your Email';
      case 3:
        return 'Create New Password';
      default:
        return '';
    }
  }

  // FIX Bug 4: subtitle now accurately describes the ambiguous result
  String _stepSubtitle() {
    switch (_step) {
      case 1:
        return 'Enter your account email. If it\'s\nregistered, we\'ll send a reset code.';
      case 2:
        return 'Enter the 6-digit code from\nyour email. Check spam if needed.';
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

enum _SnackType { success, error, warning, info }
