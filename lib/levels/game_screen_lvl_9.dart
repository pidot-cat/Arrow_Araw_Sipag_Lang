// lib/levels/game_screen_lvl_9.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 9 — 13×13 Grid — Nonagon shape
// 14 bent arrows, tap order 0 → 13.
// Each BentCell appears in exactly one arrow — no overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_10.dart';

// Grid dimensions
const int _rows = 13, _cols = 13;

// Nonagon outline cells — used for cell-background decoration
const Set<(int, int)> _shapeCells = {
  (1,3),
  (1,4),
  (1,5),
  (1,6),
  (1,7),
  (1,8),
  (1,9),
  (2,10),
  (3,11),
  (4,11),
  (5,12),
  (6,11),
  (7,10),
  (8,9),
  (9,8),
  (10,7),
  (11,6),
  (11,5),
  (10,4),
  (9,3),
  (8,2),
  (7,1),
  (6,0),
  (5,0),
  (4,1),
  (3,1),
  (2,2),
};

// Arrow definitions — each cell belongs to exactly ONE arrow
List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(1,3),BentCell(1,4)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(1,5),BentCell(1,6)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(1,7),BentCell(1,8)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(1,9),BentCell(2,10)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(3,11),BentCell(4,11)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(5,12),BentCell(6,11)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(7,10),BentCell(8,9)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(9,8),BentCell(10,7)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(11,6),BentCell(11,5)], escape:ArrowDir.left, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(10,4),BentCell(9,3)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(8,2),BentCell(7,1)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(6,0),BentCell(5,0)], escape:ArrowDir.left, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(4,1),BentCell(3,1)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(2,2)], escape:ArrowDir.up, color:AppColors.arrowCyan),
];

class GameScreenLvl9 extends StatefulWidget {
  const GameScreenLvl9({super.key});
  @override
  State<GameScreenLvl9> createState() => _GameScreenLvl9State();
}

class _GameScreenLvl9State extends State<GameScreenLvl9>
    with BentLevelStateMixin<GameScreenLvl9> {
  @override int get levelNumber => 9;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl10();

  @override
  void initState() { super.initState(); initLevelState(); }

  @override
  Widget build(BuildContext context) {
    // Scale cell size to 88% of screen width divided by column count
    final cellSize = (MediaQuery.of(context).size.width * 0.88) / _cols;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(children: [
        SafeArea(child: Column(children: [
          buildHUD(),                   // lives + countdown timer
          const SizedBox(height: 6),
          Text('Level 9 · Nonagon · 13×13',
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
