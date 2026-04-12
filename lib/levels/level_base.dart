// lib/levels/level_base.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — Core Engine v7  (PRODUCTION FINAL – DEBUGGED)
//
// [FIX 1] STRAIGHT ARROWS ONLY — StraightArrowPainter, no bends/L-shapes.
// [FIX 2] DEBOUNCING — _pendingSolve prevents rapid-tap life loss.
// [FIX 3] 350 ms + Curves.easeOutCubic animation.
// [FIX 4] Back button → LevelSelectScreen (not Home).
// [FIX 5] Idle music resume after 2 s of inactivity.
// [FIX 6] Clean closed-triangle arrowhead — zero artifacts.
// [FIX 7] DYNAMIC CELL SCALING v2:
//           availableSpace = screenWidth * 0.85  (safe margin)
//           Levels 1-6: cellSize = availableSpace / SMALL_DIVISOR → max size
//           Levels 7-10: cellSize = availableSpace / actual cols  → dense
// [FIX 8] SELECTIVE DOTS — dots rendered ONLY under occupied arrow cells.
// [FIX 9] ARROWHEAD TIP — locked to leading edge based on escapeDirection.
// [FIX 10] PREMIUM STROKE — doubled strokeWidth + doubled headSize for bold,
//           clearly visible arrows even at high grid densities.
// [FIX 11] ENFORCED SQUARE SILHOUETTE — grid container always N×N so the
//           result is always a Solid Square, never a rectangle.
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
import '../screens/level_select_screen.dart';

// ── Direction enum ────────────────────────────────────────────────────────────

enum ArrowDir { up, down, left, right }

// ── Data models ───────────────────────────────────────────────────────────────

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
    final extra = cellSize * 0.42;
    return Rect.fromLTRB(
      minX - (escape == ArrowDir.left ? extra : 0),
      minY - (escape == ArrowDir.up ? extra : 0),
      maxX + (escape == ArrowDir.right ? extra : 0),
      maxY + (escape == ArrowDir.down ? extra : 0),
    );
  }
}

// ── [FIX 7] Dynamic cellSize calculator v2 ───────────────────────────────────
// Formula: availableSpace = screenWidth * 0.85
//          cellSize       = availableSpace / effectiveDivisor
//
// Levels 1-6 (≤ 60 arrows): use a SMALLER effective divisor than the real
//   grid cols → cells are LARGER → arrows are bold and professional.
// Levels 7-10 (> 60 arrows): use the real cols so the grid still fits.
//
// The grid is ALWAYS square (rows == cols enforced in level_manager.dart),
// so this produces a strict N×N silhouette on every level.
double dynamicCellSize({
  required double screenWidth,
  required int cols,
  required int arrowCount,
}) {
  // [FIX 7] Safe margin: 85 % of screen width
  final availableSpace = screenWidth * 0.85;

  // Effective divisor: smaller divisor → larger cells
  final int effectiveDivisor;
  if (arrowCount <= 10) {
    effectiveDivisor = 5;       // Level 1: very large, premium arrows
  } else if (arrowCount <= 20) {
    effectiveDivisor = 6;       // Level 2
  } else if (arrowCount <= 30) {
    effectiveDivisor = 7;       // Level 3
  } else if (arrowCount <= 40) {
    effectiveDivisor = 8;       // Level 4
  } else if (arrowCount <= 50) {
    effectiveDivisor = 9;       // Level 5
  } else if (arrowCount <= 60) {
    effectiveDivisor = 10;      // Level 6
  } else {
    effectiveDivisor = cols;    // Levels 7-10: dense, full grid
  }

  return availableSpace / effectiveDivisor;
}

// ── BentLevelStateMixin ───────────────────────────────────────────────────────

mixin BentLevelStateMixin<T extends StatefulWidget> on State<T> {
  int get levelNumber;
  int get rows;
  int get cols;
  int get arrowCount;
  List<BentArrowData> Function() get buildArrowsFn;
  Widget Function() get nextLevelBuilder;

  late List<BentArrowData> arrows;
  int lives = 3;
  int secondsLeft = 60;
  bool gameOver = false;
  bool victory = false;
  Timer? _levelTimer;
  final Map<int, ValueNotifier<int>> animTrigger = {};
  final AudioService _audio = AudioService();

  final Set<int> _pendingSolve = {};

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
    _audio.cancelIdleTimer();
    for (final v in animTrigger.values) { v.dispose(); }
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
    _audio.cancelIdleTimer();
    setState(() => gameOver = true);
    _audio.playGameOverSound();
    if (mounted) context.read<GameProvider>().recordLevelLoss();
  }

  void triggerVictory() {
    _levelTimer?.cancel();
    _audio.cancelIdleTimer();
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

  // [FIX 9] Returns the tip segment based on escape direction
  BentCell _tipSegment(BentArrowData arrow) {
    switch (arrow.escape) {
      case ArrowDir.left:
      case ArrowDir.up:
        return arrow.segs.first;
      case ArrowDir.right:
      case ArrowDir.down:
        return arrow.segs.last;
    }
  }

  bool isPathClear(BentArrowData tappedArrow) {
    final occupied = <(int, int)>{};
    for (final a in arrows) {
      if (a.id != tappedArrow.id && !a.solved) {
        for (final cell in a.cells) { occupied.add(cell); }
      }
    }
    final tipSeg = _tipSegment(tappedArrow);
    final (dr, dc) = switch (tappedArrow.escape) {
      ArrowDir.up    => (-1, 0),
      ArrowDir.down  => (1,  0),
      ArrowDir.left  => (0, -1),
      ArrowDir.right => (0,  1),
    };
    var r = tipSeg.row + dr;
    var c = tipSeg.col + dc;
    while (r >= 0 && r < rows && c >= 0 && c < cols) {
      if (occupied.contains((r, c))) return false;
      r += dr; c += dc;
    }
    return true;
  }

  BentArrowData? _findTappedArrow(Offset localPos, double cellSize) {
    for (int i = arrows.length - 1; i >= 0; i--) {
      final a = arrows[i];
      if (a.solved) continue;
      if (_pendingSolve.contains(a.id)) continue;
      if (a.hitRect(cellSize).contains(localPos)) return a;
    }
    return null;
  }

  void onGridTap(Offset localPos, double cellSize) {
    if (gameOver || victory) return;
    _audio.startIdleResumeTimer();

    final arrow = _findTappedArrow(localPos, cellSize);
    if (arrow == null) return;

    if (!isPathClear(arrow)) { wrongTap(); return; }

    _audio.playArrowSound();
    _pendingSolve.add(arrow.id);
    arrow.solved = true;
    animTrigger[arrow.id]!.value++;

    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      _pendingSolve.remove(arrow.id);
      setState(() { if (arrows.every((a) => a.solved)) triggerVictory(); });
    });
  }

  void onTap(BentArrowData arrow) {
    if (gameOver || victory || arrow.solved) return;
    if (_pendingSolve.contains(arrow.id)) return;
    _audio.startIdleResumeTimer();
    if (!isPathClear(arrow)) { wrongTap(); return; }
    _audio.playArrowSound();
    _pendingSolve.add(arrow.id);
    arrow.solved = true;
    animTrigger[arrow.id]!.value++;
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      _pendingSolve.remove(arrow.id);
      setState(() { if (arrows.every((a) => a.solved)) triggerVictory(); });
    });
  }

  void wrongTap() {
    _audio.playWrongSound();
    _audio.startIdleResumeTimer();
    setState(() { lives--; if (lives <= 0) triggerGameOver(); });
  }

  void restart() {
    _levelTimer?.cancel();
    _audio.cancelIdleTimer();
    _pendingSolve.clear();
    setState(() {
      arrows = buildArrowsFn();
      lives = 3; secondsLeft = 60; gameOver = false; victory = false;
      for (final a in arrows) { animTrigger[a.id]?.value = 0; }
    });
    _audio.playGameMusic();
    _startTimer();
  }

  void quit() {
    _levelTimer?.cancel();
    _audio.cancelIdleTimer();
    _audio.resumeMenuMusic();
    // [FIX 4 / FIX 3-NAV] pushAndRemoveUntil with isFirst predicate clears
    // the entire stack above the root route so pressing Back on LevelSelect
    // goes directly to Home/Login — no "double-back" bug.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
      (route) => route.isFirst,
    );
  }

  void goNextLevel() {
    _levelTimer?.cancel();
    _audio.cancelIdleTimer();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => nextLevelBuilder()));
  }

  void _openSettings() {
    _levelTimer?.cancel();
    _audio.cancelIdleTimer();
    Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()))
        .then((_) { if (!gameOver && !victory && mounted) _startTimer(); });
  }

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
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withAlpha(15), blurRadius: 14)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          _GlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            color: Colors.white70,
            onTap: quit,
          ),
          const SizedBox(width: 8),
          Text('Level $levelNumber',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold,
                  fontSize: 15, letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.cyanAccent, blurRadius: 8)])),
          const Spacer(),
          Row(children: List.generate(3, (i) {
            final alive = i < lives;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Image.asset(
                alive ? 'assets/images/heart icon Red.png'
                      : 'assets/images/heart icon Black.png',
                width: 24, height: 24,
                errorBuilder: (_, __, ___) => Icon(
                  alive ? Icons.favorite : Icons.favorite_border,
                  color: alive ? Colors.redAccent : Colors.white24, size: 20),
              ),
            );
          })),
          const SizedBox(width: 10),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
                color: timerColor, fontSize: isUrgent ? 22 : 18,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: timerColor, blurRadius: 10)]),
            child: Text('${secondsLeft}s'),
          ),
          const SizedBox(width: 8),
          _GlassIconButton(
              icon: Icons.settings_rounded,
              color: Colors.white60,
              onTap: _openSettings),
        ]),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0), minHeight: 5,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation<Color>(timerColor),
          ),
        ),
      ]),
    );
  }

  // [FIX 7+8+11] buildGrid:
  //   • dots only on occupied cells
  //   • grid SizedBox is ALWAYS cols×cols (square silhouette)
  //   • cellSize passed in from the level screen
  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    final occupiedCells = <(int, int)>{};
    for (final a in arrows) {
      if (!a.solved) {
        for (final cell in a.cells) { occupiedCells.add(cell); }
      }
    }

    final dotRadius = (cellSize * 0.07).clamp(2.0, 4.5);

    // [FIX 11] Enforce square: both dimensions use the SAME cellSize * cols
    // (rows == cols for every level in level_manager.dart, but we clamp here
    //  as a safety net so the grid is never a rectangle.)
    final gridSide = cellSize * math.max(rows, cols);

    return Center(
      child: GestureDetector(
        onTapDown: (d) => onGridTap(d.localPosition, cellSize),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width:  gridSide,  // [FIX 11] always square
          height: gridSide,
          child: Stack(children: [
            for (final cell in occupiedCells)
              Positioned(
                left: cell.$2 * cellSize + cellSize / 2 - dotRadius,
                top:  cell.$1 * cellSize + cellSize / 2 - dotRadius,
                child: Container(
                    width: dotRadius * 2, height: dotRadius * 2,
                    decoration: const BoxDecoration(
                        color: Colors.white24, shape: BoxShape.circle)),
              ),
            for (final a in arrows)
              if (!a.solved || animTrigger[a.id]!.value > 0)
                _buildArrowVisual(a, cellSize),
          ]),
        ),
      ),
    );
  }

  Widget _buildArrowVisual(BentArrowData arrow, double cellSize) {
    return ValueListenableBuilder<int>(
      valueListenable: animTrigger[arrow.id]!,
      builder: (context, val, _) {
        final painter = CustomPaint(
          size: Size(cellSize * math.max(rows, cols),
                     cellSize * math.max(rows, cols)),
          painter: StraightArrowPainter(
            segs: arrow.segs, escape: arrow.escape,
            color: arrow.color, cellSize: cellSize,
          ),
          isComplex: true, willChange: val > 0,
        );
        if (val == 0) return painter;

        final dist = math.max(rows, cols) * cellSize;
        final (dx, dy) = switch (arrow.escape) {
          ArrowDir.up    => (0.0, -dist),
          ArrowDir.down  => (0.0,  dist),
          ArrowDir.left  => (-dist, 0.0),
          ArrowDir.right => ( dist, 0.0),
        };
        return Animate(effects: [
          MoveEffect(
            begin: Offset.zero, end: Offset(dx, dy),
            duration: 350.ms, curve: Curves.easeOutCubic),
          FadeEffect(
            begin: 1.0, end: 0.0,
            delay: 160.ms, duration: 190.ms, curve: Curves.easeOut),
        ], child: painter);
      },
    );
  }

  Widget buildArrow(BentArrowData arrow, double cellSize) =>
      _buildArrowVisual(arrow, cellSize);
}

// ── _GlassIconButton ──────────────────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _GlassIconButton(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.cyanAccent.withAlpha(55)),
              boxShadow: [BoxShadow(color: Colors.cyanAccent.withAlpha(20), blurRadius: 8)],
            ),
            child: Icon(icon, color: color, size: 18),
          ),
        ),
      ),
    );
  }
}

// ── StraightArrowPainter ──────────────────────────────────────────────────────
// [FIX 1]  Straight arrows only.
// [FIX 6]  Closed triangle arrowhead — zero artifacts.
// [FIX 9]  Tip placed at the LEADING end based on escape direction.
// [FIX 10] DOUBLED strokeWidth + DOUBLED headSize → premium, visible arrows.

class StraightArrowPainter extends CustomPainter {
  final List<BentCell> segs;
  final ArrowDir escape;
  final Color color;
  final double cellSize;

  const StraightArrowPainter({
    required this.segs, required this.escape,
    required this.color, required this.cellSize,
  });

  Offset _centre(BentCell c) =>
      Offset(c.col * cellSize + cellSize / 2, c.row * cellSize + cellSize / 2);

  @override
  void paint(Canvas canvas, Size size) {
    if (segs.isEmpty) return;

    // [FIX 9] Leading tip: first seg for LEFT/UP, last seg for RIGHT/DOWN
    final BentCell headSeg;
    final BentCell tailSeg;
    switch (escape) {
      case ArrowDir.left:
      case ArrowDir.up:
        headSeg = segs.first;
        tailSeg = segs.last;
        break;
      case ArrowDir.right:
      case ArrowDir.down:
        headSeg = segs.last;
        tailSeg = segs.first;
        break;
    }

    final tail = _centre(tailSeg);
    final head = _centre(headSeg);

    final (dx, dy) = switch (escape) {
      ArrowDir.up    => (0.0, -1.0),
      ArrowDir.down  => (0.0,  1.0),
      ArrowDir.left  => (-1.0, 0.0),
      ArrowDir.right => ( 1.0, 0.0),
    };

    final tip = head + Offset(dx, dy) * (cellSize * 0.45);
    final shaft = Path()..moveTo(tail.dx, tail.dy)..lineTo(tip.dx, tip.dy);

    // [FIX 10] DOUBLED stroke width for premium look on all screen sizes
    // Old: clamp(2.5, 6.0) → New: clamp(5.0, 12.0)
    final strokeWidth = (cellSize * 0.36).clamp(5.0, 12.0);
    final glowWidth   = strokeWidth * 3.2;

    // Glow pass
    canvas.drawPath(shaft, Paint()
      ..color = color.withAlpha(90)..strokeWidth = glowWidth
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7));

    // Crisp shaft
    canvas.drawPath(shaft, Paint()
      ..color = color..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    _drawHead(canvas, head, tip, color);
  }

  void _drawHead(Canvas canvas, Offset base, Offset tip, Color col) {
    final angle = math.atan2(tip.dy - base.dy, tip.dx - base.dx);
    // [FIX 10] DOUBLED head size for clear visibility
    // Old: clamp(6.0, 20.0) → New: clamp(12.0, 40.0)
    final len = (cellSize * 0.68).clamp(12.0, 40.0);
    const wing = 0.50;

    // [FIX 6] Closed triangle — zero artifacts
    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + math.cos(angle + math.pi - wing) * len,
               tip.dy + math.sin(angle + math.pi - wing) * len)
      ..lineTo(tip.dx + math.cos(angle + math.pi + wing) * len,
               tip.dy + math.sin(angle + math.pi + wing) * len)
      ..close();

    canvas.drawPath(headPath, Paint()
      ..color = col.withAlpha(130)..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    canvas.drawPath(headPath, Paint()
      ..color = col..style = PaintingStyle.fill);
  }

  @override
  bool hitTest(Offset position) => false;

  @override
  bool shouldRepaint(covariant StraightArrowPainter old) =>
      old.color != color || old.escape != escape ||
      old.cellSize != cellSize || old.segs.length != segs.length;
}

typedef BentArrowPainter = StraightArrowPainter;
