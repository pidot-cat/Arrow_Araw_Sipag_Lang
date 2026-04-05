import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _verificationController = TextEditingController();

  bool _isLoading = false;
  bool _codeSent = false;
  int _timerSeconds = 0;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _verificationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer?.cancel();
    setState(() {
      _codeSent = true;
      _timerSeconds = 60;
    });
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
          _codeSent = false;
        }
      });
    });
  }

  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _showSnackBar('Please fill in all fields', Colors.orange);
      return;
    }

    if (password != confirm) {
      _showSnackBar('Passwords do not match', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.signUp(email, password, username);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      // Auto-confirmed, go home
      Navigator.pushReplacementNamed(context, '/home');
    } else if (result == 'OTP_REQUIRED') {
      // Needs confirmation
      _startTimer();
      _showSnackBar('Verification code sent to your email!', Colors.green);
    } else {
      _showSnackBar(result, Colors.red);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final code = _verificationController.text.trim();
    final username = _usernameController.text.trim();

    if (code.isEmpty) {
      _showSnackBar('Please enter the verification code', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.verifySignupOtp(email, code, username);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar(result, Colors.red);
    }
  }

  Future<void> _resendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.resendSignupOtp(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      _startTimer();
      _showSnackBar('Verification code resent!', Colors.green);
    } else {
      _showSnackBar(result, Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fieldSpacing = size.height * 0.011;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BackgroundWrapper(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppConstants.logoWithBg,
                  width: size.width * 0.22,
                  height: size.width * 0.22,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  'Create Account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.015),

                // 1. Username
                GradientInputField(
                  hintText: 'Username',
                  controller: _usernameController,
                  prefixIcon: Icons.person,
                  enabled: !_codeSent,
                ),
                SizedBox(height: fieldSpacing),

                // 2. Email
                GradientInputField(
                  hintText: 'Email',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_codeSent,
                ),
                SizedBox(height: fieldSpacing),

                // 3. Password
                GradientInputField(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                  enabled: !_codeSent,
                ),
                SizedBox(height: fieldSpacing),

                // 4. Confirm Password
                GradientInputField(
                  hintText: 'Confirm Password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline,
                  enabled: !_codeSent,
                ),
                SizedBox(height: fieldSpacing),

                // 5. Verification Code (Only show if code sent)
                if (_codeSent) ...[
                  Row(
                    children: [
                      Expanded(
                        child: GradientInputField(
                          hintText: 'Verification Code',
                          controller: _verificationController,
                          prefixIcon: Icons.verified_user,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: (_timerSeconds > 0 || _isLoading) ? null : _resendCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _timerSeconds > 0
                                  ? [Colors.grey.shade800, Colors.grey.shade900]
                                  : [const Color(0xFF271E9A), const Color(0xFF212125)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _timerSeconds > 0 ? '${_timerSeconds}s' : 'Resend',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.025),
                ],

                SizedBox(height: size.height * 0.01),

                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan))
                    : GradientButton(
                        text: _codeSent ? 'VERIFY & SIGN UP' : 'SIGN UP',
                        onPressed: _codeSent ? _handleVerifyOtp : _handleSignUp,
                      ),

                SizedBox(height: size.height * 0.015),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text('Login',
                          style: TextStyle(
                              color: Colors.cyan, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
