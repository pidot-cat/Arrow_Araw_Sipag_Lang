// lib/levels/game_screen_lvl_3.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 3 — 7×7 Grid — TRIANGLE shape
// 9 bent arrows, tap order 0 → 8.
// The triangle points upward; arrows line the three sides.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_4.dart';

const int _rows = 7, _cols = 7;

// Upward-pointing triangle outline on a 7×7 grid
const Set<(int, int)> _shapeCells = {
  (0,3),
  (1,2),(1,4),
  (2,2),(2,4),
  (3,1),(3,5),
  (4,1),(4,5),
  (5,0),(5,6),
  (6,0),(6,1),(6,2),(6,3),(6,4),(6,5),(6,6),
};

List<BentArrowData> _buildArrows() => [
  // Base row — exits downward first (most exposed)
  BentArrowData(id:0, segs:[BentCell(6,0),BentCell(6,1)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(6,6),BentCell(6,5)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(6,2),BentCell(6,3),BentCell(6,4)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  // Right side — exits right
  BentArrowData(id:3, segs:[BentCell(5,6),BentCell(4,5)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(3,5),BentCell(2,4)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  // Left side — exits left
  BentArrowData(id:5, segs:[BentCell(5,0),BentCell(4,1)], escape:ArrowDir.left, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(3,1),BentCell(2,2)], escape:ArrowDir.left, color:AppColors.arrowPurple),
  // Inner left-right pairs
  BentArrowData(id:7, segs:[BentCell(1,4),BentCell(1,2)], escape:ArrowDir.up, color:AppColors.arrowPink),
  // Apex — exits up last
  BentArrowData(id:8, segs:[BentCell(0,3)], escape:ArrowDir.up, color:AppColors.arrowWhite),
];

class GameScreenLvl3 extends StatefulWidget {
  const GameScreenLvl3({super.key});
  @override
  State<GameScreenLvl3> createState() => _GameScreenLvl3State();
}

class _GameScreenLvl3State extends State<GameScreenLvl3>
    with BentLevelStateMixin<GameScreenLvl3> {
  @override int get levelNumber => 3;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl4();

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
          Text('Level 3 · Triangle · 7×7',
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
