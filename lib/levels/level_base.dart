// lib/levels/level_base.dart
// ─────────────────────────────────────────────────────────────────────────────
// Shared model, painter, and helpers used by every level screen.
// Supports bent (multi-segment polyline) arrows via BentArrowData +
// BentArrowPainter, in addition to the legacy straight ArrowData.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../utils/app_colors.dart';

// ── Direction enum ────────────────────────────────────────────────────────────
enum ArrowDir { up, down, left, right }

// ─────────────────────────────────────────────────────────────────────────────
// LEGACY straight-line ArrowData (kept for backward compatibility)
// ─────────────────────────────────────────────────────────────────────────────

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

  List<(int, int)> get cells => List.generate(length, (i) {
        final r = row +
            (dir == ArrowDir.down
                ? i
                : dir == ArrowDir.up
                    ? -i
                    : 0);
        final c = col +
            (dir == ArrowDir.right
                ? i
                : dir == ArrowDir.left
                    ? -i
                    : 0);
        return (r, c);
      });
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW bent-arrow data model
// ─────────────────────────────────────────────────────────────────────────────

/// A single grid cell in a bent arrow's path.
class BentCell {
  final int row, col;
  const BentCell(this.row, this.col);
}

/// Arrow that follows an arbitrary polyline through grid cells.
/// [segs] = ordered list of cells the arrow passes through (head = last cell).
/// [escape] = direction the arrowhead points out of the grid / shape.
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
// BentLevelStateMixin — replaces LevelStateMixin for bent-arrow levels
// ─────────────────────────────────────────────────────────────────────────────

mixin BentLevelStateMixin<T extends StatefulWidget> on State<T> {
  late List<BentArrowData> arrows;
  int nextSolveId = 0;
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
    _audio.playLoseSound();
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

  /// Checks whether arrow can slide out in its escape direction without
  /// being blocked by any unsolved arrow.
  bool canSlide(BentArrowData arrow) {
    final occupied = <(int, int)>{};
    for (final a in arrows) {
      if (a.id != arrow.id && !a.solved) {
        for (final cell in a.cells) {
          occupied.add(cell);
        }
      }
    }
    final head = arrow.segs.last;
    final (dr, dc) = switch (arrow.escape) {
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
    if (arrow.id != nextSolveId || !canSlide(arrow)) {
      wrongTap();
      return;
    }
    _audio.playArrowSound();
    animTrigger[arrow.id]!.value++;
    Future.delayed(350.ms, () {
      if (!mounted) return;
      setState(() {
        arrow.solved = true;
        nextSolveId++;
        if (nextSolveId >= arrows.length) triggerVictory();
      });
    });
  }

  void wrongTap() {
    _audio.playLoseSound();
    setState(() {
      lives--;
      if (lives <= 0) triggerGameOver();
    });
  }

  void restart() {
    _levelTimer?.cancel();
    setState(() {
      arrows = buildArrowsFn();
      nextSolveId = 0;
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

  Widget buildHUD() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
              children: List.generate(
                  3,
                  (i) => Icon(
                      i < lives ? Icons.favorite : Icons.favorite_border,
                      color: i < lives ? Colors.redAccent : Colors.grey,
                      size: 26))),
          Row(children: [
            Icon(Icons.timer,
                color: secondsLeft <= 10 ? Colors.redAccent : Colors.cyan,
                size: 20),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                  color: secondsLeft <= 10 ? Colors.redAccent : Colors.white,
                  fontSize: secondsLeft <= 10 ? 26 : 22,
                  fontWeight: FontWeight.bold),
              child: Text('${secondsLeft}s'),
            ),
          ]),
        ]),
      );

  // ── Grid + Arrows ────────────────────────────────────────────────────────────

  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    // Only show cell backgrounds on cells that currently have an unsolved arrow
    final activeCells = <(int, int)>{};
    for (final a in arrows) {
      if (!a.solved) {
        for (final cell in a.cells) {
          activeCells.add(cell);
        }
      }
    }
    return Center(
        child: SizedBox(
            width: cellSize * cols,
            height: cellSize * rows,
            child: Stack(children: [
              // Shape background — only on cells with active arrows
              for (final cell in activeCells)
                Positioned(
                    left: cell.$2 * cellSize,
                    top: cell.$1 * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: Container(
                        decoration: BoxDecoration(
                      color: AppColors.darkNavy.withValues(alpha: 0.6),
                      border: Border.all(color: Colors.white12, width: 0.5),
                    ))),
              // Bent arrows
              for (final a in arrows)
                if (!a.solved) _buildBentArrow(a, cellSize),
            ])));
  }

  Widget _buildBentArrow(BentArrowData arrow, double cellSize) {
    if (arrow.segs.isEmpty) return const SizedBox.shrink();

    // Bounding box of all cells
    int minR = arrow.segs[0].row, maxR = arrow.segs[0].row;
    int minC = arrow.segs[0].col, maxC = arrow.segs[0].col;
    for (final s in arrow.segs) {
      if (s.row < minR) minR = s.row;
      if (s.row > maxR) maxR = s.row;
      if (s.col < minC) minC = s.col;
      if (s.col > maxC) maxC = s.col;
    }

    final left = minC * cellSize;
    final top = minR * cellSize;
    final w = (maxC - minC + 1) * cellSize;
    final h = (maxR - minR + 1) * cellSize;

    // Slide offset for exit animation
    final (dx, dy) = switch (arrow.escape) {
      ArrowDir.right => (1.5, 0.0),
      ArrowDir.left => (-1.5, 0.0),
      ArrowDir.down => (0.0, 1.5),
      ArrowDir.up => (0.0, -1.5),
    };
    final isHoriz = arrow.escape == ArrowDir.left || arrow.escape == ArrowDir.right;

    return Positioned(
        left: left,
        top: top,
        width: w,
        height: h,
        child: ValueListenableBuilder<int>(
          valueListenable: animTrigger[arrow.id]!,
          builder: (_, trigger, child) => GestureDetector(
              onTap: () => onTap(arrow),
              child: trigger == 0
                  ? child!
                  : child!
                      .animate(key: ValueKey(trigger))
                      .slideX(
                          begin: 0,
                          end: isHoriz ? dx : 0,
                          duration: 300.ms,
                          curve: Curves.easeIn)
                      .slideY(
                          begin: 0,
                          end: !isHoriz ? dy : 0,
                          duration: 300.ms,
                          curve: Curves.easeIn)
                      .fadeOut(
                          begin: 1, duration: 300.ms, curve: Curves.easeIn)),
          child: BentArrowWidget(
              arrow: arrow,
              originRow: minR,
              originCol: minC,
              color: arrow.color,
              cellSize: cellSize),
        ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BentArrowWidget + BentArrowPainter
// ─────────────────────────────────────────────────────────────────────────────

class BentArrowWidget extends StatelessWidget {
  final BentArrowData arrow;
  final int originRow, originCol;
  final Color color;
  final double cellSize;

  const BentArrowWidget({
    super.key,
    required this.arrow,
    required this.originRow,
    required this.originCol,
    required this.color,
    required this.cellSize,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: BentArrowPainter(
          arrow: arrow,
          originRow: originRow,
          originCol: originCol,
          color: color,
          cellSize: cellSize));
}

class BentArrowPainter extends CustomPainter {
  final BentArrowData arrow;
  final int originRow, originCol;
  final Color color;
  final double cellSize;

  const BentArrowPainter({
    required this.arrow,
    required this.originRow,
    required this.originCol,
    required this.color,
    required this.cellSize,
  });

  // Centre of a cell relative to bounding-box origin
  Offset _centre(BentCell cell) {
    final dx = (cell.col - originCol + 0.5) * cellSize;
    final dy = (cell.row - originRow + 0.5) * cellSize;
    return Offset(dx, dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (arrow.segs.isEmpty) return;

    final shaft = cellSize * 0.20;
    final headLen = cellSize * 0.45;
    final headWidth = cellSize * 0.38;

    // Build polyline centres
    final pts = arrow.segs.map(_centre).toList();

    // Extend last point in escape direction for arrowhead
    final (edx, edy) = switch (arrow.escape) {
      ArrowDir.right => (1.0, 0.0),
      ArrowDir.left => (-1.0, 0.0),
      ArrowDir.down => (0.0, 1.0),
      ArrowDir.up => (0.0, -1.0),
    };
    final tip = pts.last + Offset(edx, edy) * (cellSize * 0.5);

    // ── Draw shadow ──────────────────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black45
      ..style = PaintingStyle.stroke
      ..strokeWidth = shaft * 2 + 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawPolyline(canvas, pts, shadowPaint, const Offset(2, 2));

    // ── Draw shaft ───────────────────────────────────────────────────────────
    final shaftPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = shaft * 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    _drawPolyline(canvas, pts, shaftPaint, Offset.zero);

    // ── Draw shaft border ────────────────────────────────────────────────────
    // Border paint omitted — shadow covers it; kept as reference below if needed:
    // Paint()..color = Colors.white30..style = PaintingStyle.stroke
    //   ..strokeWidth = shaft * 2 + 2..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;

    // ── Draw arrowhead ───────────────────────────────────────────────────────
    _drawHead(canvas, pts.last, tip, headLen, headWidth, color);
  }

  void _drawPolyline(Canvas canvas, List<Offset> pts, Paint paint, Offset offset) {
    if (pts.length < 2) return; // nothing to draw for single-point (no tail dot)
    final path = Path()..moveTo(pts[0].dx + offset.dx, pts[0].dy + offset.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      // If both row and col differ, draw L-bend (horizontal then vertical)
      // to avoid diagonal lines — use midpoint column as corner
      final dx = curr.dx - prev.dx;
      final dy = curr.dy - prev.dy;
      if (dx.abs() > 1 && dy.abs() > 1) {
        // L-bend: go horizontal first, then vertical
        path.lineTo(curr.dx + offset.dx, prev.dy + offset.dy);
      }
      path.lineTo(curr.dx + offset.dx, curr.dy + offset.dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawHead(Canvas canvas, Offset base, Offset tip, double len, double width, Color color) {
    final dir = (tip - base);
    final angle = math.atan2(dir.dy, dir.dx);
    final perp = angle + math.pi / 2;

    final left = tip +
        Offset(math.cos(angle + math.pi), math.sin(angle + math.pi)) * len +
        Offset(math.cos(perp), math.sin(perp)) * (width / 2);
    final right = tip +
        Offset(math.cos(angle + math.pi), math.sin(angle + math.pi)) * len -
        Offset(math.cos(perp), math.sin(perp)) * (width / 2);

    // Shadow
    final shadowPath = Path()
      ..moveTo(tip.dx + 2, tip.dy + 2)
      ..lineTo(left.dx + 2, left.dy + 2)
      ..lineTo(right.dx + 2, right.dy + 2)
      ..close();
    canvas.drawPath(shadowPath, Paint()..color = Colors.black45);

    // Fill
    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(headPath, Paint()..color = color);
    canvas.drawPath(
        headPath,
        Paint()
          ..color = Colors.white30
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Legacy LevelStateMixin (kept for any screens still using straight ArrowData)
// ─────────────────────────────────────────────────────────────────────────────

mixin LevelStateMixin<T extends StatefulWidget> on State<T> {
  late List<ArrowData> arrows;
  int nextSolveId = 0;
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
  List<ArrowData> Function() get buildArrowsFn;
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
    _audio.playLoseSound();
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

  void onTap(ArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;
    if (arrow.id != nextSolveId || !canSlide(arrow)) {
      wrongTap();
      return;
    }
    _audio.playArrowSound();
    animTrigger[arrow.id]!.value++;
    Future.delayed(350.ms, () {
      if (!mounted) return;
      setState(() {
        arrow.solved = true;
        nextSolveId++;
        if (nextSolveId >= arrows.length) triggerVictory();
      });
    });
  }

  void wrongTap() {
    _audio.playLoseSound();
    setState(() {
      lives--;
      if (lives <= 0) triggerGameOver();
    });
  }

  void restart() {
    _levelTimer?.cancel();
    setState(() {
      arrows = buildArrowsFn();
      nextSolveId = 0;
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

  Widget buildHUD() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
              children: List.generate(
                  3,
                  (i) => Icon(
                      i < lives ? Icons.favorite : Icons.favorite_border,
                      color: i < lives ? Colors.redAccent : Colors.grey,
                      size: 26))),
          Row(children: [
            Icon(Icons.timer,
                color: secondsLeft <= 10 ? Colors.redAccent : Colors.cyan,
                size: 20),
            const SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                  color: secondsLeft <= 10 ? Colors.redAccent : Colors.white,
                  fontSize: secondsLeft <= 10 ? 26 : 22,
                  fontWeight: FontWeight.bold),
              child: Text('${secondsLeft}s'),
            ),
          ]),
        ]),
      );

  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    // Only show cell backgrounds on cells with an unsolved arrow
    final activeCells = <(int, int)>{};
    for (final a in arrows) {
      if (!a.solved) {
        for (final cell in a.cells) {
          activeCells.add(cell);
        }
      }
    }
    return Center(
        child: SizedBox(
            width: cellSize * cols,
            height: cellSize * rows,
            child: Stack(children: [
              for (final cell in activeCells)
                Positioned(
                    left: cell.$2 * cellSize,
                    top: cell.$1 * cellSize,
                    width: cellSize,
                    height: cellSize,
                    child: Container(
                        decoration: BoxDecoration(
                      color: AppColors.darkNavy.withValues(alpha: 0.6),
                      border: Border.all(color: Colors.white12, width: 0.5),
                    ))),
              for (final a in arrows)
                if (!a.solved) buildArrow(a, cellSize),
            ])));
  }

  Widget buildArrow(ArrowData arrow, double cellSize) {
    final isHoriz = arrow.dir == ArrowDir.left || arrow.dir == ArrowDir.right;
    final w = isHoriz ? cellSize * arrow.length : cellSize;
    final h = isHoriz ? cellSize : cellSize * arrow.length;
    double left = arrow.col * cellSize;
    double top = arrow.row * cellSize;
    if (arrow.dir == ArrowDir.up) top -= (arrow.length - 1) * cellSize;
    if (arrow.dir == ArrowDir.left) left -= (arrow.length - 1) * cellSize;
    final so = switch (arrow.dir) {
      ArrowDir.right => const Offset(1.5, 0),
      ArrowDir.left => const Offset(-1.5, 0),
      ArrowDir.up => const Offset(0, -1.5),
      ArrowDir.down => const Offset(0, 1.5),
    };
    return Positioned(
        left: left,
        top: top,
        width: w,
        height: h,
        child: ValueListenableBuilder<int>(
          valueListenable: animTrigger[arrow.id]!,
          builder: (_, trigger, child) => GestureDetector(
              onTap: () => onTap(arrow),
              child: trigger == 0
                  ? child!
                  : child!
                      .animate(key: ValueKey(trigger))
                      .slideX(
                          begin: 0,
                          end: isHoriz ? so.dx : 0,
                          duration: 300.ms,
                          curve: Curves.easeIn)
                      .slideY(
                          begin: 0,
                          end: !isHoriz ? so.dy : 0,
                          duration: 300.ms,
                          curve: Curves.easeIn)
                      .fadeOut(
                          begin: 1, duration: 300.ms, curve: Curves.easeIn)),
          child: ArrowWidget(
              dir: arrow.dir,
              length: arrow.length,
              color: arrow.color,
              cellSize: cellSize),
        ));
  }
}

// ── Legacy straight ArrowWidget + Painter ────────────────────────────────────

class ArrowWidget extends StatelessWidget {
  final ArrowDir dir;
  final int length;
  final Color color;
  final double cellSize;
  const ArrowWidget(
      {super.key,
      required this.dir,
      required this.length,
      required this.color,
      required this.cellSize});

  @override
  Widget build(BuildContext context) => CustomPaint(
      painter: ArrowPainter(
          dir: dir, length: length, color: color, cellSize: cellSize));
}

class ArrowPainter extends CustomPainter {
  final ArrowDir dir;
  final int length;
  final Color color;
  final double cellSize;

  const ArrowPainter(
      {required this.dir,
      required this.length,
      required this.color,
      required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final pad = cellSize * 0.15;
    final shaft = cellSize * 0.22;
    final head = cellSize * 0.36;
    final path = _buildPath(size, pad, shaft, head);
    canvas.drawPath(
        path.shift(const Offset(2, 2)), Paint()..color = Colors.black38);
    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  Path _buildPath(Size s, double pad, double shaft, double head) {
    final path = Path();
    final isHoriz = dir == ArrowDir.left || dir == ArrowDir.right;
    if (isHoriz) {
      final midY = s.height / 2;
      final flip = dir == ArrowDir.left;
      final start = flip ? s.width - pad : pad;
      final end = flip ? pad : s.width - pad;
      final headEnd = flip ? head + pad : s.width - head - pad;
      path.moveTo(start, midY - shaft);
      path.lineTo(headEnd, midY - shaft);
      path.lineTo(headEnd, midY - head);
      path.lineTo(end, midY);
      path.lineTo(headEnd, midY + head);
      path.lineTo(headEnd, midY + shaft);
      path.lineTo(start, midY + shaft);
    } else {
      final midX = s.width / 2;
      final flip = dir == ArrowDir.up;
      final start = flip ? s.height - pad : pad;
      final end = flip ? pad : s.height - pad;
      final headEnd = flip ? head + pad : s.height - head - pad;
      path.moveTo(midX - shaft, start);
      path.lineTo(midX - shaft, headEnd);
      path.lineTo(midX - head, headEnd);
      path.lineTo(midX, end);
      path.lineTo(midX + head, headEnd);
      path.lineTo(midX + shaft, headEnd);
      path.lineTo(midX + shaft, start);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
