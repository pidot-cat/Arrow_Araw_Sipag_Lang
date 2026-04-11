// lib/levels/game_screen_lvl_10.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 10 — 14×14 Grid — Cross shape
// 26 bent arrows, tap order 0 → 25.
// Each BentCell appears in exactly one arrow — no overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_1.dart';

// Grid dimensions
const int _rows = 14, _cols = 14;

// Cross outline cells — used for cell-background decoration
const Set<(int, int)> _shapeCells = {
  (0,5),
  (0,6),
  (0,7),
  (0,8),
  (1,5),
  (2,5),
  (3,5),
  (4,5),
  (4,8),
  (3,8),
  (2,8),
  (1,8),
  (5,9),
  (5,10),
  (5,11),
  (5,12),
  (5,13),
  (6,13),
  (7,13),
  (8,13),
  (8,12),
  (8,11),
  (8,10),
  (8,9),
  (7,9),
  (6,9),
  (6,4),
  (7,4),
  (5,3),
  (5,2),
  (5,1),
  (5,0),
  (6,0),
  (7,0),
  (8,0),
  (8,1),
  (8,2),
  (8,3),
  (8,4),
  (9,8),
  (10,8),
  (11,8),
  (12,8),
  (13,8),
  (13,7),
  (13,6),
  (13,5),
  (12,5),
  (11,5),
  (10,5),
  (9,5),
};

// Arrow definitions — each cell belongs to exactly ONE arrow
List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(0,5),BentCell(0,6)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(0,7),BentCell(0,8)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(1,5),BentCell(2,5)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(3,5),BentCell(4,5)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(4,8),BentCell(3,8)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(2,8),BentCell(1,8)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(5,9),BentCell(5,10)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(5,11),BentCell(5,12)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(5,13),BentCell(6,13)], escape:ArrowDir.right, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(7,13),BentCell(8,13)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(8,12),BentCell(8,11)], escape:ArrowDir.left, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(8,10),BentCell(8,9)], escape:ArrowDir.left, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(7,9),BentCell(6,9)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(6,4),BentCell(7,4)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:14, segs:[BentCell(5,3),BentCell(5,2)], escape:ArrowDir.left, color:AppColors.arrowBlue),
  BentArrowData(id:15, segs:[BentCell(5,1),BentCell(5,0)], escape:ArrowDir.left, color:AppColors.arrowPurple),
  BentArrowData(id:16, segs:[BentCell(6,0),BentCell(7,0)], escape:ArrowDir.left, color:AppColors.arrowPink),
  BentArrowData(id:17, segs:[BentCell(8,0),BentCell(8,1)], escape:ArrowDir.right, color:AppColors.arrowWhite),
  BentArrowData(id:18, segs:[BentCell(8,2),BentCell(8,3)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:19, segs:[BentCell(8,4),BentCell(9,8)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:20, segs:[BentCell(10,8),BentCell(11,8)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:21, segs:[BentCell(12,8),BentCell(13,8)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:22, segs:[BentCell(13,7),BentCell(13,6)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:23, segs:[BentCell(13,5),BentCell(12,5)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:24, segs:[BentCell(11,5),BentCell(10,5)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:25, segs:[BentCell(9,5)], escape:ArrowDir.up, color:AppColors.arrowYellow),
];

class GameScreenLvl10 extends StatefulWidget {
  const GameScreenLvl10({super.key});
  @override
  State<GameScreenLvl10> createState() => _GameScreenLvl10State();
}

class _GameScreenLvl10State extends State<GameScreenLvl10>
    with BentLevelStateMixin<GameScreenLvl10> {
  @override int get levelNumber => 10;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl1();

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
          Text('Level 10 · Cross · 14×14',
              style: TextStyle(color: Colors.white.withValues(alpha:0.5), fontSize:13, letterSpacing:1.2)),
          const SizedBox(height: 10),
          Expanded(child: Center(child: buildGrid(cellSize, _shapeCells))),
        ])),
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory) VictoryOverlay(isLastLevel: true, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }
}
