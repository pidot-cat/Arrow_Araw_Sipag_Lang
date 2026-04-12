// lib/levels/game_screen_lvl_10.dart
// Level 10 — Solid Square — Level10Manager

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'level_manager.dart';


Set<(int, int)> _allCells(int rows, int cols) {
  final s = <(int, int)>{};
  for (int r = 0; r < rows; r++)
    for (int c = 0; c < cols; c++) s.add((r, c));
  return s;
}

class GameScreenLvl10 extends StatefulWidget {
  const GameScreenLvl10({super.key});
  @override
  State<GameScreenLvl10> createState() => _State();
}

class _State extends State<GameScreenLvl10> with BentLevelStateMixin<GameScreenLvl10> {
  @override int get levelNumber => 10;
  @override int get rows => Level10Manager.rows;
  @override int get cols => Level10Manager.cols;
  @override List<BentArrowData> Function() get buildArrowsFn => Level10Manager.build;
  @override Widget Function() get nextLevelBuilder =>
      () => const GameScreenLvl10();

  @override
  void initState() { super.initState(); initLevelState(); }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width * 0.88) / Level10Manager.cols;
    final shape = _allCells(rows, cols);
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(children: [
        SafeArea(child: Column(children: [
          buildHUD(),
          const SizedBox(height: 4),
          Text('Solid Square · ${rows}×$cols · ${Level10Manager.build().length} Arrows',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12, letterSpacing: 1.1)),
          const SizedBox(height: 8),
          Expanded(child: Center(child: buildGrid(cellSize, shape))),
        ])),
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory) VictoryOverlay(isLastLevel: true, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }
}
