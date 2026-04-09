// lib/levels/game_screen_lvl_9.dart
// Level 9 — 13×13 Grid — Oval Shape
// 25 bent arrows — solvable in order 0→24

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_10.dart';

const int _rows = 13, _cols = 13;

const Set<(int, int)> _shapeCells = {
  (1,6),
  (2,3),
  (2,4),
  (2,5),
  (2,6),
  (2,7),
  (2,8),
  (2,9),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (3,6),
  (3,7),
  (3,8),
  (3,9),
  (3,10),
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
  (5,11),
  (6,0),
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
  (6,11),
  (6,12),
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
  (7,11),
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
  (8,11),
  (9,2),
  (9,3),
  (9,4),
  (9,5),
  (9,6),
  (9,7),
  (9,8),
  (9,9),
  (9,10),
  (10,3),
  (10,4),
  (10,5),
  (10,6),
  (10,7),
  (10,8),
  (10,9),
  (11,6),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(6,12), BentCell(6,11), BentCell(5,11), BentCell(4,11)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(5,1), BentCell(4,1), BentCell(4,2), BentCell(3,2)], escape:ArrowDir.up, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(9,2), BentCell(8,2), BentCell(8,1)], escape:ArrowDir.left, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(7,1), BentCell(7,2), BentCell(6,2), BentCell(5,2)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(10,3), BentCell(10,4), BentCell(9,4), BentCell(9,3)], escape:ArrowDir.left, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(11,6), BentCell(10,6), BentCell(10,5)], escape:ArrowDir.left, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(8,8), BentCell(8,7), BentCell(8,6), BentCell(9,6)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(3,4), BentCell(4,4), BentCell(4,3)], escape:ArrowDir.left, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(4,5), BentCell(5,5), BentCell(5,4), BentCell(5,3)], escape:ArrowDir.left, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(6,8), BentCell(5,8), BentCell(5,7), BentCell(4,7), BentCell(4,6)], escape:ArrowDir.left, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(7,4), BentCell(8,4), BentCell(8,3)], escape:ArrowDir.left, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(6,4), BentCell(6,3), BentCell(7,3)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(2,4), BentCell(2,3), BentCell(3,3)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(1,6), BentCell(2,6), BentCell(2,5)], escape:ArrowDir.left, color:AppColors.arrowCyan),
  BentArrowData(id:14, segs:[BentCell(3,6), BentCell(3,5)], escape:ArrowDir.left, color:AppColors.arrowBlue),
  BentArrowData(id:15, segs:[BentCell(9,5), BentCell(8,5), BentCell(7,5), BentCell(6,5)], escape:ArrowDir.up, color:AppColors.arrowPurple),
  BentArrowData(id:16, segs:[BentCell(5,6), BentCell(6,6), BentCell(6,7), BentCell(7,7), BentCell(7,6)], escape:ArrowDir.left, color:AppColors.arrowPink),
  BentArrowData(id:17, segs:[BentCell(9,9), BentCell(9,10), BentCell(8,10), BentCell(8,9), BentCell(7,9), BentCell(7,8)], escape:ArrowDir.left, color:AppColors.arrowWhite),
  BentArrowData(id:18, segs:[BentCell(10,7), BentCell(9,7), BentCell(9,8), BentCell(10,8), BentCell(10,9)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:19, segs:[BentCell(2,7), BentCell(3,7), BentCell(3,8), BentCell(4,8)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:20, segs:[BentCell(3,10), BentCell(3,9), BentCell(2,9), BentCell(2,8)], escape:ArrowDir.left, color:AppColors.arrowYellow),
  BentArrowData(id:21, segs:[BentCell(5,10), BentCell(4,10)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:22, segs:[BentCell(8,11), BentCell(7,11), BentCell(7,10), BentCell(6,10)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:23, segs:[BentCell(4,9), BentCell(5,9), BentCell(6,9)], escape:ArrowDir.down, color:AppColors.arrowBlue),
  BentArrowData(id:24, segs:[BentCell(6,0), BentCell(6,1)], escape:ArrowDir.right, color:AppColors.arrowPurple),
];

class GameScreenLvl9 extends StatefulWidget {
  const GameScreenLvl9({super.key});
  @override
  State<GameScreenLvl9> createState() => _GameScreenLvl9State();
}

class _GameScreenLvl9State extends State<GameScreenLvl9>
    with BentLevelStateMixin<GameScreenLvl9> {
  @override int get levelNumber => 9;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl10();

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
    'Level 9 · Oval · 13×13',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
