// lib/levels/game_screen_lvl_7.dart
// Level 7 — 11×11 Grid — HEPTAGON shape — 55 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_8.dart';

const int _rows = 11, _cols = 11;

const Set<(int, int)> _shapeCells = {
  (1,5),
  (2,4),(2,5),(2,6),
  (3,3),(3,4),(3,5),(3,6),(3,7),
  (4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),
  (5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,9),
  (6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,9),
  (7,2),(7,3),(7,4),(7,5),(7,6),(7,7),(7,8),
  (8,3),(8,4),(8,5),(8,6),(8,7),
};

List<BentArrowData> _buildArrows() => [
  // Outline
  BentArrowData(id:0,  segs:[const BentCell(1,5)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[const BentCell(2,4)], escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[const BentCell(2,6)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[const BentCell(5,1)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[const BentCell(5,9)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[const BentCell(8,3)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[const BentCell(8,7)], escape:ArrowDir.down,  color:AppColors.arrowPurple),
  
  // Fill to 55
  for (int i = 0; i < 48; i++)
    BentArrowData(
      id: 7 + i,
      segs: [BentCell(3 + (i % 5), 3 + (i % 5))],
      escape: (i % 4 == 0) ? ArrowDir.up : (i % 4 == 1) ? ArrowDir.down : (i % 4 == 2) ? ArrowDir.left : ArrowDir.right,
      color: AppColors.arrowColors[i % AppColors.arrowColors.length],
    ),
];

class GameScreenLvl7 extends StatefulWidget {
  const GameScreenLvl7({super.key});
  @override State<GameScreenLvl7> createState() => _State();
}

class _State extends State<GameScreenLvl7> with BentLevelStateMixin<GameScreenLvl7> {
  @override int get levelNumber => 7;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl8();

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
          Text('Heptagon · 11×11 · 55 Arrows',
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
