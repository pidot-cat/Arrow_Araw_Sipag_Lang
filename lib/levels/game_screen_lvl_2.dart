// lib/levels/game_screen_lvl_2.dart
// Level 2 — 6×6 Grid — Circle Shape
// Arrows: 20 — verified solvable in order 0→19

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_3.dart';

const int _rows = 6, _cols = 6;

const Set<(int, int)> _shapeCells = {
  (0, 1),
  (0, 2),
  (0, 3),
  (0, 4),
  (1, 0),
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (2, 0),
  (2, 1),
  (2, 2),
  (2, 3),
  (2, 4),
  (2, 5),
  (3, 0),
  (3, 1),
  (3, 2),
  (3, 3),
  (3, 4),
  (3, 5),
  (4, 0),
  (4, 1),
  (4, 2),
  (4, 3),
  (4, 4),
  (4, 5),
  (5, 1),
  (5, 2),
  (5, 3),
  (5, 4),
};

List<ArrowData> _buildArrows() => [
  ArrowData(id:0, row:0, col:4, dir:ArrowDir.right, length:1, color:AppColors.arrowRed),
  ArrowData(id:1, row:0, col:1, dir:ArrowDir.up, length:1, color:AppColors.arrowOrange),
  ArrowData(id:2, row:0, col:2, dir:ArrowDir.up, length:1, color:AppColors.arrowYellow),
  ArrowData(id:3, row:0, col:3, dir:ArrowDir.up, length:1, color:AppColors.arrowGreen),
  ArrowData(id:4, row:1, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowCyan),
  ArrowData(id:5, row:1, col:4, dir:ArrowDir.right, length:2, color:AppColors.arrowBlue),
  ArrowData(id:6, row:1, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowPurple),
  ArrowData(id:7, row:2, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowPink),
  ArrowData(id:8, row:2, col:4, dir:ArrowDir.right, length:2, color:AppColors.arrowWhite),
  ArrowData(id:9, row:2, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:10, row:3, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowOrange),
  ArrowData(id:11, row:3, col:4, dir:ArrowDir.right, length:2, color:AppColors.arrowYellow),
  ArrowData(id:12, row:3, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowGreen),
  ArrowData(id:13, row:4, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowCyan),
  ArrowData(id:14, row:4, col:4, dir:ArrowDir.right, length:2, color:AppColors.arrowBlue),
  ArrowData(id:15, row:4, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowPurple),
  ArrowData(id:16, row:5, col:1, dir:ArrowDir.left, length:1, color:AppColors.arrowPink),
  ArrowData(id:17, row:5, col:2, dir:ArrowDir.down, length:1, color:AppColors.arrowWhite),
  ArrowData(id:18, row:5, col:3, dir:ArrowDir.down, length:1, color:AppColors.arrowRed),
  ArrowData(id:19, row:5, col:4, dir:ArrowDir.down, length:1, color:AppColors.arrowOrange),
];

class GameScreenLvl2 extends StatefulWidget {
  const GameScreenLvl2({super.key});
  @override
  State<GameScreenLvl2> createState() => _GameScreenLvl2State();
}

class _GameScreenLvl2State extends State<GameScreenLvl2>
    with LevelStateMixin<GameScreenLvl2> {
  @override int get levelNumber => 2;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<ArrowData> Function() get buildArrowsFn => _buildArrows;
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