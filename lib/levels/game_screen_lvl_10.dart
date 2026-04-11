// lib/levels/game_screen_lvl_10.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 10 — 14×14 Grid — Cross Shape
// 66 bent arrows, solvable in sequential order (tap 0 → 65).
//
// Architecture:
//   • Uses BentLevelStateMixin from level_base.dart for all game-loop logic
//     (timer, lives, tap handling, HUD, grid renderer, victory/game-over).
//   • _shapeCells defines which grid cells form the visual shape background.
//   • _buildArrows() returns the ordered list of BentArrowData objects.
//     Arrow id == the solve-order index so tapping them out of order triggers
//     a wrong-tap (life deduction).
//   • triggerVictory() (inherited) calls GameProvider.recordLevelComplete()
//     which in turn calls unlockNextLevel() → Level 10 becomes accessible.
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
import 'game_screen_lvl_1.dart';

const int _rows = 14, _cols = 14;

const Set<(int, int)> _shapeCells = {
  (0, 4),
  (0, 5),
  (0, 6),
  (0, 7),
  (0, 8),
  (0, 9),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 7),
  (1, 8),
  (1, 9),
  (2, 4),
  (2, 5),
  (2, 6),
  (2, 7),
  (2, 8),
  (2, 9),
  (3, 4),
  (3, 5),
  (3, 6),
  (3, 7),
  (3, 8),
  (3, 9),
  (4, 0),
  (4, 1),
  (4, 2),
  (4, 3),
  (4, 4),
  (4, 5),
  (4, 6),
  (4, 7),
  (4, 8),
  (4, 9),
  (4, 10),
  (4, 11),
  (4, 12),
  (4, 13),
  (5, 0),
  (5, 1),
  (5, 2),
  (5, 3),
  (5, 4),
  (5, 5),
  (5, 6),
  (5, 7),
  (5, 8),
  (5, 9),
  (5, 10),
  (5, 11),
  (5, 12),
  (5, 13),
  (6, 0),
  (6, 1),
  (6, 2),
  (6, 3),
  (6, 4),
  (6, 5),
  (6, 6),
  (6, 7),
  (6, 8),
  (6, 9),
  (6, 10),
  (6, 11),
  (6, 12),
  (6, 13),
  (7, 0),
  (7, 1),
  (7, 2),
  (7, 3),
  (7, 4),
  (7, 5),
  (7, 6),
  (7, 7),
  (7, 8),
  (7, 9),
  (7, 10),
  (7, 11),
  (7, 12),
  (7, 13),
  (8, 0),
  (8, 1),
  (8, 2),
  (8, 3),
  (8, 4),
  (8, 5),
  (8, 6),
  (8, 7),
  (8, 8),
  (8, 9),
  (8, 10),
  (8, 11),
  (8, 12),
  (8, 13),
  (9, 0),
  (9, 1),
  (9, 2),
  (9, 3),
  (9, 4),
  (9, 5),
  (9, 6),
  (9, 7),
  (9, 8),
  (9, 9),
  (9, 10),
  (9, 11),
  (9, 12),
  (9, 13),
  (10, 4),
  (10, 5),
  (10, 6),
  (10, 7),
  (10, 8),
  (10, 9),
  (11, 4),
  (11, 5),
  (11, 6),
  (11, 7),
  (11, 8),
  (11, 9),
  (12, 4),
  (12, 5),
  (12, 6),
  (12, 7),
  (12, 8),
  (12, 9),
  (13, 4),
  (13, 5),
  (13, 6),
  (13, 7),
  (13, 8),
  (13, 9),
};

List<BentArrowData> _buildArrows() => [
      BentArrowData(
          id: 0,
          segs: [BentCell(1, 6), BentCell(0, 7)],
          escape: ArrowDir.up,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 1,
          segs: [BentCell(1, 5), BentCell(0, 4)],
          escape: ArrowDir.up,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 2,
          segs: [BentCell(0, 6), BentCell(0, 5)],
          escape: ArrowDir.left,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 3,
          segs: [BentCell(2, 6), BentCell(1, 7)],
          escape: ArrowDir.up,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 4,
          segs: [BentCell(6, 6), BentCell(4, 3)],
          escape: ArrowDir.up,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 5,
          segs: [BentCell(5, 10), BentCell(4, 11)],
          escape: ArrowDir.up,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 6,
          segs: [BentCell(8, 8), BentCell(5, 11)],
          escape: ArrowDir.up,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 7,
          segs: [BentCell(8, 11), BentCell(9, 10)],
          escape: ArrowDir.down,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 8,
          segs: [BentCell(12, 7), BentCell(13, 6)],
          escape: ArrowDir.down,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 9,
          segs: [BentCell(12, 4), BentCell(13, 5)],
          escape: ArrowDir.down,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 10,
          segs: [BentCell(11, 4), BentCell(12, 5)],
          escape: ArrowDir.down,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 11,
          segs: [BentCell(12, 8), BentCell(13, 7)],
          escape: ArrowDir.down,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 12,
          segs: [BentCell(5, 13), BentCell(11, 7)],
          escape: ArrowDir.down,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 13,
          segs: [BentCell(4, 13), BentCell(10, 7)],
          escape: ArrowDir.down,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 14,
          segs: [BentCell(4, 12), BentCell(9, 7)],
          escape: ArrowDir.down,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 15,
          segs: [BentCell(9, 8), BentCell(5, 12)],
          escape: ArrowDir.up,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 16,
          segs: [BentCell(7, 11), BentCell(6, 12)],
          escape: ArrowDir.up,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 17,
          segs: [BentCell(7, 12), BentCell(6, 13)],
          escape: ArrowDir.up,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 18,
          segs: [BentCell(9, 11), BentCell(8, 12)],
          escape: ArrowDir.up,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 19,
          segs: [BentCell(9, 0), BentCell(13, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 20,
          segs: [BentCell(9, 3), BentCell(10, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 21,
          segs: [BentCell(8, 3), BentCell(9, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 22,
          segs: [BentCell(4, 0), BentCell(7, 3)],
          escape: ArrowDir.down,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 23,
          segs: [BentCell(4, 1), BentCell(6, 3)],
          escape: ArrowDir.down,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 24,
          segs: [BentCell(4, 2), BentCell(5, 3)],
          escape: ArrowDir.down,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 25,
          segs: [BentCell(8, 6), BentCell(5, 2)],
          escape: ArrowDir.up,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 26,
          segs: [BentCell(6, 2), BentCell(5, 1)],
          escape: ArrowDir.up,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 27,
          segs: [BentCell(10, 6), BentCell(7, 2)],
          escape: ArrowDir.up,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 28,
          segs: [BentCell(6, 1), BentCell(5, 0)],
          escape: ArrowDir.up,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 29,
          segs: [BentCell(11, 6), BentCell(8, 2)],
          escape: ArrowDir.up,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 30,
          segs: [BentCell(7, 1), BentCell(6, 0)],
          escape: ArrowDir.up,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 31,
          segs: [BentCell(12, 6), BentCell(9, 2)],
          escape: ArrowDir.up,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 32,
          segs: [BentCell(8, 7), BentCell(9, 6)],
          escape: ArrowDir.down,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 33,
          segs: [BentCell(6, 7), BentCell(7, 6)],
          escape: ArrowDir.down,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 34,
          segs: [BentCell(4, 7), BentCell(5, 6)],
          escape: ArrowDir.down,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 35,
          segs: [BentCell(4, 10), BentCell(7, 7)],
          escape: ArrowDir.down,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 36,
          segs: [BentCell(3, 9), BentCell(5, 7)],
          escape: ArrowDir.down,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 37,
          segs: [BentCell(8, 1), BentCell(7, 0)],
          escape: ArrowDir.up,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 38,
          segs: [BentCell(9, 1), BentCell(8, 0)],
          escape: ArrowDir.up,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 39,
          segs: [BentCell(12, 9), BentCell(13, 8)],
          escape: ArrowDir.down,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 40,
          segs: [BentCell(10, 9), BentCell(11, 8)],
          escape: ArrowDir.down,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 41,
          segs: [BentCell(9, 9), BentCell(10, 8)],
          escape: ArrowDir.down,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 42,
          segs: [BentCell(6, 9), BentCell(7, 8)],
          escape: ArrowDir.down,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 43,
          segs: [BentCell(9, 13), BentCell(13, 9)],
          escape: ArrowDir.down,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 44,
          segs: [BentCell(7, 13), BentCell(11, 9)],
          escape: ArrowDir.down,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 45,
          segs: [BentCell(6, 11), BentCell(8, 9)],
          escape: ArrowDir.down,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 46,
          segs: [BentCell(6, 10), BentCell(7, 9)],
          escape: ArrowDir.down,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 47,
          segs: [BentCell(10, 5), BentCell(7, 10)],
          escape: ArrowDir.up,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 48,
          segs: [BentCell(11, 5), BentCell(8, 10)],
          escape: ArrowDir.up,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 49,
          segs: [BentCell(8, 4), BentCell(9, 5)],
          escape: ArrowDir.down,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 50,
          segs: [BentCell(7, 4), BentCell(8, 5)],
          escape: ArrowDir.down,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 51,
          segs: [BentCell(6, 4), BentCell(7, 5)],
          escape: ArrowDir.down,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 52,
          segs: [BentCell(5, 4), BentCell(6, 5)],
          escape: ArrowDir.down,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 53,
          segs: [BentCell(2, 9), BentCell(4, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 54,
          segs: [BentCell(1, 9), BentCell(3, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 55,
          segs: [BentCell(0, 9), BentCell(2, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 56,
          segs: [BentCell(0, 8), BentCell(1, 4)],
          escape: ArrowDir.down,
          color: AppColors.arrowYellow),
      BentArrowData(
          id: 57,
          segs: [BentCell(2, 7), BentCell(1, 8)],
          escape: ArrowDir.up,
          color: AppColors.arrowGreen),
      BentArrowData(
          id: 58,
          segs: [BentCell(4, 6), BentCell(2, 8)],
          escape: ArrowDir.up,
          color: AppColors.arrowCyan),
      BentArrowData(
          id: 59,
          segs: [BentCell(2, 5), BentCell(3, 6)],
          escape: ArrowDir.down,
          color: AppColors.arrowBlue),
      BentArrowData(
          id: 60,
          segs: [BentCell(4, 5), BentCell(3, 8)],
          escape: ArrowDir.up,
          color: AppColors.arrowPurple),
      BentArrowData(
          id: 61,
          segs: [BentCell(3, 5), BentCell(3, 7)],
          escape: ArrowDir.right,
          color: AppColors.arrowPink),
      BentArrowData(
          id: 62,
          segs: [BentCell(5, 5), BentCell(4, 8)],
          escape: ArrowDir.up,
          color: AppColors.arrowWhite),
      BentArrowData(
          id: 63,
          segs: [BentCell(5, 8), BentCell(4, 9)],
          escape: ArrowDir.up,
          color: AppColors.arrowRed),
      BentArrowData(
          id: 64,
          segs: [BentCell(6, 8), BentCell(5, 9)],
          escape: ArrowDir.up,
          color: AppColors.arrowOrange),
      BentArrowData(
          id: 65,
          segs: [BentCell(9, 12), BentCell(8, 13)],
          escape: ArrowDir.up,
          color: AppColors.arrowYellow),
    ];

class GameScreenLvl10 extends StatefulWidget {
  const GameScreenLvl10({super.key});
  @override
  State<GameScreenLvl10> createState() => _GameScreenLvl10State();
}

class _GameScreenLvl10State extends State<GameScreenLvl10>
    with BentLevelStateMixin<GameScreenLvl10> {
  @override
  int get levelNumber => 10;
  @override
  int get rows => _rows;
  @override
  int get cols => _cols;
  @override
  List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override
  Widget Function() get nextLevelBuilder => () => const GameScreenLvl1();

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
          VictoryOverlay(isLastLevel: true, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }

  Widget _label() => Text(
        'Level 10 · Cross · 14×14',
        style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
            letterSpacing: 1.2),
      );
}
