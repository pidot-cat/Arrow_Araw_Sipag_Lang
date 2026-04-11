// lib/levels/game_screen_lvl_5.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 5 — 9×9 Grid — Pentagon shape
// 10 bent arrows, tap order 0 → 9.
// Each BentCell appears in exactly one arrow — no overlaps.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_6.dart';

// Grid dimensions
const int _rows = 9, _cols = 9;

// Pentagon outline cells — used for cell-background decoration
const Set<(int, int)> _shapeCells = {
  (7,0),
  (7,1),
  (7,2),
  (7,3),
  (7,4),
  (7,5),
  (7,6),
  (7,7),
  (7,8),
  (6,8),
  (5,7),
  (4,7),
  (3,6),
  (2,5),
  (1,4),
  (2,3),
  (3,2),
  (4,1),
  (5,1),
  (6,0),
};

// Arrow definitions — each cell belongs to exactly ONE arrow
List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(7,0),BentCell(7,1)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(7,2),BentCell(7,3)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(7,4),BentCell(7,5)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(7,6),BentCell(7,7)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(7,8),BentCell(6,8)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(5,7),BentCell(4,7)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(3,6),BentCell(2,5)], escape:ArrowDir.up, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(1,4),BentCell(2,3)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(3,2),BentCell(4,1)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(5,1),BentCell(6,0)], escape:ArrowDir.left, color:AppColors.arrowRed),
];

class GameScreenLvl5 extends StatefulWidget {
  const GameScreenLvl5({super.key});
  @override
  State<GameScreenLvl5> createState() => _GameScreenLvl5State();
}

class _GameScreenLvl5State extends State<GameScreenLvl5>
    with BentLevelStateMixin<GameScreenLvl5> {
  @override int get levelNumber => 5;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl6();

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
          Text('Level 5 · Pentagon · 9×9',
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
