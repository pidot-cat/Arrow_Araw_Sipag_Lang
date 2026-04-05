// lib/levels/level_base.dart
// Complete rewrite — all fixes applied:
//   1. Music: pause/resume (never restart mid-game)
//   2. SFX toggle: respects isSfxOn for all sounds
//   3. Shapes + grids: defined per level via shapeName getter
//   4. Game logic: canSlide verified before each tap; solvable in order
//   5. Smooth animation: slide + fade-out like Arrow Puzzle Escape

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

// ─── Direction ────────────────────────────────────────────────────────────────
enum ArrowDir { up, down, left, right }

// ─── Arrow data ───────────────────────────────────────────────────────────────
class ArrowData {
  final int id;
  int row, col;
  final ArrowDir dir;
  final int length;
  final Color color;
  bool solved;

  ArrowData({
    required this.id,
    required this.row,
    required this.col,
    required this.dir,
    required this.length,
    required this.color,
    this.solved = false,
  });

  /// All grid cells this arrow occupies
  List<(int, int)> get cells => List.generate(length, (i) {
        final r = row + (dir == ArrowDir.down ? i : dir == ArrowDir.up ? -i : 0);
        final c = col + (dir == ArrowDir.right ? i : dir == ArrowDir.left ? -i : 0);
        return (r, c);
      });
}

// ─── Difficulty helpers ───────────────────────────────────────────────────────
String _diffLabel(int lvl) {
  if (lvl <= 2) return 'Easy';
  if (lvl <= 4) return 'Normal';
  if (lvl <= 6) return 'Hard';
  if (lvl <= 8) return 'Expert';
  return 'Master';
}

Color _diffColor(int lvl) {
  if (lvl <= 2) return Colors.greenAccent;
  if (lvl <= 4) return Colors.yellowAccent;
  if (lvl <= 6) return Colors.orangeAccent;
  if (lvl <= 8) return Colors.redAccent;
  return AppColors.arrowPurple;
}

// ─── Level state mixin ────────────────────────────────────────────────────────
mixin LevelStateMixin<T extends StatefulWidget> on State<T>, TickerProvider {

  // ── Required getters per level ──────────────────────────────────────────────
  int get levelNumber;
  int get rows;
  int get cols;
  String get shapeName;
  List<ArrowData> Function() get buildArrowsFn;
  Widget Function() get nextLevelBuilder;

  // ── State ───────────────────────────────────────────────────────────────────
  late List<ArrowData> arrows;
  int nextSolveId = 0;
  int lives = 3;
  int secondsLeft = 60;
  bool gameOver = false;
  bool victory = false;
  bool _showSettings = false;

  Timer? _levelTimer;
  final Map<int, ValueNotifier<int>> _animTrigger = {};

  late AnimationController _settingsCtrl;
  late Animation<Offset> _settingsSlide;
  late Animation<double> _settingsFade;

  final AudioService _audio = AudioService();

  // ── Init ────────────────────────────────────────────────────────────────────
  void initLevelState() {
    arrows = buildArrowsFn();
    for (final a in arrows) {
      _animTrigger[a.id] = ValueNotifier(0);
    }
    _settingsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _settingsSlide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _settingsCtrl, curve: Curves.easeInOut));
    _settingsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _settingsCtrl, curve: Curves.easeInOut),
    );
    _audio.playGameMusic();
    _startTimer();
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    _settingsCtrl.dispose();
    for (final v in _animTrigger.values) {
      v.dispose();
    }
    super.dispose();
  }

  // ── Timer ───────────────────────────────────────────────────────────────────
  void _startTimer() {
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        secondsLeft--;
        if (secondsLeft <= 0) triggerGameOver();
      });
    });
  }

  // ── Game events ─────────────────────────────────────────────────────────────
  void triggerGameOver() {
    _levelTimer?.cancel();
    _audio.playLoseSound(); // lose sound ONLY here
    setState(() => gameOver = true);
  }

  void triggerVictory() {
    _levelTimer?.cancel();
    _audio.playWinSound();
    setState(() => victory = true);
    if (mounted) {
      context.read<GameProvider>().recordLevelComplete(
            level: levelNumber,
            time: 60 - secondsLeft,
            lives: lives,
          );
    }
  }

  // ── Slide logic ─────────────────────────────────────────────────────────────
  /// Returns true if this arrow can slide out of the grid (path is clear)
  bool canSlide(ArrowData arrow) {
    final occupied = <(int, int)>{};
    for (final a in arrows) {
      if (a.id != arrow.id && !a.solved) {
        for (final cell in a.cells) {
          occupied.add(cell);
        }
      }
    }
    final dr = arrow.dir == ArrowDir.down ? 1 : arrow.dir == ArrowDir.up ? -1 : 0;
    final dc = arrow.dir == ArrowDir.right ? 1 : arrow.dir == ArrowDir.left ? -1 : 0;
    var r = arrow.row + dr * arrow.length;
    var c = arrow.col + dc * arrow.length;
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (occupied.contains((r, c))) return false;
      r += dr;
      c += dc;
    }
    return true;
  }

  // ── Tap handling ─────────────────────────────────────────────────────────────
  void onTap(ArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;

    // Must tap in order AND path must be clear
    if (arrow.id != nextSolveId || !canSlide(arrow)) {
      _wrongTap();
      return;
    }

    // Correct tap — play arrow sound, trigger slide animation
    _audio.playArrowSound();
    _animTrigger[arrow.id]!.value++;

    Future.delayed(320.ms, () {
      if (!mounted) return;
      setState(() {
        arrow.solved = true;
        nextSolveId++;
        if (nextSolveId >= arrows.length) triggerVictory();
      });
    });
  }

  void _wrongTap() {
    // Wrong tap plays arrow sound (NOT lose sound — that's only for game over)
    _audio.playArrowSound();
    setState(() {
      lives--;
      if (lives <= 0) triggerGameOver();
    });
  }

  // ── Actions ──────────────────────────────────────────────────────────────────
  void restart() {
    _levelTimer?.cancel();
    setState(() {
      arrows = buildArrowsFn();
      nextSolveId = 0;
      lives = 3;
      secondsLeft = 60;
      gameOver = false;
      victory = false;
      _showSettings = false;
      for (final a in arrows) {
        _animTrigger[a.id]?.value = 0;
      }
    });
    _audio.playGameMusic();
    _startTimer();
  }

  void quit() {
    _levelTimer?.cancel();
    _audio.resumeMenuMusic();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void goNextLevel() {
    _levelTimer?.cancel();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => nextLevelBuilder()));
  }

  void _toggleSettings() {
    setState(() => _showSettings = !_showSettings);
    if (_showSettings) {
      _settingsCtrl.forward();
    } else {
      _settingsCtrl.reverse();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UI BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Top bar (AASP layout) ─────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext ctx, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: 8),
      child: Row(
        children: [
          // Back button
          _iconBtn(
            icon: Icons.arrow_back_ios_new,
            size: size,
            onTap: () async {
              final leave = await showDialog<bool>(
                context: ctx,
                builder: (d) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A2E),
                  title: const Text('Leave Game?',
                      style: TextStyle(color: Colors.white)),
                  content: const Text('Your progress in this level will be lost.',
                      style: TextStyle(color: Colors.white70)),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('Stay',
                            style: TextStyle(color: Colors.cyan))),
                    TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text('Leave',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (leave == true && ctx.mounted) quit();
            },
          ),
          // Center — level label + difficulty badge + heart icons
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL $levelNumber',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _diffColor(levelNumber).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: _diffColor(levelNumber), width: 1),
                      ),
                      child: Text(
                        _diffLabel(levelNumber).toUpperCase(),
                        style: TextStyle(
                          color: _diffColor(levelNumber),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final active = i < lives;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        active ? Icons.favorite : Icons.favorite_border,
                        color: active ? Colors.redAccent : Colors.white24,
                        size: 16,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          // Settings button
          _iconBtn(
            icon: Icons.settings_outlined,
            size: size,
            onTap: _toggleSettings,
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(
      {required IconData icon, required Size size, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.width * 0.1,
        height: size.width * 0.1,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10, width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  // ── Timer bar ──────────────────────────────────────────────────────────────
  Widget _buildTimerBar(Size size) {
    final progress = secondsLeft / 60;
    final color = secondsLeft > 20
        ? AppColors.cyan
        : secondsLeft > 10
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.12, vertical: 4),
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0, 1),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4)
            ],
          ),
        ),
      ),
    );
  }

  // ── Settings panel ─────────────────────────────────────────────────────────
  Widget _buildSettingsPanel(Size size) {
    final prov = context.watch<GameProvider>();
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('SETTINGS',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 24),
          _toggleRow(
            label: 'Music',
            icon: Icons.music_note,
            value: prov.isMusicOn,
            onChanged: (v) => prov.toggleMusic(),
          ),
          const SizedBox(height: 16),
          _toggleRow(
            label: 'Sound Effects',
            icon: Icons.volume_up,
            value: prov.isSfxOn,
            onChanged: (v) => prov.toggleSfx(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _actionBtn(
                  label: 'RESTART',
                  color: Colors.white10,
                  onTap: restart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionBtn(
                  label: 'QUIT',
                  color: Colors.redAccent.withValues(alpha: 0.2),
                  textColor: Colors.redAccent,
                  onTap: quit,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _actionBtn(
            label: 'CLOSE',
            color: AppColors.cyan,
            textColor: Colors.black,
            onTap: _toggleSettings,
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(
      {required String label,
      required Color color,
      Color textColor = Colors.white,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: textColor, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _toggleRow(
      {required String label,
      required IconData icon,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    const dur = Duration(milliseconds: 200);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Icon(icon, color: AppColors.cyan, size: 20),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ]),
        GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: dur,
            width: 52,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: value
                  ? AppColors.cyan.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.16),
              border: Border.all(
                  color: value
                      ? AppColors.cyan
                      : Colors.white.withValues(alpha: 0.24),
                  width: 1.5),
            ),
            child: Stack(alignment: Alignment.center, children: [
              AnimatedAlign(
                duration: dur,
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value
                        ? AppColors.cyan
                        : Colors.white.withValues(alpha: 0.78),
                    boxShadow: [
                      BoxShadow(
                          color: value
                              ? AppColors.cyan.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.24),
                          blurRadius: 4)
                    ],
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: dur,
                      child: Text(
                        value ? 'ON' : 'OFF',
                        key: ValueKey(value),
                        style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: value
                                ? Colors.black.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.7)),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────
  Widget _buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    return Center(
      child: Container(
        width: cellSize * cols,
        height: cellSize * rows,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.07), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(children: [
            // Shape cells background
            for (int r = 0; r < rows; r++)
              for (int c = 0; c < cols; c++)
                Positioned(
                  left: c * cellSize,
                  top: r * cellSize,
                  width: cellSize,
                  height: cellSize,
                  child: Container(
                    decoration: BoxDecoration(
                      color: shapeCells.contains((r, c))
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.transparent,
                      border: shapeCells.contains((r, c))
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.07),
                              width: 0.5)
                          : null,
                    ),
                  ),
                ),
            // Arrows
            for (final a in arrows)
              if (!a.solved) _buildArrowWidget(a, cellSize),
          ]),
        ),
      ),
    );
  }

  // ── Arrow widget with smooth slide animation ──────────────────────────────
  Widget _buildArrowWidget(ArrowData arrow, double cellSize) {
    final isHoriz =
        arrow.dir == ArrowDir.left || arrow.dir == ArrowDir.right;
    final w = isHoriz ? cellSize * arrow.length : cellSize;
    final h = isHoriz ? cellSize : cellSize * arrow.length;

    double left = arrow.col * cellSize;
    double top = arrow.row * cellSize;
    if (arrow.dir == ArrowDir.up) top -= (arrow.length - 1) * cellSize;
    if (arrow.dir == ArrowDir.left) left -= (arrow.length - 1) * cellSize;

    // Slide direction — arrow exits in its pointing direction
    final slideX = switch (arrow.dir) {
      ArrowDir.right => 2.0,
      ArrowDir.left => -2.0,
      _ => 0.0,
    };
    final slideY = switch (arrow.dir) {
      ArrowDir.down => 2.0,
      ArrowDir.up => -2.0,
      _ => 0.0,
    };

    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: ValueListenableBuilder<int>(
        valueListenable: _animTrigger[arrow.id]!,
        builder: (_, trigger, child) {
          return GestureDetector(
            onTap: () => onTap(arrow),
            child: trigger == 0
                ? child!
                : child!
                    .animate(key: ValueKey(trigger))
                    .slideX(
                        begin: 0,
                        end: slideX,
                        duration: 300.ms,
                        curve: Curves.easeIn)
                    .slideY(
                        begin: 0,
                        end: slideY,
                        duration: 300.ms,
                        curve: Curves.easeIn)
                    .fade(begin: 1, end: 0, duration: 280.ms),
          );
        },
        child: ArrowWidget(
          dir: arrow.dir,
          length: arrow.length,
          color: arrow.color,
          cellSize: cellSize,
        ),
      ),
    );
  }

  // ── Level scaffold — main build ───────────────────────────────────────────
  Widget buildLevelScaffold({
    required BuildContext context,
    required Set<(int, int)> shapeCells,
    required Widget gameOverWidget,
    required Widget victoryWidget,
  }) {
    final size = MediaQuery.of(context).size;
    // Cell size fits the grid within 92% of screen width
    final cellSize = (size.width * 0.92) / cols;

    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppConstants.background),
            fit: BoxFit.cover,
            opacity: 0.12,
          ),
        ),
        child: SafeArea(
          child: Stack(children: [
            Column(children: [
              _buildTopBar(context, size),
              _buildTimerBar(size),
              const SizedBox(height: 4),
              Text(
                'Level $levelNumber · $shapeName · $rows×$cols',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.42),
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Center(child: _buildGrid(cellSize, shapeCells)),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'TAP ARROWS TO CLEAR THE PATH',
                  style: TextStyle(
                    fontSize: size.width * 0.03,
                    color: Colors.white.withValues(alpha: 0.3),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ]),
            // Settings backdrop
            if (_showSettings) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleSettings,
                  child: FadeTransition(
                    opacity: _settingsFade,
                    child: Container(
                        color: Colors.black.withValues(alpha: 0.45)),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _settingsSlide,
                  child: _buildSettingsPanel(size),
                ),
              ),
            ],
            gameOverWidget,
            victoryWidget,
          ]),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ARROW WIDGET — gradient, glow, rounded body, clean arrowhead
// ═════════════════════════════════════════════════════════════════════════════

class ArrowWidget extends StatelessWidget {
  final ArrowDir dir;
  final int length;
  final Color color;
  final double cellSize;

  const ArrowWidget({
    super.key,
    required this.dir,
    required this.length,
    required this.color,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: ArrowPainter(
            dir: dir, length: length, color: color, cellSize: cellSize),
      );
}

class ArrowPainter extends CustomPainter {
  final ArrowDir dir;
  final int length;
  final Color color;
  final double cellSize;

  const ArrowPainter({
    required this.dir,
    required this.length,
    required this.color,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isHoriz = dir == ArrowDir.left || dir == ArrowDir.right;
    final pad = cellSize * 0.11;
    final radius = Radius.circular(cellSize * 0.32);

    // Body rect
    final Rect bodyRect;
    if (isHoriz) {
      bodyRect = Rect.fromLTRB(
          pad, size.height * 0.22, size.width - pad, size.height * 0.78);
    } else {
      bodyRect = Rect.fromLTRB(
          size.width * 0.22, pad, size.width * 0.78, size.height - pad);
    }
    final rr = RRect.fromRectAndRadius(bodyRect, radius);

    // Gradient
    final gradient = LinearGradient(
      colors: [
        Color.lerp(color, Colors.white, 0.3)!,
        color,
        Color.lerp(color, Colors.black, 0.2)!,
      ],
      begin: isHoriz ? Alignment.topCenter : Alignment.centerLeft,
      end: isHoriz ? Alignment.bottomCenter : Alignment.centerRight,
    );

    // 1. Drop shadow
    canvas.drawRRect(
        rr.shift(const Offset(2.5, 2.5)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));

    // 2. Glow
    canvas.drawRRect(
        rr,
        Paint()
          ..color = color.withValues(alpha: 0.32)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    // 3. Gradient body
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = gradient.createShader(bodyRect)
          ..style = PaintingStyle.fill);

    // 4. Highlight edge
    canvas.drawRRect(
        rr,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2);

    // 5. Arrowhead
    _drawHead(canvas, size, pad);
  }

  void _drawHead(Canvas canvas, Size size, double pad) {
    final isHoriz = dir == ArrowDir.left || dir == ArrowDir.right;
    final hw = cellSize * 0.34;
    final hh = cellSize * 0.42;

    final Offset tip, p1, p2;
    if (isHoriz) {
      final midY = size.height / 2;
      if (dir == ArrowDir.right) {
        tip = Offset(size.width - pad * 0.3, midY);
        p1 = Offset(size.width - pad * 0.3 - hw, midY - hh / 2);
        p2 = Offset(size.width - pad * 0.3 - hw, midY + hh / 2);
      } else {
        tip = Offset(pad * 0.3, midY);
        p1 = Offset(pad * 0.3 + hw, midY - hh / 2);
        p2 = Offset(pad * 0.3 + hw, midY + hh / 2);
      }
    } else {
      final midX = size.width / 2;
      if (dir == ArrowDir.down) {
        tip = Offset(midX, size.height - pad * 0.3);
        p1 = Offset(midX - hh / 2, size.height - pad * 0.3 - hw);
        p2 = Offset(midX + hh / 2, size.height - pad * 0.3 - hw);
      } else {
        tip = Offset(midX, pad * 0.3);
        p1 = Offset(midX - hh / 2, pad * 0.3 + hw);
        p2 = Offset(midX + hh / 2, pad * 0.3 + hw);
      }
    }

    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    final bounds = Rect.fromPoints(p1, p2);
    final headGrad = LinearGradient(
      colors: [Color.lerp(color, Colors.white, 0.5)!, color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Head shadow
    canvas.drawPath(
        headPath.shift(const Offset(2, 2)),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Head fill
    canvas.drawPath(
        headPath,
        Paint()
          ..shader = headGrad.createShader(bounds)
          ..style = PaintingStyle.fill);

    // Head edge
    canvas.drawPath(
        headPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.22)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0);
  }

  @override
  bool shouldRepaint(covariant ArrowPainter old) =>
      old.dir != dir ||
      old.length != length ||
      old.color != color ||
      old.cellSize != cellSize;
}
