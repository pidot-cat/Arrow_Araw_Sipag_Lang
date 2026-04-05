import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Standard top gap
              SizedBox(height: size.height * 0.055),
              Image.asset(AppConstants.logoWithBg, width: 160, height: 160),
              const SizedBox(height: 16),
              const Text(
                'About us',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.white.withAlpha(153),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              _buildInfoCard(
                'Our Mission',
                'Arrow Araw Sipag Lang is designed to challenge your puzzle-solving skills '
                    'while providing an engaging and visually stunning gaming experience. '
                    'Our mission is to create games that are both entertaining and mentally stimulating.',
                Icons.flag_rounded,
                Colors.cyan,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Game Concept',
                'Navigate colorful arrows through a strategic puzzle board. Each arrow moves '
                    'in its indicated direction, and your goal is to clear the entire board '
                    'without hitting arrows. Manage your 3 lives wisely!',
                Icons.gamepad_rounded,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Development Team',
                'Created with passion by a dedicated student who love puzzles '
                    'and gaming. We continuously work to improve your experience and add new features.',
                Icons.people_rounded,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Technology',
                'Built with Flutter for Android-platform, ensuring smooth performance '
                    'on Android devices. Designed with modern UI/UX principles.',
                Icons.code_rounded,
                Colors.green,
              ),
              const SizedBox(height: 28),
              Text(
                '© 2026 Arrow Araw Sipag Lang',
                style: TextStyle(
                  color: Colors.white.withAlpha(128),
                  fontSize: 13,
                ),
              ),
              Text(
                'All rights reserved',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String content, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: TextStyle(
                color: Colors.white.withAlpha(204), fontSize: 14, height: 1.55),
          ),
        ],
      ),
    );
  }
}
