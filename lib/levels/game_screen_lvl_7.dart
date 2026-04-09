// lib/levels/game_screen_lvl_7.dart
// Level 7 — 11×11 Grid — Triangle Shape
// 25 bent arrows — solvable in order 0→24

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_8.dart';

const int _rows = 11, _cols = 11;

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
  (2,1),
  (2,2),
  (2,3),
  (2,4),
  (2,5),
  (2,6),
  (2,7),
  (2,8),
  (2,9),
  (3,1),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (3,6),
  (3,7),
  (3,8),
  (3,9),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (4,6),
  (4,7),
  (4,8),
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
  (6,6),
  (6,7),
  (7,3),
  (7,4),
  (7,5),
  (7,6),
  (7,7),
  (8,4),
  (8,5),
  (8,6),
  (9,4),
  (9,5),
  (9,6),
  (10,5),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(10,5), BentCell(9,5), BentCell(9,4)], escape:ArrowDir.left, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(3,9), BentCell(2,9), BentCell(1,9), BentCell(1,10)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(2,1), BentCell(3,1)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(1,0), BentCell(0,0), BentCell(0,1), BentCell(1,1)], escape:ArrowDir.down, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(7,3), BentCell(6,3), BentCell(5,3), BentCell(5,2)], escape:ArrowDir.left, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(1,3), BentCell(1,2), BentCell(0,2)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(4,2), BentCell(3,2), BentCell(2,2)], escape:ArrowDir.up, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(5,6), BentCell(6,6), BentCell(7,6), BentCell(7,7)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(3,8), BentCell(4,8), BentCell(5,8), BentCell(5,7), BentCell(6,7)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(0,8), BentCell(1,8), BentCell(2,8)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(1,5), BentCell(1,4)], escape:ArrowDir.left, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(0,4), BentCell(0,3)], escape:ArrowDir.left, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(4,3), BentCell(3,3), BentCell(2,3)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(3,4), BentCell(2,4)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:14, segs:[BentCell(5,4), BentCell(4,4)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:15, segs:[BentCell(7,4), BentCell(6,4)], escape:ArrowDir.up, color:AppColors.arrowPurple),
  BentArrowData(id:16, segs:[BentCell(0,6), BentCell(0,5)], escape:ArrowDir.left, color:AppColors.arrowPink),
  BentArrowData(id:17, segs:[BentCell(3,6), BentCell(3,5), BentCell(2,5)], escape:ArrowDir.up, color:AppColors.arrowWhite),
  BentArrowData(id:18, segs:[BentCell(7,5), BentCell(6,5), BentCell(5,5), BentCell(4,5)], escape:ArrowDir.up, color:AppColors.arrowRed),
  BentArrowData(id:19, segs:[BentCell(4,7), BentCell(4,6)], escape:ArrowDir.left, color:AppColors.arrowOrange),
  BentArrowData(id:20, segs:[BentCell(0,7), BentCell(1,7), BentCell(2,7), BentCell(3,7)], escape:ArrowDir.down, color:AppColors.arrowYellow),
  BentArrowData(id:21, segs:[BentCell(0,10), BentCell(0,9)], escape:ArrowDir.left, color:AppColors.arrowGreen),
  BentArrowData(id:22, segs:[BentCell(2,6), BentCell(1,6)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:23, segs:[BentCell(9,6), BentCell(8,6)], escape:ArrowDir.up, color:AppColors.arrowBlue),
  BentArrowData(id:24, segs:[BentCell(8,4), BentCell(8,5)], escape:ArrowDir.right, color:AppColors.arrowPurple),
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
    'Level 7 · Triangle · 11×11',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
