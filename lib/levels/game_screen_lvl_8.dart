// lib/levels/game_screen_lvl_8.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 8 — 12×12 Grid — Shield Shape
// 62 bent arrows, solvable in sequential order (tap 0 → 61).
//
// Architecture:
//   • Uses BentLevelStateMixin from level_base.dart for all game-loop logic
//     (timer, lives, tap handling, HUD, grid renderer, victory/game-over).
//   • _shapeCells defines which grid cells form the visual shape background.
//   • _buildArrows() returns the ordered list of BentArrowData objects.
//     Arrow id == the solve-order index so tapping them out of order triggers
//     a wrong-tap (life deduction).
//   • triggerVictory() (inherited) calls GameProvider.recordLevelComplete()
//     which in turn calls unlockNextLevel() → Level 9 becomes accessible.
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
import 'game_screen_lvl_9.dart';

const int _rows = 12, _cols = 12;

const Set<(int, int)> _shapeCells = {
  (0,0),
  (0,1),
  (0,2),
  (0,3),
  (0,4),
  (0,5),
  (0,6),
  (0,7),
  (0,8),
  (0,9),
  (0,10),
  (0,11),
  (1,0),
  (1,1),
  (1,2),
  (1,3),
  (1,4),
  (1,5),
  (1,6),
  (1,7),
  (1,8),
  (1,9),
  (1,10),
  (1,11),
  (2,0),
  (2,1),
  (2,2),
  (2,3),
  (2,4),
  (2,5),
  (2,6),
  (2,7),
  (2,8),
  (2,9),
  (2,10),
  (2,11),
  (3,0),
  (3,1),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (3,6),
  (3,7),
  (3,8),
  (3,9),
  (3,10),
  (3,11),
  (4,0),
  (4,1),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (4,6),
  (4,7),
  (4,8),
  (4,9),
  (4,10),
  (4,11),
  (5,1),
  (5,2),
  (5,3),
  (5,4),
  (5,5),
  (5,6),
  (5,7),
  (5,8),
  (5,9),
  (5,10),
  (6,1),
  (6,2),
  (6,3),
  (6,4),
  (6,5),
  (6,6),
  (6,7),
  (6,8),
  (6,9),
  (6,10),
  (7,1),
  (7,2),
  (7,3),
  (7,4),
  (7,5),
  (7,6),
  (7,7),
  (7,8),
  (7,9),
  (7,10),
  (8,1),
  (8,2),
  (8,3),
  (8,4),
  (8,5),
  (8,6),
  (8,7),
  (8,8),
  (8,9),
  (8,10),
  (9,1),
  (9,2),
  (9,3),
  (9,4),
  (9,5),
  (9,6),
  (9,7),
  (9,8),
  (9,9),
  (9,10),
  (10,2),
  (10,3),
  (10,4),
  (10,5),
  (10,6),
  (10,7),
  (10,8),
  (10,9),
  (11,3),
  (11,4),
  (11,5),
  (11,6),
  (11,7),
  (11,8),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(10,6), BentCell(0,6)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(10,5), BentCell(0,5)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(9,5), BentCell(1,5)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(8,5), BentCell(2,5)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(7,5), BentCell(3,5)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(6,5), BentCell(4,5)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(3,10), BentCell(4,11)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(0,7), BentCell(11,6)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(2,7), BentCell(9,6)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(3,7), BentCell(8,6)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(4,7), BentCell(7,6)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(5,7), BentCell(6,6)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(9,7), BentCell(1,7)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(4,0), BentCell(0,4)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:14, segs:[BentCell(10,4), BentCell(11,5)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:15, segs:[BentCell(0,8), BentCell(3,11)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:16, segs:[BentCell(2,9), BentCell(1,8)], escape:ArrowDir.up, color:AppColors.arrowPink),
  BentArrowData(id:17, segs:[BentCell(10,8), BentCell(11,7)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:18, segs:[BentCell(9,8), BentCell(10,7)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:19, segs:[BentCell(7,8), BentCell(8,7)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:20, segs:[BentCell(6,8), BentCell(7,7)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:21, segs:[BentCell(5,8), BentCell(6,7)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:22, segs:[BentCell(0,3), BentCell(11,4)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:23, segs:[BentCell(1,4), BentCell(9,4)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:24, segs:[BentCell(2,4), BentCell(8,4)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:25, segs:[BentCell(3,4), BentCell(7,4)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:26, segs:[BentCell(4,4), BentCell(6,4)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:27, segs:[BentCell(4,6), BentCell(5,4)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:28, segs:[BentCell(2,2), BentCell(1,3)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:29, segs:[BentCell(1,10), BentCell(2,11)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:30, segs:[BentCell(0,9), BentCell(9,10)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:31, segs:[BentCell(2,10), BentCell(1,9)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:32, segs:[BentCell(10,9), BentCell(11,8)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:33, segs:[BentCell(6,10), BentCell(8,8)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:34, segs:[BentCell(8,10), BentCell(9,9)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:35, segs:[BentCell(7,10), BentCell(8,9)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:36, segs:[BentCell(4,10), BentCell(7,9)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:37, segs:[BentCell(9,1), BentCell(10,2)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:38, segs:[BentCell(8,1), BentCell(9,2)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:39, segs:[BentCell(7,1), BentCell(8,2)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:40, segs:[BentCell(6,1), BentCell(7,2)], escape:ArrowDir.down, color:AppColors.arrowCyan),
  BentArrowData(id:41, segs:[BentCell(1,6), BentCell(6,2)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:42, segs:[BentCell(4,3), BentCell(5,2)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:43, segs:[BentCell(4,2), BentCell(5,1)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:44, segs:[BentCell(2,3), BentCell(4,1)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:45, segs:[BentCell(7,3), BentCell(3,3)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:46, segs:[BentCell(1,1), BentCell(0,2)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:47, segs:[BentCell(2,1), BentCell(1,2)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:48, segs:[BentCell(8,3), BentCell(3,2)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:49, segs:[BentCell(1,11), BentCell(0,10)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:50, segs:[BentCell(6,9), BentCell(5,10)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:51, segs:[BentCell(4,8), BentCell(5,9)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:52, segs:[BentCell(3,8), BentCell(4,9)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:53, segs:[BentCell(2,8), BentCell(3,9)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:54, segs:[BentCell(1,0), BentCell(0,1)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:55, segs:[BentCell(9,3), BentCell(3,1)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:56, segs:[BentCell(0,11), BentCell(0,0)], escape:ArrowDir.left, color:AppColors.arrowYellow),
  BentArrowData(id:57, segs:[BentCell(11,3), BentCell(2,0)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:58, segs:[BentCell(10,3), BentCell(3,0)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:59, segs:[BentCell(2,6), BentCell(6,3)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:60, segs:[BentCell(3,6), BentCell(5,3)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:61, segs:[BentCell(5,6), BentCell(5,5)], escape:ArrowDir.left, color:AppColors.arrowPink),
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
    'Level 8 · Shield · 12×12',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
