// lib/levels/game_screen_lvl_3.dart
// ─────────────────────────────────────────────────────────────────────────────
// Level 3 — 4×7 Grid — Arrow Shape
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
//     which in turn calls unlockNextLevel() → Level 4 becomes accessible.
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
import 'game_screen_lvl_4.dart';

const int _rows = 4, _cols = 7;

const Set<(int, int)> _shapeCells = {
  (0,3),
  (1,2),
  (1,3),
  (1,4),
  (2,0),
  (2,1),
  (2,2),
  (2,3),
  (2,4),
  (2,5),
  (2,6),
  (3,3),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(1,2), BentCell(2,2), BentCell(2,1), BentCell(2,0)], escape:ArrowDir.left, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(1,4), BentCell(2,4)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(2,3), BentCell(3,3)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(0,3), BentCell(1,3)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(2,6), BentCell(2,5)], escape:ArrowDir.left, color:AppColors.arrowCyan),
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
    'Level 3 · Arrow · 4×7',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
