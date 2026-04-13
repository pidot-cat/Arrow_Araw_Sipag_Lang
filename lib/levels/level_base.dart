// lib/levels/level_base.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — Core Engine v9  (PRODUCTION FINAL)
//
// PERF-1  RepaintBoundary wraps EACH arrow → only the animating arrow
//         repaints; the static grid never repaints during animation cycles.
// PERF-2  Static dot grid drawn in its own RepaintBoundary (_DotGridPainter)
//         and never rebuilt during animation.
// PERF-3  willChange=false on idle painters; true only on animating arrow
//         to opt it into a dedicated GPU compositing layer.
// PERF-4  shouldRepaint compares segs by value (not just length).
// PERF-5  onGridTap debounced: taps within 16 ms are ignored (1-frame guard)
//         to prevent ghost life deductions from rapid input.
// WIN-1   _victoryTriggered boolean: triggerVictory() + win sound fire
//         exactly ONCE per level regardless of simultaneous callbacks.
// HEAD-1  Arrowhead apex correctly placed at the OUTER EDGE of the head cell.
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

// ── Responsive cellSize ───────────────────────────────────────────────────────
double dynamicCellSize({
  required double screenWidth,
  required int cols,
  required int arrowCount,
}) {
  final maxGridWidth = screenWidth * 0.85;
  return maxGridWidth / cols;
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

  // WIN-1: Ensures win sound + state transition happen exactly once.
  bool _victoryTriggered = false;

  Timer? _levelTimer;
  final Map<int, ValueNotifier<int>> animTrigger = {};
  final AudioService _audio = AudioService();
  final Set<int> _pendingSolve = {};

  // PERF-5: Rapid-tap debounce timestamp.
  DateTime? _lastTapTime;

  void initLevelState() {
    _victoryTriggered = false;
    _audio.resetWinSoundGuard(); // WIN-DEBOUNCE: fresh guard for this level
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

  // WIN-1: _victoryTriggered guard — idempotent.
  void triggerVictory() {
    if (_victoryTriggered) return;
    _victoryTriggered = true;
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

  BentCell _headSeg(BentArrowData arrow) {
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
    final tipSeg = _headSeg(tappedArrow);
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

  // PERF-5: Ignore taps within one frame of the previous tap.
  bool _debounceCheck() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < const Duration(milliseconds: 16)) {
      return false;
    }
    _lastTapTime = now;
    return true;
  }

  void onGridTap(Offset localPos, double cellSize) {
    if (gameOver || victory) return;
    if (!_debounceCheck()) return; // PERF-5
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
    if (!_debounceCheck()) return; // PERF-5
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
    _victoryTriggered = false;
    _lastTapTime = null;
    _audio.resetWinSoundGuard(); // WIN-DEBOUNCE: reset for new attempt
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

  // PERF-1+2: Dot grid in its own RepaintBoundary. Each arrow in its own
  // RepaintBoundary. Background never repaints during arrow animations.
  Widget buildGrid(double cellSize, Set<(int, int)> shapeCells) {
    final occupiedCells = <(int, int)>{};
    for (final a in arrows) {
      if (!a.solved) {
        for (final cell in a.cells) { occupiedCells.add(cell); }
      }
    }

    final dotRadius = (cellSize * 0.07).clamp(1.5, 4.0);
    final gridSide  = cellSize * math.max(rows, cols);

    return Center(
      child: GestureDetector(
        onTapDown: (d) => onGridTap(d.localPosition, cellSize),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width:  gridSide,
          height: gridSide,
          child: Stack(children: [
            // PERF-2: Static dot layer — isolated in RepaintBoundary.
            RepaintBoundary(
              child: CustomPaint(
                size: Size(gridSide, gridSide),
                painter: _DotGridPainter(
                  occupiedCells: Set.unmodifiable(occupiedCells),
                  cellSize: cellSize,
                  dotRadius: dotRadius,
                ),
                isComplex: false,
                willChange: false,
              ),
            ),
            // PERF-1: Each arrow in its own RepaintBoundary.
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
        // PERF-3: willChange only true while animating.
        final painter = CustomPaint(
          size: Size(cellSize * math.max(rows, cols),
                     cellSize * math.max(rows, cols)),
          painter: StraightArrowPainter(
            segs: arrow.segs, escape: arrow.escape,
            color: arrow.color, cellSize: cellSize,
          ),
          isComplex: true,
          willChange: val > 0,
        );

        // PERF-1: Each arrow RepaintBoundary = GPU compositing layer.
        final bounded = RepaintBoundary(child: painter);

        if (val == 0) return bounded;

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
        ], child: bounded);
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

// ── _DotGridPainter ───────────────────────────────────────────────────────────
// PERF-2: Dedicated static painter for the dot grid background layer.

class _DotGridPainter extends CustomPainter {
  final Set<(int, int)> occupiedCells;
  final double cellSize;
  final double dotRadius;

  const _DotGridPainter({
    required this.occupiedCells,
    required this.cellSize,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (final cell in occupiedCells) {
      final cx = cell.$2 * cellSize + cellSize / 2;
      final cy = cell.$1 * cellSize + cellSize / 2;
      canvas.drawCircle(Offset(cx, cy), dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) =>
      old.cellSize != cellSize ||
      old.dotRadius != dotRadius ||
      old.occupiedCells.length != occupiedCells.length;
}

// ── StraightArrowPainter ──────────────────────────────────────────────────────
// HEAD-1: Apex locked to outer edge of head cell.
// PERF-4: shouldRepaint compares segs by value.

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

  // HEAD-1: Tip = outer edge boundary of head cell.
  Offset _outerEdgeTip(BentCell headSeg) {
    final cx = headSeg.col * cellSize;
    final cy = headSeg.row * cellSize;
    return switch (escape) {
      ArrowDir.up    => Offset(cx + cellSize / 2, cy),
      ArrowDir.down  => Offset(cx + cellSize / 2, cy + cellSize),
      ArrowDir.left  => Offset(cx,                cy + cellSize / 2),
      ArrowDir.right => Offset(cx + cellSize,     cy + cellSize / 2),
    };
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (segs.isEmpty) return;

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
    final tip  = _outerEdgeTip(headSeg);

    final shaft = Path()..moveTo(tail.dx, tail.dy)..lineTo(tip.dx, tip.dy);

    // Glow layer.
    canvas.drawPath(shaft, Paint()
      ..color       = color.withAlpha(55)
      ..strokeWidth = 7.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..isAntiAlias = true
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 4.0));

    // Crisp shaft.
    canvas.drawPath(shaft, Paint()
      ..color       = color
      ..strokeWidth = 3.5
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..isAntiAlias = true);

    _drawHead(canvas, tip, color);
  }

  void _drawHead(Canvas canvas, Offset tip, Color col) {
    final (dx, dy) = switch (escape) {
      ArrowDir.up    => (0.0, -1.0),
      ArrowDir.down  => (0.0,  1.0),
      ArrowDir.left  => (-1.0, 0.0),
      ArrowDir.right => ( 1.0, 0.0),
    };
    final angle = math.atan2(dy, dx);

    // Wing length scaled to cell, clamped for dense grids.
    final len  = (cellSize * 0.55).clamp(6.0, 20.0);
    const wing = 0.48;

    final headPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(tip.dx + math.cos(angle + math.pi - wing) * len,
               tip.dy + math.sin(angle + math.pi - wing) * len)
      ..lineTo(tip.dx + math.cos(angle + math.pi + wing) * len,
               tip.dy + math.sin(angle + math.pi + wing) * len)
      ..close();

    canvas.drawPath(headPath, Paint()
      ..color       = col.withAlpha(65)
      ..style       = PaintingStyle.fill
      ..isAntiAlias = true
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 3.0));

    canvas.drawPath(headPath, Paint()
      ..color       = col
      ..style       = PaintingStyle.fill
      ..isAntiAlias = true);
  }

  @override
  bool hitTest(Offset position) => false;

  // PERF-4: Value-based seg comparison.
  @override
  bool shouldRepaint(covariant StraightArrowPainter old) {
    if (old.color != color || old.escape != escape ||
        old.cellSize != cellSize || old.segs.length != segs.length) {
      return true;
    }
    for (int i = 0; i < segs.length; i++) {
      if (segs[i] != old.segs[i]) return true;
    }
    return false;
  }
}

typedef BentArrowPainter = StraightArrowPainter;
