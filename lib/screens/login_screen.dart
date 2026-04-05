import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../widgets/gradient_input_field.dart';
import '../utils/constants.dart';

/// Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Input Email and Password', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result == null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (result == 'EMAIL_NOT_CONFIRMED') {
      _showSnackBar('Email not confirmed. Please check your inbox or sign up again.', Colors.red);
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

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: BackgroundWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: size.height * 0.06),
                Image.asset(
                  AppConstants.logoWithBg,
                  width: size.width * 0.38,
                  height: size.width * 0.38,
                ),
                SizedBox(height: size.height * 0.025),
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.075,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: size.height * 0.006),
                Text(
                  'Login to continue your adventure',
                  style: TextStyle(
                    color: Colors.white.withAlpha(128),
                    fontSize: size.width * 0.038,
                  ),
                ),
                SizedBox(height: size.height * 0.045),
                GradientInputField(
                  hintText: 'Email',
                  controller: _emailController,
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: size.height * 0.022),
                GradientInputField(
                  hintText: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: Icons.lock,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _handleForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.cyan, fontSize: 13),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.018),
                _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan))
                    : GradientButton(text: 'LOGIN', onPressed: _handleLogin),
                SizedBox(height: size.height * 0.022),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.white.withAlpha(128)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/signup'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
