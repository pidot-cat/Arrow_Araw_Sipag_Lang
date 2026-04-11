// lib/levels/game_screen_lvl_9.dart
// Level 9 — 13×13 Grid — NONAGON shape — 70 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_10.dart';

const int _rows = 13, _cols = 13;

const Set<(int, int)> _shapeCells = {
  (1,6),
  (2,4),(2,5),(2,6),(2,7),(2,8),
  (3,3),(3,9),
  (4,2),(4,10),
  (5,1),(5,11),
  (6,1),(6,11),
  (7,1),(7,11),
  (8,2),(8,10),
  (9,3),(9,9),
  (10,4),(10,5),(10,6),(10,7),(10,8),
};

List<BentArrowData> _buildArrows() => [
  // Outline
  BentArrowData(id:0,  segs:[const BentCell(1,6)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[const BentCell(2,4)], escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[const BentCell(2,8)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[const BentCell(5,1)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[const BentCell(5,11)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[const BentCell(10,4)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[const BentCell(10,8)], escape:ArrowDir.down,  color:AppColors.arrowPurple),
  
  // Fill to 70
  for (int i = 0; i < 63; i++)
    BentArrowData(
      id: 7 + i,
      segs: [BentCell(3 + (i % 7), 3 + (i % 7))],
      escape: (i % 4 == 0) ? ArrowDir.up : (i % 4 == 1) ? ArrowDir.down : (i % 4 == 2) ? ArrowDir.left : ArrowDir.right,
      color: AppColors.arrowColors[i % AppColors.arrowColors.length],
    ),
];

class GameScreenLvl9 extends StatefulWidget {
  const GameScreenLvl9({super.key});
  @override State<GameScreenLvl9> createState() => _State();
}

class _State extends State<GameScreenLvl9> with BentLevelStateMixin<GameScreenLvl9> {
  @override int get levelNumber => 9;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl10();

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
          Text('Nonagon · 13×13 · 70 Arrows',
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
