// lib/levels/game_screen_lvl_1.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 1 — 5×5 Grid — HEART shape
// 5 bent arrows, tap order 0 → 4 (each arrow's ID equals its tap position).
// The escape direction of arrow N is blocked ONLY by arrows 0..N-1 so the
// sequence is always valid (solvable guarantee).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_2.dart'; // next level navigation target

// ── Grid dimensions ───────────────────────────────────────────────────────────
const int _rows = 5, _cols = 5;

// ── Shape definition — cells that form the Heart outline ──────────────────────
// These cells are only used for the cell-background decoration in buildGrid().
const Set<(int, int)> _shapeCells = {
  (0,1),(0,2),(0,3),
  (1,0),(1,1),(1,3),(1,4),
  (2,0),(2,4),
  (3,1),(3,3),
  (4,2),
};

// ── Arrow definitions — each BentArrowData is one puzzle piece ────────────────
// • id     : tap order (0 = first, N-1 = last)
// • segs   : ordered grid cells the body occupies (tail first, head last)
// • escape : direction the arrowhead points off the grid / out of the shape
// • color  : visual colour for this arrow
//
// Solvability rule: arrow[id=0] can always escape freely; arrow[id=N] only
// becomes clear after arrows 0..N-1 are removed.
List<BentArrowData> _buildArrows() => [
  // Arrow 0 — red L-bend, exits right
  BentArrowData(
    id: 0,
    segs: [BentCell(2,0), BentCell(1,0)],
    escape: ArrowDir.up,
    color: AppColors.arrowRed,
  ),
  // Arrow 1 — orange, exits right after 0 clears col 4
  BentArrowData(
    id: 1,
    segs: [BentCell(2,4), BentCell(1,4)],
    escape: ArrowDir.up,
    color: AppColors.arrowOrange,
  ),
  // Arrow 2 — yellow L-bend, exits up after 0 clears row 1
  BentArrowData(
    id: 2,
    segs: [BentCell(3,1), BentCell(1,1)],
    escape: ArrowDir.up,
    color: AppColors.arrowYellow,
  ),
  // Arrow 3 — green, exits right after 1 clears the path
  BentArrowData(
    id: 3,
    segs: [BentCell(3,3), BentCell(1,3)],
    escape: ArrowDir.up,
    color: AppColors.arrowGreen,
  ),
  // Arrow 4 — cyan, centre bottom; exits down last after shape is clear
  BentArrowData(
    id: 4,
    segs: [BentCell(4,2), BentCell(3,2), BentCell(0,2)],
    escape: ArrowDir.up,
    color: AppColors.arrowCyan,
  ),
];

// ── Widget — StatefulWidget wrapper ──────────────────────────────────────────
class GameScreenLvl1 extends StatefulWidget {
  const GameScreenLvl1({super.key});
  @override
  State<GameScreenLvl1> createState() => _GameScreenLvl1State();
}

// ── State — uses BentLevelStateMixin for all game logic ──────────────────────
class _GameScreenLvl1State extends State<GameScreenLvl1>
    with BentLevelStateMixin<GameScreenLvl1> {
  @override int get levelNumber => 1;          // used by unlock service
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl2();

  @override
  void initState() {
    super.initState();
    initLevelState(); // starts timer, builds arrows, plays music
  }

  @override
  Widget build(BuildContext context) {
    // Scale cell size to 88% of screen width
    final cellSize = (MediaQuery.of(context).size.width * 0.88) / _cols;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(children: [
        SafeArea(
          child: Column(children: [
            buildHUD(),                  // lives + timer row
            const SizedBox(height: 6),
            _label(),                    // level / shape title
            const SizedBox(height: 10),
            Expanded(child: Center(child: buildGrid(cellSize, _shapeCells))),
          ]),
        ),
        // Overlay screens shown on game-over or victory
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory) VictoryOverlay(isLastLevel: false, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }

  /// Small subtitle under the HUD identifying the current level and shape.
  Widget _label() => Text(
    'Level 1 · Heart · 5×5',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2,
    ),
  );
}
