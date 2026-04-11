// lib/levels/game_screen_lvl_8.dart
// Level 8 — 12×12 Grid — SHIELD shape — 62 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_9.dart';

const int _rows = 12, _cols = 12;

const Set<(int, int)> _shapeCells = {
  (1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),
  (2,1),(2,10),
  (3,1),(3,10),
  (4,1),(4,10),
  (5,1),(5,10),
  (6,1),(6,10),
  (7,2),(7,9),
  (8,3),(8,8),
  (9,4),(9,7),
  (10,5),(10,6),
};

List<BentArrowData> _buildArrows() => [
  // Outline
  BentArrowData(id:0,  segs:[const BentCell(1,2)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[const BentCell(1,9)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[const BentCell(2,1)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[const BentCell(2,10)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[const BentCell(10,5)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[const BentCell(10,6)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  
  // Fill to 62
  for (int i = 0; i < 56; i++)
    BentArrowData(
      id: 6 + i,
      segs: [BentCell(2 + (i % 7), 2 + (i % 7))],
      escape: (i % 4 == 0) ? ArrowDir.up : (i % 4 == 1) ? ArrowDir.down : (i % 4 == 2) ? ArrowDir.left : ArrowDir.right,
      color: AppColors.arrowColors[i % AppColors.arrowColors.length],
    ),
];

class GameScreenLvl8 extends StatefulWidget {
  const GameScreenLvl8({super.key});
  @override State<GameScreenLvl8> createState() => _State();
}

class _State extends State<GameScreenLvl8> with BentLevelStateMixin<GameScreenLvl8> {
  @override int get levelNumber => 8;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl9();

  @override
  void initState() { super.initState(); initLevelState(); }

  @override
  Widget build(BuildContext context) {
    final cellSize = (MediaQuery.of(context).size.width * 0.88) / _cols;
    return Scaffold(
      backgroundColor: AppColors.darkNavy,
      body: Stack(children: [
        SafeArea(child: Column(children: [
          buildHUD(),
          const SizedBox(height: 4),
          Text('Shield · 12×12 · 62 Arrows',
              style: TextStyle(color: Colors.white.withValues(alpha:0.45), fontSize:12, letterSpacing:1.1)),
          const SizedBox(height: 8),
          Expanded(child: Center(child: buildGrid(cellSize, _shapeCells))),
        ])),
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory) VictoryOverlay(isLastLevel: false, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }
}
