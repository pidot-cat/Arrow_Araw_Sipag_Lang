import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../utils/constants.dart';
import '../providers/auth_provider.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audio = AudioService();

  late final AnimationController _panelCtrl;
  late final Animation<double> _panelAnim;
  bool _panelOpen = false;
  late bool _musicOn;
  late bool _sfxOn;

  @override
  void initState() {
    super.initState();
    _musicOn = _audio.isMusicOn;
    _sfxOn   = _audio.isSfxOn;
    _panelCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _panelAnim =
        CurvedAnimation(parent: _panelCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _panelCtrl.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _panelOpen = !_panelOpen);
    _panelOpen ? _panelCtrl.forward() : _panelCtrl.reverse();
  }

  Future<void> _toggleMusic() async {
    await _audio.toggleMusic();
    setState(() => _musicOn = _audio.isMusicOn);
  }

  void _toggleSfx() {
    _audio.toggleSfx();
    setState(() => _sfxOn = _audio.isSfxOn);
  }

  Future<void> _handleLogout(BuildContext context) async {
    _audio.stopAll();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final passCtrl = TextEditingController();
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isLoading = false;
        String? errorMsg;
        return StatefulBuilder(builder: (ctx, setDs) {
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
                    'This action is permanent and cannot be undone.\nEnter your password to confirm.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 16),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    errorText: errorMsg,
                    errorStyle:
                        const TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final pass = passCtrl.text.trim();
                        if (pass.isEmpty) {
                          setDs(() => errorMsg = 'Password is required');
                          return;
                        }
                        setDs(() {
                          isLoading = true;
                          errorMsg = null;
                        });
                        final auth = Provider.of<AuthProvider>(context,
                            listen: false);
                        final result =
                            await auth.deleteAccount(pass);
                        if (!ctx.mounted) return;
                        if (result == null) {
                          Navigator.pop(ctx);
                          _audio.stopAll();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (_) => false);
                          }
                        } else {
                          setDs(() {
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
                        style:
                            TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
      },
    );
    passCtrl.dispose();
  }

  // ── Audio expandable panel ──────────────────────────────────────────────
  Widget _buildAudioPanel() {
    return Column(
      children: [
        InkWell(
          onTap: _togglePanel,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: const Icon(Icons.volume_up,
                      color: Colors.cyan, size: 20),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Audio',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Music & sound effects',
                          style: TextStyle(
                              color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                ),
                AnimatedBuilder(
                  animation: _panelAnim,
                  builder: (_, __) => Transform.rotate(
                    angle: _panelAnim.value * 3.14159,
                    child: Icon(Icons.keyboard_arrow_down,
                        color: Colors.white.withAlpha(180), size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _panelAnim,
          child: Container(
            margin: const EdgeInsets.only(top: 2),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              border: Border.all(color: Colors.white.withAlpha(18)),
            ),
            child: Column(
              children: [
                _buildToggleRow(
                  icon: Icons.music_note,
                  label: 'Music',
                  subtitle: 'Background music',
                  value: _musicOn,
                  onTap: _toggleMusic,
                ),
                const Divider(color: Colors.white12, height: 20),
                _buildToggleRow(
                  icon: Icons.spatial_audio_off,
                  label: 'Sound Effects',
                  subtitle: 'Arrow & game sounds',
                  value: _sfxOn,
                  onTap: () async => _toggleSfx(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Future<void> Function() onTap,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: (value ? Colors.cyan : Colors.white30).withAlpha(40),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: value ? Colors.cyan : Colors.white38, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: value ? Colors.white : Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              Text(subtitle,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: 48,
            height: 26,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: value
                  ? Colors.cyan.withAlpha(200)
                  : Colors.white.withAlpha(40),
              border: Border.all(
                  color: value ? Colors.cyan : Colors.white24,
                  width: 1.2),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: value ? 22 : 2,
                  top: 3,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: value ? Colors.white : Colors.white54,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 4,
                            offset: const Offset(0, 1))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Nav Tile ──────────────────────────────────────────────────────────────
  Widget _buildSettingTile(BuildContext context, String title,
      String subtitle, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.white.withAlpha(153),
                          fontSize: 12)),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Column(
              children: [
                SizedBox(height: size.height * 0.01),
                Center(
                  child: Image.asset(AppConstants.logoWithBg,
                      width: 100, height: 100),
                ),
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
                        color: Colors.white.withAlpha(179),
                        fontSize: 13)),
                const SizedBox(height: 16),

                _buildAudioPanel(),
                const SizedBox(height: 10),

                _buildSettingTile(context, 'Contact Us',
                    'Get help and support', Icons.contact_support,
                    () => Navigator.pushNamed(context, '/contact')),
                const SizedBox(height: 10),
                _buildSettingTile(context, 'Terms of Service',
                    'Read our terms', Icons.description,
                    () => Navigator.pushNamed(context, '/terms')),
                const SizedBox(height: 10),
                _buildSettingTile(context, 'Privacy Policy',
                    'Your privacy matters', Icons.privacy_tip,
                    () => Navigator.pushNamed(context, '/policy')),
                const SizedBox(height: 10),
                _buildSettingTile(context, 'About Us',
                    'Learn more about the app', Icons.info,
                    () => Navigator.pushNamed(context, '/about')),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF271E9A),
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                      shadowColor:
                          const Color(0xFF271E9A).withAlpha(120),
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
                    onPressed: () =>
                        _showDeleteAccountDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                          color: Colors.redAccent, width: 1.5),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
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
}
