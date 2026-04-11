// lib/levels/game_screen_lvl_7.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 7 — 11×11 Grid — Heptagon shape
// 12 bent arrows, tap order 0 → 11.
// Each BentCell appears in exactly one arrow — no overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_8.dart';

// Grid dimensions
const int _rows = 11, _cols = 11;

// Heptagon outline cells — used for cell-background decoration
const Set<(int, int)> _shapeCells = {
  (1,3),
  (1,4),
  (1,5),
  (1,6),
  (1,7),
  (2,8),
  (3,9),
  (4,9),
  (5,10),
  (6,9),
  (7,8),
  (8,7),
  (9,6),
  (9,5),
  (9,4),
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
  BentArrowData(id:2, segs:[BentCell(1,7),BentCell(2,8)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(3,9),BentCell(4,9)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(5,10),BentCell(6,9)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(7,8),BentCell(8,7)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(9,6),BentCell(9,5)], escape:ArrowDir.left, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(9,4),BentCell(9,3)], escape:ArrowDir.left, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(8,2),BentCell(7,1)], escape:ArrowDir.up, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(6,0),BentCell(5,0)], escape:ArrowDir.left, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(4,1),BentCell(3,1)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(2,2)], escape:ArrowDir.up, color:AppColors.arrowYellow),
];

class GameScreenLvl7 extends StatefulWidget {
  const GameScreenLvl7({super.key});
  @override
  State<GameScreenLvl7> createState() => _GameScreenLvl7State();
}

class _GameScreenLvl7State extends State<GameScreenLvl7>
    with BentLevelStateMixin<GameScreenLvl7> {
  @override int get levelNumber => 7;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl8();

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
          Text('Level 7 · Heptagon · 11×11',
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
