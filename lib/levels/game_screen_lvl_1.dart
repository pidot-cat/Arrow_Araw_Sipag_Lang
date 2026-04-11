// lib/levels/game_screen_lvl_1.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 1 — 5×5 Grid — Heart Shape
// 5 bent arrows, solvable in sequential order (tap 0 → 4).
//
// Architecture:
//   • Uses BentLevelStateMixin from level_base.dart for all game-loop logic
//     (timer, lives, tap handling, HUD, grid renderer, victory/game-over).
//   • _shapeCells defines which grid cells form the visual shape background.
//   • _buildArrows() returns the ordered list of BentArrowData objects.
//     Arrow id == the solve-order index so tapping them out of order triggers
//     a wrong-tap (life deduction).
//   • triggerVictory() (inherited) calls GameProvider.recordLevelComplete()
//     which in turn calls unlockNextLevel() → Level 2 becomes accessible.
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
import 'game_screen_lvl_2.dart';

const int _rows = 5, _cols = 5;

const Set<(int, int)> _shapeCells = {
  (0,1),
  (0,2),
  (1,0),
  (1,1),
  (1,2),
  (1,3),
  (2,0),
  (2,1),
  (2,2),
  (2,3),
  (2,4),
  (3,1),
  (3,2),
  (3,3),
  (4,2),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(2,4), BentCell(2,3), BentCell(1,3)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(4,2), BentCell(3,2), BentCell(3,3)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(3,1), BentCell(2,1), BentCell(2,0), BentCell(1,0)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(0,2), BentCell(0,1), BentCell(1,1)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(2,2), BentCell(1,2)], escape:ArrowDir.up, color:AppColors.arrowCyan),
];

class GameScreenLvl1 extends StatefulWidget {
  const GameScreenLvl1({super.key});
  @override
  State<GameScreenLvl1> createState() => _GameScreenLvl1State();
}

class _GameScreenLvl1State extends State<GameScreenLvl1>
    with BentLevelStateMixin<GameScreenLvl1> {
  @override int get levelNumber => 1;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl2();

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
    'Level 1 · Heart · 5×5',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
