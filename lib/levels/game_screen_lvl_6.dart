// lib/levels/game_screen_lvl_6.dart
// Level 6 — 10×10 Grid — Hexagon Shape
// 14 bent arrows — solvable in order 0→13

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_7.dart';

const int _rows = 10, _cols = 10;

const Set<(int, int)> _shapeCells = {
  (1,4),
  (1,5),
  (2,3),
  (2,4),
  (2,5),
  (2,6),
  (3,2),
  (3,3),
  (3,4),
  (3,5),
  (3,6),
  (3,7),
  (4,1),
  (4,2),
  (4,3),
  (4,4),
  (4,5),
  (4,6),
  (4,7),
  (4,8),
  (5,1),
  (5,2),
  (5,3),
  (5,4),
  (5,5),
  (5,6),
  (5,7),
  (5,8),
  (6,2),
  (6,3),
  (6,4),
  (6,5),
  (6,6),
  (6,7),
  (7,3),
  (7,4),
  (7,5),
  (7,6),
  (8,4),
  (8,5),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0, segs:[BentCell(4,8), BentCell(5,8), BentCell(5,7), BentCell(6,7)], escape:ArrowDir.down, color:AppColors.arrowRed),
  BentArrowData(id:1, segs:[BentCell(3,7), BentCell(4,7)], escape:ArrowDir.down, color:AppColors.arrowOrange),
  BentArrowData(id:2, segs:[BentCell(5,1), BentCell(4,1), BentCell(4,2), BentCell(3,2)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:3, segs:[BentCell(2,3), BentCell(2,4), BentCell(1,4)], escape:ArrowDir.up, color:AppColors.arrowGreen),
  BentArrowData(id:4, segs:[BentCell(4,3), BentCell(3,3)], escape:ArrowDir.up, color:AppColors.arrowCyan),
  BentArrowData(id:5, segs:[BentCell(7,5), BentCell(8,5), BentCell(8,4)], escape:ArrowDir.left, color:AppColors.arrowBlue),
  BentArrowData(id:6, segs:[BentCell(6,6), BentCell(7,6)], escape:ArrowDir.down, color:AppColors.arrowPurple),
  BentArrowData(id:7, segs:[BentCell(4,6), BentCell(5,6)], escape:ArrowDir.down, color:AppColors.arrowPink),
  BentArrowData(id:8, segs:[BentCell(1,5), BentCell(2,5), BentCell(2,6), BentCell(3,6)], escape:ArrowDir.down, color:AppColors.arrowWhite),
  BentArrowData(id:9, segs:[BentCell(4,4), BentCell(5,4), BentCell(5,5)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:10, segs:[BentCell(6,2), BentCell(5,2), BentCell(5,3)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:11, segs:[BentCell(7,3), BentCell(6,3)], escape:ArrowDir.up, color:AppColors.arrowYellow),
  BentArrowData(id:12, segs:[BentCell(7,4), BentCell(6,4), BentCell(6,5)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:13, segs:[BentCell(3,4), BentCell(3,5), BentCell(4,5)], escape:ArrowDir.down, color:AppColors.arrowCyan),
];

class GameScreenLvl6 extends StatefulWidget {
  const GameScreenLvl6({super.key});
  @override
  State<GameScreenLvl6> createState() => _GameScreenLvl6State();
}

class _GameScreenLvl6State extends State<GameScreenLvl6>
    with BentLevelStateMixin<GameScreenLvl6> {
  @override int get levelNumber => 6;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl7();

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
    'Level 6 · Hexagon · 10×10',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}
