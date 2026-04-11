// lib/levels/game_screen_lvl_4.dart
// Level 4 — 8×8 Grid — Diamond Shape
// 7 bent arrows — solvable in order 0→6

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_5.dart';

const int _rows = 8, _cols = 8;

const Set<(int, int)> _shapeCells = {
  (1,3),
  (1,4),
  (2,2),
  (2,3),
  (2,4),
  (2,5),
  (3,1),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (3,6),
  (4,1),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (4,6),
  (5,2),
  (5,3),
  (5,4),
  (5,5),
  (6,3),
  (6,4),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(6,3), BentCell(6,4), BentCell(5,4), BentCell(5,5)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(5,2), BentCell(5,3)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(4,3), BentCell(4,4), BentCell(4,5), BentCell(4,6)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(3,1), BentCell(4,1), BentCell(4,2)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(3,4), BentCell(3,3), BentCell(3,2), BentCell(2,2)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(1,4), BentCell(1,3), BentCell(2,3)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(3,6), BentCell(3,5), BentCell(2,5), BentCell(2,4)], escape:ArrowDir.left, color:AppColors.arrowPurple),
];

class GameScreenLvl4 extends StatefulWidget {
  const GameScreenLvl4({super.key});
  @override
  State<GameScreenLvl4> createState() => _GameScreenLvl4State();
}

class _GameScreenLvl4State extends State<GameScreenLvl4>
    with BentLevelStateMixin<GameScreenLvl4> {
  @override int get levelNumber => 4;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl5();

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
    'Level 4 · Diamond · 8×8',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
