// lib/levels/level_base.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — Core Engine v3 (Zero-Overlap / Perfect-Square)
//
// ARCHITECTURE:
//   • BentArrowData  — immutable data model (segments, escape dir, colour)
//   • BentLevelStateMixin — all game state, timer, tap logic, HUD builder
//   • BentArrowPainter — two-pass neon renderer (blur halo + crisp line)
//   • _GlassIconButton — programmatic glassmorphism back / settings button
//
// ASSET USAGE:
//   backgrounds  → assets/images/background.jpg       (per-level Scaffold bg)
//   hearts live  → assets/images/heart icon Red.png
//   hearts lost  → assets/images/heart icon Black.png
//   victory      → assets/images/Victory.png          (rendered by overlay)
//   game over    → assets/images/Game Over.png         (rendered by overlay)
//
// AUDIO ROUTING (via AudioService singleton):
//   • playGameMusic()   — starts Ingame-Music.mp3, no-op if already playing
//   • playArrowSound()  — on each valid tap
//   • playWrongSound()  — on blocked tap
//   • playWinSound()    — ONLY when victory overlay mounts
//   • playGameOverSound() — ONLY when game-over overlay mounts
//   • resumeMenuMusic() — on quit / back to lobby
//
// ANIMATION:
//   • easeOutCubic 400 ms slide to escape edge + fade from 180 ms
//   • Future.delayed(420 ms) marks arrow solved AFTER animation
//
// COLLISION (ray-cast):
//   • Checks every grid cell along escape ray to screen boundary
//   • Considers all unsolved arrows' full segment lists
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/level_unlock_service.dart';
import '../utils/app_colors.dart';
import '../screens/settings_screen.dart';

// ── Direction enum ────────────────────────────────────────────────────────────

enum ArrowDir { up, down, left, right }

// ── Segment / Arrow data models ───────────────────────────────────────────────

class BentCell {
  final int row, col;
  const BentCell(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is BentCell && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}

class BentArrowData {
  final int id;
  final List<BentCell> segs;
  final ArrowDir escape;
  final Color color;
  bool solved;

  BentArrowData({
    required this.id,
    required this.segs,
    required this.escape,
    required this.color,
    this.solved = false,
  });

  List<(int, int)> get cells => segs.map((c) => (c.row, c.col)).toList();
}

// ── BentLevelStateMixin ───────────────────────────────────────────────────────

mixin BentLevelStateMixin<T extends StatefulWidget> on State<T> {
  // ── Sub-class contracts ──
  int get levelNumber;
  int get rows;
  int get cols;
  List<BentArrowData> Function() get buildArrowsFn;
  Widget Function() get nextLevelBuilder;

  // ── State ─────────────────────────────────────────────────────────────────
  late List<BentArrowData> arrows;
  int lives = 3;
  int secondsLeft = 60;
  bool gameOver = false;
  bool victory = false;
  Timer? _levelTimer;
  final Map<int, ValueNotifier<int>> animTrigger = {};
  final AudioService _audio = AudioService();

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  void initLevelState() {
    arrows = buildArrowsFn();
    for (final a in arrows) {
      animTrigger[a.id] = ValueNotifier(0);
    }
    _audio.playGameMusic();
    _startTimer();
  }

  @override
  void dispose() {
    _levelTimer?.cancel();
    for (final v in animTrigger.values) v.dispose();
    super.dispose();
  }

  // ── Timer ─────────────────────────────────────────────────────────────────

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

  // ── Game state transitions ────────────────────────────────────────────────

  void triggerGameOver() {
    _levelTimer?.cancel();
    setState(() => gameOver = true);
    _audio.playGameOverSound(); // triggers ONLY when overlay shown
    if (mounted) context.read<GameProvider>().recordLevelLoss();
  }

  void triggerVictory() {
    _levelTimer?.cancel();
    setState(() => victory = true);
    _audio.playWinSound(); // triggers ONLY when overlay shown
    if (mounted) {
      context.read<GameProvider>().recordLevelComplete(
            level: levelNumber,
            time: 60 - secondsLeft,
            lives: lives,
          );
    }
    if (levelNumber >= 10) {
      LevelUnlockService.instance.unlockAll();
    } else {
      LevelUnlockService.instance.unlockLevel(levelNumber + 1);
    }
  }

  // ── Collision — full ray-cast to screen edge ──────────────────────────────

  bool isPathClear(BentArrowData tappedArrow) {
    // Build occupied set from all OTHER unsolved arrows
    final occupied = <(int, int)>{};
    for (final a in arrows) {
      if (a.id != tappedArrow.id && !a.solved) {
        for (final cell in a.cells) occupied.add(cell);
      }
    }

    final head = tappedArrow.segs.last;
    final (dr, dc) = switch (tappedArrow.escape) {
      ArrowDir.up    => (-1, 0),
      ArrowDir.down  => (1, 0),
      ArrowDir.left  => (0, -1),
      ArrowDir.right => (0, 1),
    };

    var r = head.row + dr;
    var c = head.col + dc;
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (occupied.contains((r, c))) return false;
      r += dr;
      c += dc;
    }
    return true;
  }

  // ── Tap handling ──────────────────────────────────────────────────────────

  void onTap(BentArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;

    if (!isPathClear(arrow)) {
      wrongTap();
      return;
    }

    _audio.playArrowSound();
    animTrigger[arrow.id]!.value++;

    // Mark solved AFTER the 400 ms easeOutCubic animation completes
    Future.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        arrow.solved = true;
        if (arrows.every((a) => a.solved)) triggerVictory();
      });
    });
  }

  void wrongTap() {
    _audio.playWrongSound();
    setState(() {
      lives--;
      if (lives <= 0) triggerGameOver();
    });
  }

  // ── Navigation helpers ────────────────────────────────────────────────────

  void restart() {
    _levelTimer?.cancel();
    setState(() {
      arrows = buildArrowsFn();
      lives = 3;
      secondsLeft = 60;
      gameOver = false;
      victory = false;
      for (final a in arrows) animTrigger[a.id]?.value = 0;
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

  void _openSettings() {
    _levelTimer?.cancel();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    ).then((_) {
      if (!gameOver && !victory && mounted) _startTimer();
    });
  }

  // ── HUD ───────────────────────────────────────────────────────────────────
  //
  // Layout:
  //   [ ← glass ]  Level N    ♥♥♥   60s   [ ⚙ glass ]
  //   ━━━━━━━━━━━━━━━ neon progress bar ━━━━━━━━━━━━━━━

  Widget buildHUD() {
    final progress = secondsLeft / 60.0;
    final isUrgent = secondsLeft <= 10;
    final timerColor = isUrgent ? Colors.redAccent : Colors.cyanAccent;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withAlpha(15),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // ── Back button (programmatic glassmorphism) ─────────────────
              _GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                onTap: quit,
              ),
              const SizedBox(width: 8),

              // ── Level label ───────────────────────────────────────────────
              Text(
                'Level $levelNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 8)],
                ),
              ),

              const Spacer(),

              // ── Heart lives — uses asset images ───────────────────────────
              Row(
                children: List.generate(3, (i) {
                  final alive = i < lives;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Image.asset(
                      alive
                          ? 'assets/images/heart icon Red.png'
                          : 'assets/images/heart icon Black.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (_, __, ___) => Icon(
                        alive ? Icons.favorite : Icons.favorite_border,
                        color: alive ? Colors.redAccent : Colors.white24,
                        size: 20,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(width: 10),

              // ── Timer (pulses red when ≤ 10 s) ───────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: timerColor,
                  fontSize: isUrgent ? 22 : 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: timerColor, blurRadius: 10)],
                ),
                child: Text('${secondsLeft}s'),
              ),
              const SizedBox(width: 8),

              // ── Settings button (programmatic glassmorphism) ──────────────
              _GlassIconButton(
                icon: Icons.settings_rounded,
                color: Colors.white60,
                onTap: _openSettings,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Progress bar ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Grid ──────────────────────────────────────────────────────────────────

  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    return Center(
      child: SizedBox(
        width: cellSize * cols,
        height: cellSize * rows,
        child: Stack(
          children: [
            // Background dot-grid
            for (int r = 0; r < rows; r++)
              for (int c = 0; c < cols; c++)
                Positioned(
                  left: c * cellSize + cellSize / 2 - 1.5,
                  top: r * cellSize + cellSize / 2 - 1.5,
                  child: Container(
                    width: 3,
                    height: 3,
                    decoration: const BoxDecoration(
                      color: Colors.white12,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            // Arrows
            for (final a in arrows)
              if (!a.solved) buildArrow(a, cellSize),
          ],
        ),
      ),
    );
  }

  // ── Arrow widget (with Smooth-Out animation) ──────────────────────────────

  Widget buildArrow(BentArrowData arrow, double cellSize) {
    return ValueListenableBuilder<int>(
      valueListenable: animTrigger[arrow.id]!,
      builder: (context, val, _) {
        final painter = CustomPaint(
          size: Size(cellSize * cols, cellSize * rows),
          painter: BentArrowPainter(
            segs: arrow.segs,
            escape: arrow.escape,
            color: arrow.color,
            cellSize: cellSize,
          ),
        );

        if (val == 0) {
          return GestureDetector(onTap: () => onTap(arrow), child: painter);
        }

        // Smooth-Out: easeOutCubic 400 ms slide off-screen in escape direction
        final dist = math.max(rows, cols) * cellSize;
        final (dx, dy) = switch (arrow.escape) {
          ArrowDir.up    => (0.0, -dist),
          ArrowDir.down  => (0.0,  dist),
          ArrowDir.left  => (-dist, 0.0),
          ArrowDir.right => (dist,  0.0),
        };

        return Animate(
          effects: [
            MoveEffect(
              begin: Offset.zero,
              end: Offset(dx, dy),
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
            FadeEffect(
              begin: 1.0,
              end: 0.0,
              delay: 180.ms,
              duration: 220.ms,
              curve: Curves.easeOut,
            ),
          ],
          child: painter,
        );
      },
    );
  }
}

// ── _GlassIconButton ──────────────────────────────────────────────────────────
//
// Programmatic glassmorphism: BackdropFilter blur + semi-transparent fill +
// subtle neon border.  No image assets required.

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.cyanAccent.withAlpha(55),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withAlpha(20),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

// ── BentArrowPainter ──────────────────────────────────────────────────────────
//
// Two-pass neon renderer:
//   Pass 1 — wide blurred stroke → glowing halo
//   Pass 2 — crisp 3.5 px solid stroke → clean arrow body
//   Arrow head — same two-pass approach (fill glow + solid fill)
//   Corners — quadratic Bézier curves at each direction change

class BentArrowPainter extends CustomPainter {
  final List<BentCell> segs;
  final ArrowDir escape;
  final Color color;
  final double cellSize;

  const BentArrowPainter({
    required this.segs,
    required this.escape,
    required this.color,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segs.isEmpty) return;

    // Convert grid coords → pixel centres
    final pts = segs
        .map((c) => Offset(
              c.col * cellSize + cellSize / 2,
              c.row * cellSize + cellSize / 2,
            ))
        .toList();

    final head = pts.last;
    final (dr, dc) = switch (escape) {
      ArrowDir.up    => (-1.0, 0.0),
      ArrowDir.down  => ( 1.0, 0.0),
      ArrowDir.left  => (0.0, -1.0),
      ArrowDir.right => (0.0,  1.0),
    };

    // Tip extends 42 % of a cell beyond the last segment centre
    final tip = head + Offset(dc, dr) * (cellSize * 0.42);

    // ── Build path with Bézier-rounded corners ──────────────────────────────
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);

    for (int i = 1; i < pts.length; i++) {
      if (i < pts.length - 1) {
        final p0 = pts[i - 1];
        final p1 = pts[i];
        final p2 = pts[i + 1];

        final v1 = p1 - p0;
        final d1 = v1.distance;
        final n1 = d1 > 0 ? v1 / d1 : v1;

        final v2 = p2 - p1;
        final d2 = v2.distance;
        final n2 = d2 > 0 ? v2 / d2 : v2;

        // Corner inset = 22 % of cell size
        final cs = cellSize * 0.22;
        final sc = p1 - n1 * math.min(cs, d1 / 2);
        final ec = p1 + n2 * math.min(cs, d2 / 2);

        path
          ..lineTo(sc.dx, sc.dy)
          ..quadraticBezierTo(p1.dx, p1.dy, ec.dx, ec.dy);
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    path.lineTo(tip.dx, tip.dy);

    // ── Pass 1: neon glow halo ───────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withAlpha(90)
        ..strokeWidth = 11.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );

    // ── Pass 2: crisp solid line ─────────────────────────────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    _drawHead(canvas, head, tip, color);
  }

  void _drawHead(Canvas canvas, Offset base, Offset tip, Color col) {
    final angle = math.atan2((tip - base).dy, (tip - base).dx);
    final len = cellSize * 0.28;

    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx + math.cos(angle + math.pi - 0.48) * len,
        tip.dy + math.sin(angle + math.pi - 0.48) * len,
      )
      ..lineTo(
        tip.dx + math.cos(angle + math.pi + 0.48) * len,
        tip.dy + math.sin(angle + math.pi + 0.48) * len,
      )
      ..close();

    // Glow pass
    canvas.drawPath(
      headPath,
      Paint()
        ..color = col.withAlpha(130)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Solid fill
    canvas.drawPath(
      headPath,
      Paint()
        ..color = col
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant BentArrowPainter old) =>
      old.color != color ||
      old.escape != escape ||
      old.cellSize != cellSize ||
      old.segs.length != segs.length;
}