// lib/levels/game_screen_lvl_6.dart
// Level 6 — 10×10 Grid — HEXAGON shape — 45 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_7.dart';

const int _rows = 10, _cols = 10;

const Set<(int, int)> _shapeCells = {
  (1,3),(1,4),(1,5),(1,6),
  (2,2),(2,3),(2,4),(2,5),(2,6),(2,7),
  (3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),
  (4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),
  (5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),
  (6,2),(6,3),(6,4),(6,5),(6,6),(6,7),
  (7,3),(7,4),(7,5),(7,6),
};

List<BentArrowData> _buildArrows() => [
  // Top edge
  BentArrowData(id:0,  segs:[const BentCell(1,3)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[const BentCell(1,4)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[const BentCell(1,5)], escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[const BentCell(1,6)], escape:ArrowDir.up,    color:AppColors.arrowGreen),
  // Sides
  BentArrowData(id:4,  segs:[const BentCell(2,2)], escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[const BentCell(3,1)], escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[const BentCell(4,1)], escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[const BentCell(5,1)], escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[const BentCell(2,7)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[const BentCell(3,8)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[const BentCell(4,8)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[const BentCell(5,8)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  // Bottom edge
  BentArrowData(id:12, segs:[const BentCell(7,3)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[const BentCell(7,4)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  BentArrowData(id:14, segs:[const BentCell(7,5)], escape:ArrowDir.down,  color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[const BentCell(7,6)], escape:ArrowDir.down,  color:AppColors.arrowPink),
  
  // Internal (filling to 45)
  for (int i = 0; i < 29; i++)
    BentArrowData(
      id: 16 + i,
      segs: [BentCell(2 + (i % 5), 3 + (i % 4))],
      escape: (i % 2 == 0) ? ArrowDir.up : ArrowDir.down,
      color: AppColors.arrowColors[i % AppColors.arrowColors.length],
    ),
];

class GameScreenLvl6 extends StatefulWidget {
  const GameScreenLvl6({super.key});
  @override State<GameScreenLvl6> createState() => _State();
}

class _State extends State<GameScreenLvl6> with BentLevelStateMixin<GameScreenLvl6> {
  @override int get levelNumber => 6;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl7();

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
          Text('Hexagon · 10×10 · 45 Arrows',
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
