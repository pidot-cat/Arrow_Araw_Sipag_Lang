// lib/levels/level_base.dart
// ─────────────────────────────────────────────────────────────────────────────
// Shared model, painter, and helpers used by every level screen.
// Supports sleek polyline arrows via BentArrowData + BentArrowPainter.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/level_unlock_service.dart';
import '../utils/app_colors.dart';

// ── Direction enum ────────────────────────────────────────────────────────────
enum ArrowDir { up, down, left, right }

// ─────────────────────────────────────────────────────────────────────────────
// Bent-arrow data model
// ─────────────────────────────────────────────────────────────────────────────

class BentCell {
  final int row, col;
  const BentCell(this.row, this.col);
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

// ─────────────────────────────────────────────────────────────────────────────
// BentLevelStateMixin — free-flow spatial collision logic
// ─────────────────────────────────────────────────────────────────────────────

mixin BentLevelStateMixin<T extends StatefulWidget> on State<T> {
  late List<BentArrowData> arrows;
  int lives = 3;
  int secondsLeft = 60;
  bool gameOver = false;
  bool victory = false;
  Timer? _levelTimer;
  final Map<int, ValueNotifier<int>> animTrigger = {};

  final AudioService _audio = AudioService();

  int get levelNumber;
  int get rows;
  int get cols;
  List<BentArrowData> Function() get buildArrowsFn;
  Widget Function() get nextLevelBuilder;

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

  void triggerGameOver() {
    _levelTimer?.cancel();
    _audio.playGameOverSound();
    setState(() => gameOver = true);
    if (mounted) {
      context.read<GameProvider>().recordLevelLoss();
    }
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
    if (levelNumber >= 10) {
      LevelUnlockService.instance.unlockAll();
    } else {
      LevelUnlockService.instance.unlockLevel(levelNumber + 1);
    }
  }

  /// Checks if the path is clear for the tapped arrow.
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

  void onTap(BentArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;
    
    if (!isPathClear(arrow)) {
      wrongTap();
      return;
    }

    _audio.playArrowSound();
    animTrigger[arrow.id]!.value++;
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        arrow.solved = true;
        if (arrows.every((a) => a.solved)) {
          triggerVictory();
        }
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

  // ── HUD ─────────────────────────────────────────────────────────────────────

  Widget buildHUD() {
    final progress = secondsLeft / 60.0;
    final timerColor = secondsLeft <= 10 ? Colors.redAccent : Colors.cyanAccent;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 20),
                onPressed: quit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 6),
              Text(
                'Level $levelNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      i < lives ? Icons.favorite : Icons.favorite_border,
                      color: i < lives ? Colors.redAccent : Colors.grey,
                      size: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ── Grid + Arrows ────────────────────────────────────────────────────────────

  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    return Center(
      child: SizedBox(
        width: cellSize * cols,
        height: cellSize * rows,
        child: Stack(
          children: [
            // Grid dots (optional, for visual reference)
            for (int r = 0; r < rows; r++)
              for (int c = 0; c < cols; c++)
                Positioned(
                  left: c * cellSize + cellSize / 2 - 1,
                  top: r * cellSize + cellSize / 2 - 1,
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: Colors.white10,
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

  Widget buildArrow(BentArrowData arrow, double cellSize) {
    return ValueListenableBuilder<int>(
      valueListenable: animTrigger[arrow.id]!,
      builder: (context, val, child) {
        if (val == 0) {
          return GestureDetector(
            onTap: () => onTap(arrow),
            child: CustomPaint(
              size: Size(cellSize * cols, cellSize * rows),
              painter: BentArrowPainter(
                segs: arrow.segs,
                escape: arrow.escape,
                color: arrow.color,
                cellSize: cellSize,
              ),
            ),
          );
        }
        // Slide-off animation
        final (dr, dc) = switch (arrow.escape) {
          ArrowDir.up => (0.0, -1.0),
          ArrowDir.down => (0.0, 1.0),
          ArrowDir.left => (-1.0, 0.0),
          ArrowDir.right => (1.0, 0.0),
        };
        return Animate(
          effects: [
            MoveEffect(
              begin: Offset.zero,
              end: Offset(dc * cellSize * math.max(rows, cols), dr * cellSize * math.max(rows, cols)),
              duration: 300.ms,
              curve: Curves.easeIn,
            ),
          ],
          child: CustomPaint(
            size: Size(cellSize * cols, cellSize * rows),
            painter: BentArrowPainter(
              segs: arrow.segs,
              escape: arrow.escape,
              color: arrow.color,
              cellSize: cellSize,
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BentArrowPainter — Sleek Polyline Specs
// ─────────────────────────────────────────────────────────────────────────────

class BentArrowPainter extends CustomPainter {
  final List<BentCell> segs;
  final ArrowDir escape;
  final Color color;
  final double cellSize;

  BentArrowPainter({
    required this.segs,
    required this.escape,
    required this.color,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segs.isEmpty) return;

    final List<Offset> pts = segs.map((c) => Offset(
      c.col * cellSize + cellSize / 2,
      c.row * cellSize + cellSize / 2,
    )).toList();

    final head = pts.last;
    final (dr, dc) = switch (escape) {
      ArrowDir.up => (-1.0, 0.0),
      ArrowDir.down => (1.0, 0.0),
      ArrowDir.left => (0.0, -1.0),
      ArrowDir.right => (0.0, 1.0),
    };
    
    // Tip extends slightly towards the escape direction
    final tip = head + Offset(dc, dr) * (cellSize * 0.4);

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(pts[0].dx, pts[0].dy);

    // Draw smooth bends using quadratic beziers
    for (int i = 1; i < pts.length; i++) {
      if (i < pts.length - 1) {
        // Smooth corner
        final p1 = pts[i];
        final p2 = pts[i + 1];
        
        // Calculate control points for a small curve at the corner
        final mid1 = Offset((pts[i-1].dx + p1.dx) / 2, (pts[i-1].dy + p1.dy) / 2);
        final mid2 = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);
        
        // We use a simpler approach for grid-based polylines:
        // Move towards the corner, then curve to the next segment.
        // To keep it clean, we'll just use lineTo for now but ensure StrokeJoin.round handles the visual.
        // For "flowing bends", we can interpolate:
        final cornerSize = cellSize * 0.2;
        
        // Vector from prev to current
        final v1 = p1 - pts[i-1];
        final d1 = v1.distance;
        final n1 = v1 / d1;
        
        // Vector from current to next
        final v2 = p2 - p1;
        final d2 = v2.distance;
        final n2 = v2 / d2;
        
        final startCurve = p1 - n1 * math.min(cornerSize, d1 / 2);
        final endCurve = p1 + n2 * math.min(cornerSize, d2 / 2);
        
        path.lineTo(startCurve.dx, startCurve.dy);
        path.quadraticBezierTo(p1.dx, p1.dy, endCurve.dx, endCurve.dy);
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    
    // Connect to the tip
    path.lineTo(tip.dx, tip.dy);
    canvas.drawPath(path, paint);

    // Draw sleek arrowhead
    _drawSleekHead(canvas, head, tip, color);
  }

  void _drawSleekHead(Canvas canvas, Offset base, Offset tip, Color color) {
    final dir = tip - base;
    final angle = math.atan2(dir.dy, dir.dx);
    final headLen = cellSize * 0.25;
    final headWidth = cellSize * 0.25;

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    
    final angle1 = angle + math.pi - 0.5;
    final angle2 = angle + math.pi + 0.5;
    
    path.lineTo(
      tip.dx + math.cos(angle1) * headLen,
      tip.dy + math.sin(angle1) * headLen,
    );
    path.lineTo(
      tip.dx + math.cos(angle2) * headLen,
      tip.dy + math.sin(angle2) * headLen,
    );
    path.close();

    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
