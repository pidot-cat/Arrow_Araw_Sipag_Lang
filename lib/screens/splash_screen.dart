// splash_screen.dart
// Launch screen with mandatory connectivity check.
//
// KEY BEHAVIOURS:
//   • Online + logged-in  → go directly to /home
//   • Online + not logged-in → go to /login
//   • Offline (any state) → stay on splash with persistent Snackbar, keep polling
//
// The app blocks navigation entirely when offline — even for previously
// logged-in users — until a real internet connection is restored.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _snackBarShown = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        duration: const Duration(seconds: 2), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
    _init();
  }

  /// Real internet check via DNS lookup (5-second timeout).
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Main entry point after splash animation kicks off.
  Future<void> _init() async {
    // Wait for the splash logo to finish appearing
    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    // MANDATORY connectivity check — blocks ALL navigation when offline
    final online = await _hasInternet();
    if (!mounted) return;

    if (!online) {
      _showNoInternetSnackBar();
      _retryWhenOnline();
      return;
    }

    // Online: check auth state and route accordingly
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isReady) await _waitForAuthReady(auth);
    if (!mounted) return;

    if (auth.isLoggedIn) {
      _goHome();
    } else {
      _goLogin();
    }
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _showNoInternetSnackBar() {
    if (!mounted || _snackBarShown) return;
    _snackBarShown = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please check your internet connection.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: Duration(days: 1), // dismissed programmatically
      ),
    );
  }

  /// Polls every 3 s until online, then dismisses the snackbar and navigates.
  void _retryWhenOnline() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final online = await _hasInternet();
      if (!mounted) return;

      if (!online) {
        _retryWhenOnline(); // keep polling
        return;
      }

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _snackBarShown = false;

      // Re-check auth state
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (!auth.isReady) await _waitForAuthReady(auth);
      if (!mounted) return;

      if (auth.isLoggedIn) {
        _goHome();
      } else {
        _goLogin();
      }
    });
  }

  Future<void> _waitForAuthReady(AuthProvider auth) async {
    final completer = Completer<void>();
    void listener() {
      if (auth.isReady) {
        auth.removeListener(listener);
        completer.complete();
      }
    }
    auth.addListener(listener);
    return completer.future;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1D),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.background),
            fit: BoxFit.cover,
            opacity: 0.4,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppConstants.logoWithBg,
                  width: size.width * 0.55,
                  height: size.width * 0.55,
                ),
                SizedBox(height: size.height * 0.06),
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.cyan),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
