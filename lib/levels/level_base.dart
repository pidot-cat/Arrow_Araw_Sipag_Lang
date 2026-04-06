// lib/levels/level_base.dart
// Shared model, painter, state mixin, and widgets used by every level screen.
// Arrow style: line/stroke with arrowhead.
// Animation: smooth slide-out on correct tap, shake on blocked tap.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

enum ArrowDir { up, down, left, right }

// ── Arrow Data ────────────────────────────────────────────────────────────────
// For ALL directions, (row, col) is always the TOP-LEFT corner of the bounding box.
// cells() expands from that corner based on direction.
class ArrowData {
  final int id;
  final int row, col;
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

  // All grid cells this arrow occupies (row, col pairs).
  List<(int, int)> get cells => List.generate(length, (i) {
        switch (dir) {
          case ArrowDir.right: return (row, col + i);
          case ArrowDir.left:  return (row, col - i);
          case ArrowDir.down:  return (row + i, col);
          case ArrowDir.up:    return (row - i, col);
        }
      });

  // The first cell in the direction of travel (leading edge).
  // This is the cell just BEYOND the arrow's last occupied cell.
  (int, int) get leadingEdge {
    switch (dir) {
      case ArrowDir.right: return (row, col + length);
      case ArrowDir.left:  return (row, col - length);
      case ArrowDir.down:  return (row + length, col);
      case ArrowDir.up:    return (row - length, col);
    }
  }
}

// ── Arrow Painter (Line/Stroke Style) ─────────────────────────────────────────
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
    final strokeW = (cellSize * 0.13).clamp(2.5, 6.0);

    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW + 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _buildPath(size, strokeW);
    canvas.save();
    canvas.translate(2, 2);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size s, double sw) {
    final path = Path();
    final pad = sw * 0.8;
    final headLen = (cellSize * 0.30).clamp(8.0, 22.0);
    final headWing = (cellSize * 0.20).clamp(5.0, 15.0);

    switch (dir) {
      case ArrowDir.right:
        final y = s.height / 2;
        path.moveTo(pad, y);
        path.lineTo(s.width - pad, y);
        path.moveTo(s.width - pad, y);
        path.lineTo(s.width - pad - headLen, y - headWing);
        path.moveTo(s.width - pad, y);
        path.lineTo(s.width - pad - headLen, y + headWing);

      case ArrowDir.left:
        final y = s.height / 2;
        path.moveTo(s.width - pad, y);
        path.lineTo(pad, y);
        path.moveTo(pad, y);
        path.lineTo(pad + headLen, y - headWing);
        path.moveTo(pad, y);
        path.lineTo(pad + headLen, y + headWing);

      case ArrowDir.down:
        final x = s.width / 2;
        path.moveTo(x, pad);
        path.lineTo(x, s.height - pad);
        path.moveTo(x, s.height - pad);
        path.lineTo(x - headWing, s.height - pad - headLen);
        path.moveTo(x, s.height - pad);
        path.lineTo(x + headWing, s.height - pad - headLen);

      case ArrowDir.up:
        final x = s.width / 2;
        path.moveTo(x, s.height - pad);
        path.lineTo(x, pad);
        path.moveTo(x, pad);
        path.lineTo(x - headWing, pad + headLen);
        path.moveTo(x, pad);
        path.lineTo(x + headWing, pad + headLen);
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant ArrowPainter old) =>
      old.color != color || old.dir != dir || old.length != length;
}

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
          dir: dir, length: length, color: color, cellSize: cellSize));
}

// ── Animated Arrow Widget ─────────────────────────────────────────────────────
class AnimatedArrowWidget extends StatefulWidget {
  final ArrowData arrow;
  final double cellSize;
  final VoidCallback onTap;

  const AnimatedArrowWidget({
    super.key,
    required this.arrow,
    required this.cellSize,
    required this.onTap,
  });

  @override
  State<AnimatedArrowWidget> createState() => AnimatedArrowWidgetState();
}

class AnimatedArrowWidgetState extends State<AnimatedArrowWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  Animation<Offset> _slideAnim = const AlwaysStoppedAnimation(Offset.zero);
  Animation<double> _fadeAnim = const AlwaysStoppedAnimation(1.0);
  Animation<double> _shakeAnim = const AlwaysStoppedAnimation(0.0);

  bool _sliding = false;
  bool _shaking = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void triggerSlide(ArrowDir dir, VoidCallback onDone) {
    if (_sliding) return;
    _sliding = true;
    _shaking = false;
    _ctrl.duration = const Duration(milliseconds: 300);

    final Offset slideEnd = switch (dir) {
      ArrowDir.right => const Offset(4.0, 0),
      ArrowDir.left  => const Offset(-4.0, 0),
      ArrowDir.down  => const Offset(0, 4.0),
      ArrowDir.up    => const Offset(0, -4.0),
    };

    _slideAnim = Tween<Offset>(begin: Offset.zero, end: slideEnd).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));

    _shakeAnim = const AlwaysStoppedAnimation(0.0);
    setState(() {});
    _ctrl.forward(from: 0).then((_) => onDone());
  }

  void triggerShake() {
    if (_sliding || _shaking) return;
    _shaking = true;
    _ctrl.duration = const Duration(milliseconds: 400);
    _slideAnim = const AlwaysStoppedAnimation(Offset.zero);
    _fadeAnim = const AlwaysStoppedAnimation(1.0);

    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end:  8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin:-8.0, end:  8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin:-4.0, end:  0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    setState(() {});
    _ctrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _shaking = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        Widget w = child!;
        if (_shaking) {
          w = Transform.translate(
              offset: Offset(_shakeAnim.value, 0), child: w);
        }
        if (_sliding) {
          w = FractionalTranslation(
            translation: _slideAnim.value,
            child: Opacity(
                opacity: _fadeAnim.value.clamp(0.0, 1.0), child: w),
          );
        }
        return GestureDetector(onTap: widget.onTap, child: w);
      },
      child: ArrowWidget(
        dir: widget.arrow.dir,
        length: widget.arrow.length,
        color: widget.arrow.color,
        cellSize: widget.cellSize,
      ),
    );
  }
}

// ── Level State Mixin ─────────────────────────────────────────────────────────
mixin LevelStateMixin<T extends StatefulWidget> on State<T> {
  late List<ArrowData> arrows;
  int lives = 3;
  int secondsLeft = 60;
  bool gameOver = false;
  bool victory = false;
  bool _levelEnded = false;
  Timer? _levelTimer;

  final Map<int, GlobalKey<AnimatedArrowWidgetState>> _arrowKeys = {};
  final AudioService _audio = AudioService();

  int get levelNumber;
  int get rows;
  int get cols;
  List<ArrowData> Function() get buildArrowsFn;
  Widget Function() get nextLevelBuilder;

  void initLevelState() {
    arrows = buildArrowsFn();
    _rebuildKeys();
    _audio.playGameMusic();
    _startTimer();
  }

  void _rebuildKeys() {
    _arrowKeys.clear();
    for (final a in arrows) {
      _arrowKeys[a.id] = GlobalKey<AnimatedArrowWidgetState>();
    }
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _levelEnded = false;
    _levelTimer?.cancel();
    _levelTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _levelEnded) return;
      setState(() {
        secondsLeft--;
        if (secondsLeft <= 0) {
          secondsLeft = 0;
          _doGameOver();
        }
      });
    });
  }

  void _doGameOver() {
    if (_levelEnded) return;
    _levelEnded = true;
    _levelTimer?.cancel();
    _audio.playLoseSound();        // sound ONLY on actual game over
    setState(() => gameOver = true);
  }

  void triggerGameOver() => _doGameOver();

  void triggerVictory() {
    if (_levelEnded) return;
    _levelEnded = true;
    _levelTimer?.cancel();
    _audio.playWinSound();         // sound ONLY on actual victory
    setState(() => victory = true);
    if (mounted) {
      context.read<GameProvider>().recordLevelComplete(
            level: levelNumber,
            time: 60 - secondsLeft,
            lives: lives,
          );
    }
  }

  // ── canSlide ────────────────────────────────────────────────────────────────
  // An arrow can slide out if every cell from its leading edge to the grid
  // boundary (in its direction of travel) is unoccupied by other unsolved arrows.
  bool canSlide(ArrowData arrow) {
    // Build set of all cells occupied by OTHER unsolved arrows.
    final occupied = <(int, int)>{};
    for (final a in arrows) {
      if (a.id != arrow.id && !a.solved) {
        occupied.addAll(a.cells);
      }
    }

    // Direction deltas.
    final int dr = switch (arrow.dir) {
      ArrowDir.down  =>  1,
      ArrowDir.up    => -1,
      _              =>  0,
    };
    final int dc = switch (arrow.dir) {
      ArrowDir.right =>  1,
      ArrowDir.left  => -1,
      _              =>  0,
    };

    // Start from the leading edge (first cell beyond the arrow's body).
    var (int r, int c) = arrow.leadingEdge;

    // Walk toward the grid boundary — any blocked cell means can't slide.
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (occupied.contains((r, c))) return false;
      r += dr;
      c += dc;
    }
    return true;
  }

  // ── onTap ───────────────────────────────────────────────────────────────────
  void onTap(ArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;

    if (!canSlide(arrow)) {
      // Wrong tap: shake the arrow, deduct a life, and pause game music briefly.
      _audio.onArrowTap();
      _arrowKeys[arrow.id]?.currentState?.triggerShake();
      setState(() {
        lives--;
        if (lives <= 0) {
          lives = 0;
          // Short delay so shake animation is visible before game over screen.
          Future.delayed(const Duration(milliseconds: 420), _doGameOver);
        }
      });
      return;
    }

    // Correct tap: play sound then slide the arrow out.
    _audio.playArrowSound();
    _arrowKeys[arrow.id]?.currentState?.triggerSlide(arrow.dir, () {
      if (!mounted) return;
      setState(() {
        arrow.solved = true;
        if (arrows.every((a) => a.solved)) triggerVictory();
      });
    });
  }

  // ── restart / quit / next ───────────────────────────────────────────────────
  void restart() {
    _levelTimer?.cancel();
    _levelEnded = false;
    setState(() {
      arrows = buildArrowsFn();
      _rebuildKeys();
      lives = 3;
      secondsLeft = 60;
      gameOver = false;
      victory = false;
    });
    _audio.playGameMusic();
    _startTimer();
  }

  void quit() {
    _levelEnded = true;
    _levelTimer?.cancel();
    _audio.resumeMenuMusic();
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void goNextLevel() {
    _levelEnded = true;
    _levelTimer?.cancel();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => nextLevelBuilder()));
  }

  // ── HUD ─────────────────────────────────────────────────────────────────────
  Widget buildHUD() {
    final timerColor = secondsLeft <= 10 ? Colors.redAccent : AppColors.cyan;
    final progress = secondsLeft / 60.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: Back | Level Title + Badge | Settings
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: quit,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
                ),
              ),
              // Level + difficulty badge (centered)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LEVEL $levelNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withAlpha(40),
                        border: Border.all(color: AppColors.cyan, width: 1.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        levelDifficulty,
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Settings button
              GestureDetector(
                onTap: openSettings,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.settings, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),

        // Row 2: Hearts (centered)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = i < lives;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(
                active ? AppConstants.heartRed : AppConstants.heartBlack,
                width: 30,
                height: 30,
                errorBuilder: (_, __, ___) => Icon(
                  active ? Icons.favorite : Icons.favorite_border,
                  color: active ? Colors.redAccent : Colors.grey,
                  size: 28,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Row 3: Timer text (centered)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_rounded, color: timerColor, size: 18),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: timerColor,
                fontSize: secondsLeft <= 10 ? 22 : 18,
                fontWeight: FontWeight.bold,
              ),
              child: Text('${secondsLeft}s'),
            ),
          ],
        ),

        const SizedBox(height: 6),

        // Row 4: Timer progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Background track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  // Foreground fill
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 6,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: timerColor,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: timerColor.withAlpha(120),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 4),
      ],
    );
  }

  // Override these in each level for custom difficulty label and settings
  String get levelDifficulty => 'Easy';
  void openSettings() {
    // Navigate to settings screen
    Navigator.pushNamed(context, '/settings');
  }

  // ── Grid ─────────────────────────────────────────────────────────────────────
  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    return Center(
      child: SizedBox(
        width: cellSize * cols,
        height: cellSize * rows,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Shape background tiles.
            for (int r = 0; r < rows; r++)
              for (int c = 0; c < cols; c++)
                if (shapeCells.contains((r, c)))
                  Positioned(
                    left: c * cellSize,
                    top: r * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkNavy.withAlpha(153),
                        border: Border.all(color: Colors.white12, width: 0.5),
                      ),
                    ),
                  ),
            // Arrow widgets.
            for (final a in arrows)
              if (!a.solved) _buildArrowPositioned(a, cellSize),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowPositioned(ArrowData arrow, double cellSize) {
    final isHoriz = arrow.dir == ArrowDir.left || arrow.dir == ArrowDir.right;
    final double w = isHoriz ? cellSize * arrow.length : cellSize;
    final double h = isHoriz ? cellSize : cellSize * arrow.length;

    // (row, col) is always the anchor. For left/up arrows the body extends
    // backwards, so we adjust the Positioned top/left accordingly.
    double left = arrow.col * cellSize;
    double top  = arrow.row * cellSize;

    // Left arrows: col is the rightmost cell, body extends left.
    if (arrow.dir == ArrowDir.left) left -= (arrow.length - 1) * cellSize;
    // Up arrows: row is the bottommost cell, body extends up.
    if (arrow.dir == ArrowDir.up)   top  -= (arrow.length - 1) * cellSize;

    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: AnimatedArrowWidget(
        key: _arrowKeys[arrow.id],
        arrow: arrow,
        cellSize: cellSize,
        onTap: () => onTap(arrow),
      ),
    );
  }
}
