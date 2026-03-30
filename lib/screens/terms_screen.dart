import 'package:flutter/material.dart';
import '../widgets/background_wrapper.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        showLogo: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.1),
              const Center(
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection('Acceptance of Terms',
                  'By accessing and using Arrow Araw Sipag Lang, you accept and agree to be bound by the terms and provision of this agreement.'),
              _buildSection('Use License',
                  'Permission is granted to temporarily download one copy of Arrow Araw Sipag Lang per device for personal, non-commercial transitory viewing only.'),
              _buildSection('User Account',
                  'You are responsible for maintaining the confidentiality of your account and password.'),
              _buildSection('Game Rules',
                  'Players must follow the game rules and play fairly. Any attempt to cheat, hack, or exploit the game will result in immediate account termination.'),
              _buildSection('Intellectual Property',
                  'All content, features, and functionality are owned by Arrow Araw Sipag Lang and are protected by international copyright, trademark, and other intellectual property laws.'),
              _buildSection('Limitation of Liability',
                  'Arrow Araw Sipag Lang shall not be liable for any damages arising out of the use or inability to use the game.'),
              _buildSection('Modifications',
                  'We reserve the right to modify or replace these Terms at any time.'),
              _buildSection('Contact Information',
                  'For questions about these Terms, please contact us at support@arrowaraw.com'),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Last Updated: February 2026',
                  style: TextStyle(
                      color: Colors.white.withAlpha(128),
                      fontSize: 13,
                      fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(content,
              style: TextStyle(
                  color: Colors.white.withAlpha(204),
                  fontSize: 15,
                  height: 1.5)),
        ],
      ),
    );
  }
}
