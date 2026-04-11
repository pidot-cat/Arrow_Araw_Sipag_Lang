// lib/levels/game_screen_lvl_5.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 5 — 9×9 Grid — Plus Shape
// 14 bent arrows, solvable in sequential order (tap 0 → 13).
//
// Architecture:
//   • Uses BentLevelStateMixin from level_base.dart for all game-loop logic
//     (timer, lives, tap handling, HUD, grid renderer, victory/game-over).
//   • _shapeCells defines which grid cells form the visual shape background.
//   • _buildArrows() returns the ordered list of BentArrowData objects.
//     Arrow id == the solve-order index so tapping them out of order triggers
//     a wrong-tap (life deduction).
//   • triggerVictory() (inherited) calls GameProvider.recordLevelComplete()
//     which in turn calls unlockNextLevel() → Level 6 becomes accessible.
//
// Snake-path exit animation:
//   Each BentArrowData has an [escape] direction.  When tapped correctly,
//   the arrow widget slides out along that axis via flutter_animate
//   (.slideX / .slideY / .fadeOut) giving the snake-leaving-grid effect.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_6.dart';

const int _rows = 9, _cols = 9;

const Set<(int, int)> _shapeCells = {
  (0,3),
  (0,4),
  (0,5),
  (1,3),
  (1,4),
  (1,5),
  (2,3),
  (2,4),
  (2,5),
  (3,0),
  (3,1),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (3,6),
  (3,7),
  (3,8),
  (4,0),
  (4,1),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (4,6),
  (4,7),
  (4,8),
  (5,0),
  (5,1),
  (5,2),
  (5,3),
  (5,4),
  (5,5),
  (5,6),
  (5,7),
  (5,8),
  (6,3),
  (6,4),
  (6,5),
  (7,3),
  (7,4),
  (7,5),
  (8,3),
  (8,4),
  (8,5),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(3,1), BentCell(4,1), BentCell(4,2), BentCell(3,2)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(7,4), BentCell(8,4), BentCell(8,5)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(4,6), BentCell(3,6), BentCell(3,7), BentCell(3,8)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(5,7), BentCell(4,7), BentCell(4,8), BentCell(5,8)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(5,4), BentCell(4,4), BentCell(4,5)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(7,5), BentCell(6,5), BentCell(5,5), BentCell(5,6)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(2,5), BentCell(3,5)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(0,5), BentCell(1,5)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(5,2), BentCell(5,3), BentCell(6,3), BentCell(6,4)], escape:ArrowDir.right, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(3,0), BentCell(4,0), BentCell(5,0), BentCell(5,1)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(1,3), BentCell(0,3), BentCell(0,4)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(4,3), BentCell(3,3), BentCell(2,3)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(8,3), BentCell(7,3)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(3,4), BentCell(2,4), BentCell(1,4)], escape:ArrowDir.up, color:AppColors.arrowCyan),
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
  void initState() {
    super.initState();
    initLevelState();
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width * 0.88) / _cols;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(children: [
        SafeArea(
          child: Column(children: [
            buildHUD(),
            const SizedBox(height: 6),
            _label(),
            const SizedBox(height: 10),
            Expanded(
              child: Center(child: buildGrid(cellSize, _shapeCells)),
            ),
          ]),
        ),
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory)
          VictoryOverlay(isLastLevel: false, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }

  Widget _label() => Text(
    'Level 5 · Plus · 9×9',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
