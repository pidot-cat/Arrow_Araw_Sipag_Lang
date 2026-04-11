// lib/levels/game_screen_lvl_2.dart
// Level 2 — 6×6 Grid — Circle Shape
// 12 bent arrows — solvable in order 0→11

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_3.dart';

const int _rows = 6, _cols = 6;

const Set<(int, int)> _shapeCells = {
  (0,1),
  (0,2),
  (0,3),
  (0,4),
  (1,0),
  (1,1),
  (1,2),
  (1,3),
  (1,4),
  (1,5),
  (2,0),
  (2,1),
  (2,2),
  (2,3),
  (2,4),
  (2,5),
  (3,0),
  (3,1),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (4,0),
  (4,1),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (5,1),
  (5,2),
  (5,3),
  (5,4),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(3,4), BentCell(3,5)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(0,2), BentCell(0,1)], escape:ArrowDir.left, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(1,0), BentCell(2,0), BentCell(2,1), BentCell(1,1)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(4,0), BentCell(3,0)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(5,1), BentCell(4,1), BentCell(3,1)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(5,4), BentCell(5,3), BentCell(5,2)], escape:ArrowDir.left, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(0,4), BentCell(0,3)], escape:ArrowDir.left, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(1,3), BentCell(1,2)], escape:ArrowDir.left, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(4,2), BentCell(3,2), BentCell(2,2)], escape:ArrowDir.up, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(2,5), BentCell(1,5), BentCell(1,4)], escape:ArrowDir.left, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(4,3), BentCell(3,3), BentCell(2,3), BentCell(2,4)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(4,5), BentCell(4,4)], escape:ArrowDir.left, color:AppColors.arrowYellow),
];

class GameScreenLvl2 extends StatefulWidget {
  const GameScreenLvl2({super.key});
  @override
  State<GameScreenLvl2> createState() => _GameScreenLvl2State();
}

class _GameScreenLvl2State extends State<GameScreenLvl2>
    with BentLevelStateMixin<GameScreenLvl2> {
  @override int get levelNumber => 2;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl3();

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
    'Level 2 · Circle · 6×6',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
