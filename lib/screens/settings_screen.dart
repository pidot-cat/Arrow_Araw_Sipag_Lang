import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // Logout: stop all audio then navigate to login
  Future<void> _handleLogout(BuildContext context) async {
    AudioService().stopAll();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  // Delete Account dialog with password confirmation
  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final TextEditingController passCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        String? errorMsg;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Delete Account',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This action is permanent and cannot be undone.\nEnter your password to confirm.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      errorText: errorMsg,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final pass = passCtrl.text.trim();
                          if (pass.isEmpty) {
                            setDialogState(
                                () => errorMsg = 'Password is required');
                            return;
                          }
                          setDialogState(() {
                            isLoading = true;
                            errorMsg = null;
                          });
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final result = await authProvider.deleteAccount(pass);
                          if (!ctx.mounted) return;
                          if (result == null) {
                            Navigator.pop(ctx);
                            AudioService().stopAll();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/login', (r) => false);
                            }
                          } else {
                            setDialogState(() {
                              isLoading = false;
                              errorMsg = result;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade800,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );

    passCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                // Logo — smaller so everything fits without scrolling
                SizedBox(height: size.height * 0.01),
                Center(
                  child: Image.asset(
                    AppConstants.logoWithBg,
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Logged in as: ${authProvider.username}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(179),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),

                // Settings tiles
                _buildSettingTile(
                  context,
                  'Contact Us',
                  'Get help and support',
                  Icons.contact_support,
                  () => Navigator.pushNamed(context, '/contact'),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  context,
                  'Terms of Service',
                  'Read our terms',
                  Icons.description,
                  () => Navigator.pushNamed(context, '/terms'),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  context,
                  'Privacy Policy',
                  'Your privacy matters',
                  Icons.privacy_tip,
                  () => Navigator.pushNamed(context, '/policy'),
                ),
                const SizedBox(height: 10),
                _buildSettingTile(
                  context,
                  'About Us',
                  'Learn more about the app',
                  Icons.info,
                  () => Navigator.pushNamed(context, '/about'),
                ),

                const Spacer(),

                // LOG OUT button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF8B0000).withAlpha(120),
                    ),
                    child: const Text(
                      'LOG OUT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // DELETE ACCOUNT button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showDeleteAccountDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side:
                          const BorderSide(color: Colors.redAccent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'DELETE ACCOUNT',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.025),
              ],
            ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(13),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(26)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.cyan.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.cyan, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withAlpha(153),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha(128),
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
