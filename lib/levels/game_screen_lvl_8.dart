// lib/levels/game_screen_lvl_8.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 8 — 12×12 Grid — Shield shape
// 14 bent arrows, tap order 0 → 13.
// Each BentCell appears in exactly one arrow — no overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_9.dart';

// Grid dimensions
const int _rows = 12, _cols = 12;

// Shield outline cells — used for cell-background decoration
const Set<(int, int)> _shapeCells = {
  (1,2),
  (1,3),
  (1,4),
  (1,5),
  (1,6),
  (1,7),
  (1,8),
  (1,9),
  (2,10),
  (3,10),
  (4,10),
  (5,10),
  (6,10),
  (7,9),
  (8,8),
  (9,7),
  (10,6),
  (11,5),
  (11,6),
  (10,5),
  (9,4),
  (8,3),
  (7,2),
  (6,1),
  (5,1),
  (4,1),
  (3,1),
  (2,1),
};

// Arrow definitions — each cell belongs to exactly ONE arrow
List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(1,2),BentCell(1,3)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(1,4),BentCell(1,5)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(1,6),BentCell(1,7)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(1,8),BentCell(1,9)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(2,10),BentCell(3,10)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(4,10),BentCell(5,10)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(6,10),BentCell(7,9)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(8,8),BentCell(9,7)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(10,6),BentCell(11,5)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(11,6),BentCell(10,5)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(9,4),BentCell(8,3)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(7,2),BentCell(6,1)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(5,1),BentCell(4,1)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(3,1),BentCell(2,1)], escape:ArrowDir.up, color:AppColors.arrowCyan),
];

class GameScreenLvl8 extends StatefulWidget {
  const GameScreenLvl8({super.key});
  @override
  State<GameScreenLvl8> createState() => _GameScreenLvl8State();
}

class _GameScreenLvl8State extends State<GameScreenLvl8>
    with BentLevelStateMixin<GameScreenLvl8> {
  @override int get levelNumber => 8;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl9();

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
          Text('Level 8 · Shield · 12×12',
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
