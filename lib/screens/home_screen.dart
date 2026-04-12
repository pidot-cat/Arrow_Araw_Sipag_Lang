// lib/screens/home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// [FIX NAV] PopScope(canPop: false) — system back button disabled on Home.
//           Users cannot press back to return to the Login screen.
// [FIX AUDIO] WidgetsBindingObserver — Lobby-Music auto-resumes when the app
//           returns to the foreground while on this screen.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';
import '../widgets/background_wrapper.dart';
import '../widgets/gradient_button.dart';
import '../utils/constants.dart';
import 'level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    // Register lifecycle observer for lobby music auto-resume
    WidgetsBinding.instance.addObserver(this);
    // Start lobby music after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _audioService.playMenuMusic();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // [FIX AUDIO] Auto-resume Lobby-Music when app returns to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Only resume if we're still in the menu/lobby context
      _audioService.playMenuMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    // [FIX NAV] canPop: false prevents system back from returning to Login
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: BackgroundWrapper(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppConstants.logoWithBg,
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                  ),
                  SizedBox(height: size.height * 0.022),
                  Text(
                    'Arrow Araw Sipag Lang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.07,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome, ${authProvider.username}!',
                    style: TextStyle(
                      color: Colors.white.withAlpha(128),
                      fontSize: size.width * 0.045,
                    ),
                  ),
                  SizedBox(height: size.height * 0.07),
                  GradientButton(
                    text: 'PLAY',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LevelSelectScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: size.height * 0.022),
                  GradientButton(
                    text: 'RECORDS',
                    onPressed: () => Navigator.pushNamed(context, '/records'),
                  ),
                  SizedBox(height: size.height * 0.022),
                  GradientButton(
                    text: 'SETTINGS',
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
