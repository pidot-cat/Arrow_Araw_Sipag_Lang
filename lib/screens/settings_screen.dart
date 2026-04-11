// lib/screens/settings_screen.dart
// Settings screen: Music/SFX toggles, logout, delete account, support links.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../utils/constants.dart';
import '../utils/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/level_unlock_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AudioService _audio = AudioService();

  Future<void> _handleLogout() async {
    _audio.stopAll();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  void _showAudioSettingsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Audio Settings',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1)),
              const SizedBox(height: 6),
              Text('assets/sounds/  ·  lib/sounds/',
                  style: TextStyle(
                      color: Colors.white.withAlpha(100), fontSize: 11)),
              const SizedBox(height: 20),
              // Music toggle
              _buildAudioToggle(
                ctx,
                setModal,
                icon: Icons.music_note_rounded,
                label: 'Background Music',
                subtitle: 'Lobby-Music · Ingame-Music',
                value: _audio.isMusicOn,
                onChanged: (v) async {
                  await _audio.toggleMusic();
                  setModal(() {});
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),
              // SFX toggle
              _buildAudioToggle(
                ctx,
                setModal,
                icon: Icons.volume_up_rounded,
                label: 'Sound FX',
                subtitle: 'Arrow · Win · Wrong Move · Game Over',
                value: _audio.isSfxOn,
                onChanged: (v) {
                  _audio.toggleSfx();
                  setModal(() {});
                  setState(() {});
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAudioToggle(
    BuildContext ctx,
    StateSetter setModal, {
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.cyan, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withAlpha(120), fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.cyanAccent,
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    final TextEditingController passCtrl = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        bool obscureText = true;
        String? errorMsg;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E2E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text('Delete Account',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This is permanent and cannot be undone.\nEnter your password to confirm.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Re-registering with the same email will start fresh (Level 1, zero stats).',
                    style: TextStyle(color: Colors.orange.withAlpha(200), fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passCtrl,
                    obscureText: obscureText,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white38),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white38,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscureText = !obscureText),
                      ),
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
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white54)),
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
                              Provider.of<AuthProvider>(ctx, listen: false);
                          final gameProvider =
                              Provider.of<GameProvider>(ctx, listen: false);

                          final dialogNav = Navigator.of(ctx);
                          final rootNav = Navigator.of(context);

                          // Wipe stats and level progress BEFORE deletion
                          await gameProvider.resetStats();
                          await LevelUnlockService.instance.resetProgress();

                          // Hard-delete account from Supabase Auth + public tables
                          final result = await authProvider.deleteAccount(pass);
                          if (!ctx.mounted) return;

                          if (result == null) {
                            // Success — navigate to login as fresh user
                            dialogNav.pop();
                            _audio.stopAll();
                            rootNav.pushNamedAndRemoveUntil(
                                '/login', (r) => false);
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
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Delete',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
                SizedBox(height: size.height * 0.01),
                Center(child: Image.asset(AppConstants.logoWithBg, width: 100, height: 100)),
                const SizedBox(height: 8),
                const Text('Settings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Logged in as: ${authProvider.username}',
                    style: TextStyle(
                        color: Colors.white.withAlpha(179), fontSize: 13)),
                const SizedBox(height: 16),

                // ── Audio Settings ──────────────────────────────────────────
                _buildSettingTile(
                  'Audio Settings',
                  _audio.isMusicOn && _audio.isSfxOn
                      ? 'Music & SFX On'
                      : !_audio.isMusicOn && !_audio.isSfxOn
                          ? 'Music & SFX Off'
                          : 'Partially Muted',
                  Icons.tune_rounded,
                  _showAudioSettingsModal,
                ),
                const SizedBox(height: 10),

                // ── Navigation tiles ────────────────────────────────────────
                _buildSettingTile('Contact Us', 'Get help and support',
                    Icons.contact_support,
                    () => Navigator.pushNamed(context, '/contact')),
                const SizedBox(height: 10),
                _buildSettingTile('Terms of Service', 'Read our terms',
                    Icons.description,
                    () => Navigator.pushNamed(context, '/terms')),
                const SizedBox(height: 10),
                _buildSettingTile('Privacy Policy', 'Your privacy matters',
                    Icons.privacy_tip,
                    () => Navigator.pushNamed(context, '/policy')),
                const SizedBox(height: 10),
                _buildSettingTile('About Us', 'Learn more about the app',
                    Icons.info,
                    () => Navigator.pushNamed(context, '/about')),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B0000),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: const Text('LOG OUT',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _showDeleteAccountDialog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('DELETE ACCOUNT',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
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
      String title, String subtitle, IconData icon, VoidCallback onTap) {
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
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.cyan, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withAlpha(153), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withAlpha(128), size: 13),
          ],
        ),
      ),
    );
  }
}
