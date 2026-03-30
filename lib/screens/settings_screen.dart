import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.06),
              // Logo at top center
              Center(
                child: Image.asset(
                  AppConstants.logoWithBg,
                  width: size.width * 0.35,
                  height: size.width * 0.35,
                ),
              ),
              SizedBox(height: size.height * 0.018),
              Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.075,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: size.height * 0.006),
              Text(
                'Logged in as: ${authProvider.username}',
                style: TextStyle(
                  color: Colors.white.withAlpha(179),
                  fontSize: size.width * 0.038,
                ),
              ),
              SizedBox(height: size.height * 0.04),
              _buildSettingTile(
                context,
                'Contact Us',
                'Get help and support',
                Icons.contact_support,
                () => Navigator.pushNamed(context, '/contact'),
              ),
              SizedBox(height: size.height * 0.018),
              _buildSettingTile(
                context,
                'Terms of Service',
                'Read our terms',
                Icons.description,
                () => Navigator.pushNamed(context, '/terms'),
              ),
              SizedBox(height: size.height * 0.018),
              _buildSettingTile(
                context,
                'Privacy Policy',
                'Your privacy matters',
                Icons.privacy_tip,
                () => Navigator.pushNamed(context, '/policy'),
              ),
              SizedBox(height: size.height * 0.018),
              _buildSettingTile(
                context,
                'About Us',
                'Learn more about the app',
                Icons.info,
                () => Navigator.pushNamed(context, '/about'),
              ),
              SizedBox(height: size.height * 0.045),
              // Logout button — dark red background
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B0000), // Dark Red
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF8B0000).withAlpha(120),
                  ),
                  child: const Text(
                    'LOG OUT',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final size = MediaQuery.of(context).size;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(size.width * 0.028),
              decoration: BoxDecoration(
                color: Colors.cyan.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.cyan, size: size.width * 0.055),
            ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size.width * 0.043,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(153),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(128),
              size: size.width * 0.038,
            ),
          ],
        ),
      ),
    );
  }
}
