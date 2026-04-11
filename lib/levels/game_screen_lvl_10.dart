// lib/levels/game_screen_lvl_10.dart
// Level 10 — 14×14 Grid — CROSS shape — 66 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';

const int _rows = 14, _cols = 14;

const Set<(int, int)> _shapeCells = {
  (1,5),(1,6),(1,7),(1,8),
  (2,5),(2,6),(2,7),(2,8),
  (3,5),(3,6),(3,7),(3,8),
  (4,5),(4,6),(4,7),(4,8),
  (5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,9),(5,10),(5,11),(5,12),
  (6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,9),(6,10),(6,11),(6,12),
  (7,1),(7,2),(7,3),(7,4),(7,5),(7,6),(7,7),(7,8),(7,9),(7,10),(7,11),(7,12),
  (8,1),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7),(8,8),(8,9),(8,10),(8,11),(8,12),
  (9,5),(9,6),(9,7),(9,8),
  (10,5),(10,6),(10,7),(10,8),
  (11,5),(11,6),(11,7),(11,8),
  (12,5),(12,6),(12,7),(12,8),
};

List<BentArrowData> _buildArrows() => [
  // Outline points
  BentArrowData(id:0,  segs:[const BentCell(1,5)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[const BentCell(1,8)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[const BentCell(5,1)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[const BentCell(5,12)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[const BentCell(12,5)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[const BentCell(12,8)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  
  // Fill to 66
  for (int i = 0; i < 60; i++)
    BentArrowData(
      id: 6 + i,
      segs: [BentCell(2 + (i % 10), 2 + (i % 10))],
      escape: (i % 4 == 0) ? ArrowDir.up : (i % 4 == 1) ? ArrowDir.down : (i % 4 == 2) ? ArrowDir.left : ArrowDir.right,
      color: AppColors.arrowColors[i % AppColors.arrowColors.length],
    ),
];

class GameScreenLvl10 extends StatefulWidget {
  const GameScreenLvl10({super.key});
  @override State<GameScreenLvl10> createState() => _State();
}

class _State extends State<GameScreenLvl10> with BentLevelStateMixin<GameScreenLvl10> {
  @override int get levelNumber => 10;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl10(); // Loop or end

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
          Text('Cross · 14×14 · 66 Arrows',
              style: TextStyle(color: Colors.white.withValues(alpha:0.45), fontSize:12, letterSpacing:1.1)),
          const SizedBox(height: 8),
          Expanded(child: Center(child: buildGrid(cellSize, _shapeCells))),
        ])),
        if (gameOver) GameOverOverlay(onRetry: restart, onBack: quit),
        if (victory) VictoryOverlay(isLastLevel: true, onNext: quit, onBack: quit),
      ]),
    );
  }
}
