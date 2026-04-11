// lib/levels/game_screen_lvl_4.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 4 — 8×8 Grid — SQUARE shape
// 8 arrows covering the four sides + four corners. No cell overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_5.dart';

const int _rows = 8, _cols = 8;

// Square perimeter — rows 1–6, cols 1–6
const Set<(int, int)> _shapeCells = {
  (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
  (2,1),(2,6),(3,1),(3,6),(4,1),(4,6),(5,1),(5,6),
  (6,1),(6,2),(6,3),(6,4),(6,5),(6,6),
};

// Each cell belongs to exactly ONE arrow
List<BentArrowData> _buildArrows() => [
  // Arrow 0 — top edge left half, exits up
  BentArrowData(id:0, segs:[BentCell(1,1),BentCell(1,2),BentCell(1,3)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  // Arrow 1 — top edge right half, exits up
  BentArrowData(id:1, segs:[BentCell(1,4),BentCell(1,5),BentCell(1,6)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  // Arrow 2 — right side upper, exits right
  BentArrowData(id:2, segs:[BentCell(2,6),BentCell(3,6)],               escape:ArrowDir.right, color:AppColors.arrowYellow),
  // Arrow 3 — right side lower, exits right
  BentArrowData(id:3, segs:[BentCell(4,6),BentCell(5,6)],               escape:ArrowDir.right, color:AppColors.arrowGreen),
  // Arrow 4 — bottom edge right half, exits down
  BentArrowData(id:4, segs:[BentCell(6,6),BentCell(6,5),BentCell(6,4)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  // Arrow 5 — bottom edge left half, exits down
  BentArrowData(id:5, segs:[BentCell(6,3),BentCell(6,2),BentCell(6,1)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  // Arrow 6 — left side lower, exits left
  BentArrowData(id:6, segs:[BentCell(5,1),BentCell(4,1)],               escape:ArrowDir.left,  color:AppColors.arrowPurple),
  // Arrow 7 — left side upper, exits left
  BentArrowData(id:7, segs:[BentCell(3,1),BentCell(2,1)],               escape:ArrowDir.left,  color:AppColors.arrowPink),
];

class GameScreenLvl4 extends StatefulWidget {
  const GameScreenLvl4({super.key});
  @override
  State<GameScreenLvl4> createState() => _GameScreenLvl4State();
}

class _GameScreenLvl4State extends State<GameScreenLvl4>
    with BentLevelStateMixin<GameScreenLvl4> {
  @override int get levelNumber => 4;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl5();

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
          Text('Level 4 · Square · 8×8',
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
