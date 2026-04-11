// lib/levels/game_screen_lvl_2.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 2 — 6×6 Grid — CIRCLE shape
// 8 bent arrows (one per perimeter segment), tap order 0 → 7.
// Each BentCell appears in exactly one arrow — no overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_3.dart';

// Grid dimensions
const int _rows = 6, _cols = 6;

// Circle perimeter outline cells
const Set<(int, int)> _shapeCells = {
  (0,2),(0,3),
  (1,1),(1,4),
  (2,0),(2,5),
  (3,0),(3,5),
  (4,1),(4,4),
  (5,2),(5,3),
};

// Arrows — each cell belongs to exactly ONE arrow segment
List<BentArrowData> _buildArrows() => [
  // Arrow 0 — top arc (2 cells), exits up
  BentArrowData(id:0, segs:[BentCell(0,2),BentCell(0,3)],       escape:ArrowDir.up,    color:AppColors.arrowRed),
  // Arrow 1 — upper-right diagonal, exits right
  BentArrowData(id:1, segs:[BentCell(1,4)],                      escape:ArrowDir.right, color:AppColors.arrowOrange),
  // Arrow 2 — right arc (2 cells), exits right
  BentArrowData(id:2, segs:[BentCell(2,5),BentCell(3,5)],       escape:ArrowDir.right, color:AppColors.arrowYellow),
  // Arrow 3 — lower-right diagonal, exits right
  BentArrowData(id:3, segs:[BentCell(4,4)],                      escape:ArrowDir.right, color:AppColors.arrowGreen),
  // Arrow 4 — bottom arc (2 cells), exits down
  BentArrowData(id:4, segs:[BentCell(5,3),BentCell(5,2)],       escape:ArrowDir.down,  color:AppColors.arrowCyan),
  // Arrow 5 — lower-left diagonal, exits left
  BentArrowData(id:5, segs:[BentCell(4,1)],                      escape:ArrowDir.left,  color:AppColors.arrowBlue),
  // Arrow 6 — left arc (2 cells), exits left
  BentArrowData(id:6, segs:[BentCell(3,0),BentCell(2,0)],       escape:ArrowDir.left,  color:AppColors.arrowPurple),
  // Arrow 7 — upper-left diagonal, exits up (last blocker removed)
  BentArrowData(id:7, segs:[BentCell(1,1)],                      escape:ArrowDir.left,  color:AppColors.arrowPink),
];

class GameScreenLvl2 extends StatefulWidget {
  const GameScreenLvl2({super.key});
  @override
  State<GameScreenLvl2> createState() => _GameScreenLvl2State();
}

class _GameScreenLvl2State extends State<GameScreenLvl2>
    with BentLevelStateMixin<GameScreenLvl2> {
  @override int get levelNumber => 2;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl3();

  @override
  void initState() { super.initState(); initLevelState(); }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width * 0.88) / _cols;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(children: [
        SafeArea(child: Column(children: [
          buildHUD(),
          const SizedBox(height: 6),
          Text('Level 2 · Circle · 6×6',
              style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize:13, letterSpacing:1.2)),
          const SizedBox(height: 10),
          Expanded(child: Center(child: buildGrid(cellSize, _shapeCells))),
        ])),
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory) VictoryOverlay(isLastLevel: false, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }
}
