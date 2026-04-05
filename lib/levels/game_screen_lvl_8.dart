// lib/levels/game_screen_lvl_8.dart
// Level 8 — 12×12 Grid — Octagon Shape
// Arrows: 58 — verified solvable in order 0→57

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_9.dart';

const int _rows = 12, _cols = 12;

const Set<(int, int)> _shapeCells = {
  (0, 3),
  (0, 4),
  (0, 5),
  (0, 6),
  (0, 7),
  (0, 8),
  (1, 2),
  (1, 3),
  (1, 4),
  (1, 5),
  (1, 6),
  (1, 7),
  (1, 8),
  (1, 9),
  (2, 1),
  (2, 2),
  (2, 3),
  (2, 4),
  (2, 5),
  (2, 6),
  (2, 7),
  (2, 8),
  (2, 9),
  (2, 10),
  (3, 0),
  (3, 1),
  (3, 2),
  (3, 3),
  (3, 4),
  (3, 5),
  (3, 6),
  (3, 7),
  (3, 8),
  (3, 9),
  (3, 10),
  (3, 11),
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
  (10, 2),
  (10, 3),
  (10, 4),
  (10, 5),
  (10, 6),
  (10, 7),
  (10, 8),
  (10, 9),
  (11, 3),
  (11, 4),
  (11, 5),
  (11, 6),
  (11, 7),
  (11, 8),
};

List<ArrowData> _buildArrows() => [
  ArrowData(id:0, row:0, col:8, dir:ArrowDir.right, length:1, color:AppColors.arrowRed),
  ArrowData(id:1, row:0, col:3, dir:ArrowDir.up, length:1, color:AppColors.arrowOrange),
  ArrowData(id:2, row:0, col:4, dir:ArrowDir.up, length:1, color:AppColors.arrowYellow),
  ArrowData(id:3, row:0, col:5, dir:ArrowDir.up, length:1, color:AppColors.arrowGreen),
  ArrowData(id:4, row:0, col:6, dir:ArrowDir.up, length:1, color:AppColors.arrowCyan),
  ArrowData(id:5, row:0, col:7, dir:ArrowDir.up, length:1, color:AppColors.arrowBlue),
  ArrowData(id:6, row:1, col:2, dir:ArrowDir.left, length:1, color:AppColors.arrowPurple),
  ArrowData(id:7, row:1, col:9, dir:ArrowDir.right, length:1, color:AppColors.arrowPink),
  ArrowData(id:8, row:1, col:6, dir:ArrowDir.right, length:3, color:AppColors.arrowWhite),
  ArrowData(id:9, row:1, col:3, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:10, row:2, col:1, dir:ArrowDir.left, length:1, color:AppColors.arrowOrange),
  ArrowData(id:11, row:2, col:8, dir:ArrowDir.right, length:3, color:AppColors.arrowYellow),
  ArrowData(id:12, row:2, col:5, dir:ArrowDir.right, length:3, color:AppColors.arrowGreen),
  ArrowData(id:13, row:2, col:2, dir:ArrowDir.right, length:3, color:AppColors.arrowCyan),
  ArrowData(id:14, row:3, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowBlue),
  ArrowData(id:15, row:3, col:10, dir:ArrowDir.right, length:2, color:AppColors.arrowPurple),
  ArrowData(id:16, row:3, col:7, dir:ArrowDir.right, length:3, color:AppColors.arrowPink),
  ArrowData(id:17, row:3, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowWhite),
  ArrowData(id:18, row:3, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:19, row:4, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowOrange),
  ArrowData(id:20, row:4, col:10, dir:ArrowDir.right, length:2, color:AppColors.arrowYellow),
  ArrowData(id:21, row:4, col:7, dir:ArrowDir.right, length:3, color:AppColors.arrowGreen),
  ArrowData(id:22, row:4, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowCyan),
  ArrowData(id:23, row:4, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowBlue),
  ArrowData(id:24, row:5, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowPurple),
  ArrowData(id:25, row:5, col:10, dir:ArrowDir.right, length:2, color:AppColors.arrowPink),
  ArrowData(id:26, row:5, col:7, dir:ArrowDir.right, length:3, color:AppColors.arrowWhite),
  ArrowData(id:27, row:5, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:28, row:5, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowOrange),
  ArrowData(id:29, row:6, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowYellow),
  ArrowData(id:30, row:6, col:10, dir:ArrowDir.right, length:2, color:AppColors.arrowGreen),
  ArrowData(id:31, row:6, col:7, dir:ArrowDir.right, length:3, color:AppColors.arrowCyan),
  ArrowData(id:32, row:6, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowBlue),
  ArrowData(id:33, row:6, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowPurple),
  ArrowData(id:34, row:7, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowPink),
  ArrowData(id:35, row:7, col:10, dir:ArrowDir.right, length:2, color:AppColors.arrowWhite),
  ArrowData(id:36, row:7, col:7, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:37, row:7, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowOrange),
  ArrowData(id:38, row:7, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowYellow),
  ArrowData(id:39, row:8, col:0, dir:ArrowDir.left, length:1, color:AppColors.arrowGreen),
  ArrowData(id:40, row:8, col:10, dir:ArrowDir.right, length:2, color:AppColors.arrowCyan),
  ArrowData(id:41, row:8, col:7, dir:ArrowDir.right, length:3, color:AppColors.arrowBlue),
  ArrowData(id:42, row:8, col:4, dir:ArrowDir.right, length:3, color:AppColors.arrowPurple),
  ArrowData(id:43, row:8, col:1, dir:ArrowDir.right, length:3, color:AppColors.arrowPink),
  ArrowData(id:44, row:9, col:1, dir:ArrowDir.left, length:1, color:AppColors.arrowWhite),
  ArrowData(id:45, row:9, col:8, dir:ArrowDir.right, length:3, color:AppColors.arrowRed),
  ArrowData(id:46, row:9, col:5, dir:ArrowDir.right, length:3, color:AppColors.arrowOrange),
  ArrowData(id:47, row:9, col:2, dir:ArrowDir.right, length:3, color:AppColors.arrowYellow),
  ArrowData(id:48, row:10, col:2, dir:ArrowDir.left, length:1, color:AppColors.arrowGreen),
  ArrowData(id:49, row:10, col:9, dir:ArrowDir.right, length:1, color:AppColors.arrowCyan),
  ArrowData(id:50, row:10, col:6, dir:ArrowDir.right, length:3, color:AppColors.arrowBlue),
  ArrowData(id:51, row:10, col:3, dir:ArrowDir.right, length:3, color:AppColors.arrowPurple),
  ArrowData(id:52, row:11, col:3, dir:ArrowDir.left, length:1, color:AppColors.arrowPink),
  ArrowData(id:53, row:11, col:4, dir:ArrowDir.down, length:1, color:AppColors.arrowWhite),
  ArrowData(id:54, row:11, col:5, dir:ArrowDir.down, length:1, color:AppColors.arrowRed),
  ArrowData(id:55, row:11, col:6, dir:ArrowDir.down, length:1, color:AppColors.arrowOrange),
  ArrowData(id:56, row:11, col:7, dir:ArrowDir.down, length:1, color:AppColors.arrowYellow),
  ArrowData(id:57, row:11, col:8, dir:ArrowDir.down, length:1, color:AppColors.arrowGreen),
];

class GameScreenLvl8 extends StatefulWidget {
  const GameScreenLvl8({super.key});
  @override
  State<GameScreenLvl8> createState() => _GameScreenLvl8State();
}

class _GameScreenLvl8State extends State<GameScreenLvl8>
    with LevelStateMixin<GameScreenLvl8> {
  @override int get levelNumber => 8;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<ArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl9();

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
    'Level 8 · Octagon · 12×12',
    style: TextStyle(
      color: Colors.white.withValues(alpha: 0.5),
      fontSize: 13,
      letterSpacing: 1.2),
  );
}