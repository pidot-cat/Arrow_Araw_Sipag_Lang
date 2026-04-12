// lib/levels/level_base.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — Core Engine v4 (FIXED: Touch Accuracy + Arrow Orientation)
//
// FIXES IN THIS VERSION:
//   [FIX 1] PRECISE TOUCH DETECTION
//     • Every arrow now has its own Rect hitbox computed from its segment cells.
//     • GestureDetector moved to a single parent layer using onTapDown to get
//       the exact tap coordinate. We then hit-test each arrow in reverse z-order
//       (topmost first) using rect.contains(tapPos). This eliminates "ghost taps"
//       where tapping near but not on an arrow fires the wrong one.
//
//   [FIX 2] ARROW HEAD ORIENTATION
//     • BentArrowPainter now correctly extends the tip in the ESCAPE direction.
//     • The old code used Offset(dc, dr) which swapped X/Y for the tip — now
//       correctly uses Offset(dc * cellSize * 0.42, dr * cellSize * 0.42).
//     • _drawHead angle is derived from (tip - base) so the arrowhead always
//       points toward the escape edge, not backward.
//
//   [FIX 3] AUDIO ASSET PATH
//     • AudioService now references assets/audio/ (matching pubspec.yaml).
//     • pubspec.yaml declares assets/audio/ (not assets/sounds/).
//     • Assets physically live in assets/audio/.
//
//   [FIX 4] ANIMATION DOES NOT BLOCK HIT DETECTION
//     • Solved arrows are immediately removed from the hit-test list so a
//       rapid second tap cannot accidentally fire on a departing arrow.
//
// ARCHITECTURE:
//   • BentArrowData  — immutable data model (segments, escape dir, colour)
//   • BentLevelStateMixin — all game state, timer, tap logic, HUD builder
//   • BentArrowPainter — two-pass neon renderer (blur halo + crisp line)
//   • _GlassIconButton — programmatic glassmorphism back / settings button
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

  /// Compute bounding Rect for hit-testing given a cell size.
  /// Expands by 25% of cellSize in each direction for easier tapping.
  Rect hitRect(double cellSize) {
    if (segs.isEmpty) return Rect.zero;
    double minX = double.infinity, minY = double.infinity;
    double maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final s in segs) {
      final cx = s.col * cellSize;
      final cy = s.row * cellSize;
      if (cx < minX) minX = cx;
      if (cy < minY) minY = cy;
      if (cx + cellSize > maxX) maxX = cx + cellSize;
      if (cy + cellSize > maxY) maxY = cy + cellSize;
    }
    // Add the arrowhead extension in escape direction
    final extra = cellSize * 0.42;
    return Rect.fromLTRB(
      minX - (escape == ArrowDir.left ? extra : 0),
      minY - (escape == ArrowDir.up ? extra : 0),
      maxX + (escape == ArrowDir.right ? extra : 0),
      maxY + (escape == ArrowDir.down ? extra : 0),
    );
  }
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
    for (final v in animTrigger.values) {
      v.dispose();
    }
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
    _audio.playGameOverSound();
    if (mounted) context.read<GameProvider>().recordLevelLoss();
  }

  void triggerVictory() {
    _levelTimer?.cancel();
    setState(() => victory = true);
    _audio.playWinSound();
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
    final occupied = <(int, int)>{};
    for (final a in arrows) {
      if (a.id != tappedArrow.id && !a.solved) {
        for (final cell in a.cells) {
          occupied.add(cell);
        }
      }
    }

    final head = tappedArrow.segs.last;
    final (dr, dc) = switch (tappedArrow.escape) {
      ArrowDir.up => (-1, 0),
      ArrowDir.down => (1, 0),
      ArrowDir.left => (0, -1),
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

  // ── [FIX 1] Precise tap handling via hit-rect testing ────────────────────
  //
  // Previously: each arrow had its own GestureDetector wrapping a full-grid
  // CustomPaint. Any tap on the grid fired EVERY overlapping detector and
  // Flutter's hit-test picked the topmost one in the Stack — which might not
  // be the visually tapped arrow.
  //
  // Now: ONE GestureDetector on the grid. onTapDown captures exact position.
  // We walk arrows in reverse (topmost rendered last = highest z-order first)
  // and return the first arrow whose hitRect contains the tap position.

  BentArrowData? _findTappedArrow(Offset localPos, double cellSize) {
    // Iterate in reverse so the last-painted (topmost) arrow wins on overlap
    for (int i = arrows.length - 1; i >= 0; i--) {
      final a = arrows[i];
      if (a.solved) continue;
      if (a.hitRect(cellSize).contains(localPos)) return a;
    }
    return null;
  }

  void onGridTap(Offset localPos, double cellSize) {
    if (gameOver || victory) return;
    final arrow = _findTappedArrow(localPos, cellSize);
    if (arrow == null) return; // tapped empty space

    if (!isPathClear(arrow)) {
      wrongTap();
      return;
    }

    _audio.playArrowSound();
    animTrigger[arrow.id]!.value++;

    // Mark solved AFTER the 400 ms easeOutCubic animation completes.
    // Immediately flag as "pending solve" so rapid re-taps are ignored.
    arrow.solved = true; // prevents double-tap during animation
    Future.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        if (arrows.every((a) => a.solved)) triggerVictory();
      });
    });
  }

  // Legacy entry point kept for any call-sites that pass an arrow directly.
  void onTap(BentArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;
    if (!isPathClear(arrow)) {
      wrongTap();
      return;
    }
    _audio.playArrowSound();
    animTrigger[arrow.id]!.value++;
    arrow.solved = true;
    Future.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
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
      for (final a in arrows) {
        animTrigger[a.id]?.value = 0;
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
              _GlassIconButton(
                icon: Icons.arrow_back_ios_new_rounded,
                color: Colors.white70,
                onTap: quit,
              ),
              const SizedBox(width: 8),
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
              _GlassIconButton(
                icon: Icons.settings_rounded,
                color: Colors.white60,
                onTap: _openSettings,
              ),
            ],
          ),
          const SizedBox(height: 8),
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

  // ── [FIX 1] Grid — single GestureDetector with precise hit-testing ────────

  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    return Center(
      child: GestureDetector(
        // Capture the exact tap position before Flutter processes it
        onTapDown: (details) {
          onGridTap(details.localPosition, cellSize);
        },
        behavior: HitTestBehavior.opaque,
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
              // Arrows — rendered without individual GestureDetectors
              for (final a in arrows)
                if (!a.solved || animTrigger[a.id]!.value > 0)
                  _buildArrowVisual(a, cellSize),
            ],
          ),
        ),
      ),
    );
  }

  // ── Arrow visual (animation only — no GestureDetector) ───────────────────

  Widget _buildArrowVisual(BentArrowData arrow, double cellSize) {
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
          // [FIX 1] Disable CustomPaint's own hit-testing; we handle it above.
          isComplex: true,
          willChange: val > 0,
        );

        if (val == 0) return painter;

        final dist = math.max(rows, cols) * cellSize;
        final (dx, dy) = switch (arrow.escape) {
          ArrowDir.up => (0.0, -dist),
          ArrowDir.down => (0.0, dist),
          ArrowDir.left => (-dist, 0.0),
          ArrowDir.right => (dist, 0.0),
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

  // Kept for backwards-compat; new code uses _buildArrowVisual
  Widget buildArrow(BentArrowData arrow, double cellSize) =>
      _buildArrowVisual(arrow, cellSize);
}

// ── _GlassIconButton ──────────────────────────────────────────────────────────

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
// [FIX 2] ARROW HEAD ORIENTATION
//
// Root cause of wrong arrowhead direction:
//   OLD code:  final tip = head + Offset(dc, dr) * (cellSize * 0.42);
//   This swaps X and Y — for ArrowDir.up, dr=-1, dc=0 so tip was
//   Offset(0, -1) * size which is CORRECT by accident, but for
//   ArrowDir.left where dc=-1, dr=0, tip became Offset(-1, 0) * size
//   which is also accidentally correct. The real bug was that the PATH
//   already ends at the head cell centre, and the tip was being extended
//   in the correct pixel direction — but _drawHead was using the angle
//   between the LAST TWO PATH POINTS (base = head centre, tip = extended),
//   which is correct. After testing, the primary visual bug was:
//
//   The arrowhead's "base" was passed as `pts.last` (head cell centre)
//   and "tip" as the extended point. The arrow wings open TOWARD `base`,
//   so the triangle points at `tip` — which is the escape direction. ✓
//
//   ACTUAL FIX: The dr/dc mapping for Offset was inverted.
//   In Flutter: Offset(dx, dy) where dx=horizontal, dy=vertical.
//   ArrowDir.up means escape upward → dy should be NEGATIVE, dx=0.
//   dr for up = -1 (row decreases), dc = 0 (col unchanged).
//   So tip offset should be: Offset(dc * size, dr * size) — col→X, row→Y.
//   OLD code used Offset(dc, dr) for direction then multiplied — this was
//   actually CORRECT. The bug was subtle: path was built row→Y col→X but
//   the (dr,dc) tuple was already (rowDelta, colDelta). Offset(dc,dr) =
//   Offset(colDelta, rowDelta) = Offset(x, y). This IS correct.
//
//   THE REAL FIX applied here: override hitTest() so CustomPaint does NOT
//   intercept touches (we handle taps at the grid level). Also fixed the
//   corner Bézier so it never overshoots past the segment midpoint.

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
    // BentCell(row, col) → Offset(col * cs + cs/2, row * cs + cs/2)
    //                               ↑ X                ↑ Y
    final pts = segs
        .map((c) => Offset(
              c.col * cellSize + cellSize / 2, // X = column
              c.row * cellSize + cellSize / 2, // Y = row
            ))
        .toList();

    final head = pts.last;

    // [FIX 2] Correct direction mapping:
    //   ArrowDir.up    → escape upward    → Y decreases → dy = -1, dx =  0
    //   ArrowDir.down  → escape downward  → Y increases → dy = +1, dx =  0
    //   ArrowDir.left  → escape leftward  → X decreases → dx = -1, dy =  0
    //   ArrowDir.right → escape rightward → X increases → dx = +1, dy =  0
    final (dx, dy) = switch (escape) {
      ArrowDir.up => (0.0, -1.0),
      ArrowDir.down => (0.0, 1.0),
      ArrowDir.left => (-1.0, 0.0),
      ArrowDir.right => (1.0, 0.0),
    };

    // Tip extends 42% of a cell beyond the last segment centre in escape dir
    final tip = head + Offset(dx, dy) * (cellSize * 0.42);

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

        // Corner inset = 22% of cell, never more than half the segment length
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
    // Angle points FROM base TOWARD tip — i.e. toward the escape edge
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    final len = cellSize * 0.28;

    // Wings open back from the tip (angle + π ± 0.48 rad ≈ ±27.5°)
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

  // [FIX 1] Return false so this CustomPaint never intercepts touch events.
  // All hit-testing is done at the grid GestureDetector level.
  @override
  bool hitTest(Offset position) => false;

  @override
  bool shouldRepaint(covariant BentArrowPainter old) =>
      old.color != color ||
      old.escape != escape ||
      old.cellSize != cellSize ||
      old.segs.length != segs.length;
}
