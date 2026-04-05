// lib/levels/game_screen_lvl_4.dart
// Level 4 — 8×8 Grid — Square Shape
// Arrows: 40 — verified solvable in order 0→39

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_5.dart';

const int _rows = 8, _cols = 8;

const Set<(int, int)> _shapeCells = {
  (0, 0),
  (0, 1),
  (0, 2),
  (0, 3),
  (0, 4),
  (0, 5),
  (0, 6),
  (0, 7),
  (1, 0),
  (1, 1),
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 7),
  (2, 0),
  (2, 1),
  (2, 2),
  (2, 3),
  (2, 4),
  (2, 5),
  (2, 6),
  (2, 7),
  (3, 0),
  (3, 1),
  (3, 2),
  (3, 3),
  (3, 4),
  (3, 5),
  (3, 6),
  (3, 7),
  (4, 0),
  (4, 1),
  (4, 2),
  (4, 3),
  (4, 4),
  (4, 5),
  (4, 6),
  (4, 7),
  (5, 0),
  (5, 1),
  (5, 2),
  (5, 3),
  (5, 4),
  (5, 5),
  (5, 6),
  (5, 7),
  (6, 0),
  (6, 1),
  (6, 2),
  (6, 3),
  (6, 4),
  (6, 5),
  (6, 6),
  (6, 7),
  (7, 0),
  (7, 1),
  (7, 2),
  (7, 3),
  (7, 4),
  (7, 5),
  (7, 6),
  (7, 7),
};

List<ArrowData> _buildArrows() => [
  ArrowData(id:0, row:0, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowRed),
  ArrowData(id:1, row:0, col:0, dir:ArrowDir.up, length:1, color:AppColors.arrowOrange),
  ArrowData(id:2, row:0, col:1, dir:ArrowDir.up, length:1, color:AppColors.arrowYellow),
  ArrowData(id:3, row:0, col:2, dir:ArrowDir.up, length:1, color:AppColors.arrowGreen),
  ArrowData(id:4, row:0, col:3, dir:ArrowDir.up, length:1, color:AppColors.arrowCyan),
  ArrowData(id:5, row:0, col:4, dir:ArrowDir.up, length:1, color:AppColors.arrowBlue),
  ArrowData(id:6, row:0, col:5, dir:ArrowDir.up, length:1, color:AppColors.arrowPurple),
  ArrowData(id:7, row:0, col:6, dir:ArrowDir.up, length:1, color:AppColors.arrowPink),
  ArrowData(id:8, row:1, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowWhite),
  ArrowData(id:9, row:1, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowRed),
  ArrowData(id:10, row:1, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowOrange),
  ArrowData(id:11, row:1, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowYellow),
  ArrowData(id:12, row:2, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowGreen),
  ArrowData(id:13, row:2, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowCyan),
  ArrowData(id:14, row:2, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowBlue),
  ArrowData(id:15, row:2, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowPurple),
  ArrowData(id:16, row:3, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowPink),
  ArrowData(id:17, row:3, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowWhite),
  ArrowData(id:18, row:3, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:19, row:3, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowOrange),
  ArrowData(id:20, row:4, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowYellow),
  ArrowData(id:21, row:4, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowGreen),
  ArrowData(id:22, row:4, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowCyan),
  ArrowData(id:23, row:4, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowBlue),
  ArrowData(id:24, row:5, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowPurple),
  ArrowData(id:25, row:5, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowPink),
  ArrowData(id:26, row:5, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowWhite),
  ArrowData(id:27, row:5, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:28, row:6, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowOrange),
  ArrowData(id:29, row:6, col:7, dir:ArrowDir.right, length:1, color:AppColors.arrowYellow),
  ArrowData(id:30, row:6, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowGreen),
  ArrowData(id:31, row:6, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowCyan),
  ArrowData(id:32, row:7, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowBlue),
  ArrowData(id:33, row:7, col:1, dir:ArrowDir.down, length:1, color:AppColors.arrowPurple),
  ArrowData(id:34, row:7, col:2, dir:ArrowDir.down, length:1, color:AppColors.arrowPink),
  ArrowData(id:35, row:7, col:3, dir:ArrowDir.down, length:1, color:AppColors.arrowWhite),
  ArrowData(id:36, row:7, col:4, dir:ArrowDir.down, length:1, color:AppColors.arrowRed),
  ArrowData(id:37, row:7, col:5, dir:ArrowDir.down, length:1, color:AppColors.arrowOrange),
  ArrowData(id:38, row:7, col:6, dir:ArrowDir.down, length:1, color:AppColors.arrowYellow),
  ArrowData(id:39, row:7, col:7, dir:ArrowDir.down, length:1, color:AppColors.arrowGreen),
];

class GameScreenLvl4 extends StatefulWidget {
  const GameScreenLvl4({super.key});
  @override
  State<GameScreenLvl4> createState() => _GameScreenLvl4State();
}

class _GameScreenLvl4State extends State<GameScreenLvl4>
    with LevelStateMixin<GameScreenLvl4> {
  @override int get levelNumber => 4;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<ArrowData> Function() get buildArrowsFn => _buildArrows;
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
    'Level 4 · Square · 8×8',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}