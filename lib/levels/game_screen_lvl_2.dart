// lib/levels/game_screen_lvl_2.dart
// Level 2 — 6×6 Grid — CIRCLE shape — 20 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_3.dart';

const int _rows = 6, _cols = 6;

const Set<(int, int)> _shapeCells = {
  (0,2),(0,3),
  (1,1),(1,4),
  (2,0),(2,5),
  (3,0),(3,5),
  (4,1),(4,4),
  (5,2),(5,3),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0,  segs:[const BentCell(0,2)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[const BentCell(0,3)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[const BentCell(1,1)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[const BentCell(1,4)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[const BentCell(2,0)], escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[const BentCell(3,0)], escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[const BentCell(2,5)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[const BentCell(3,5)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[const BentCell(5,2)], escape:ArrowDir.down,  color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[const BentCell(5,3)], escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[const BentCell(4,1)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[const BentCell(4,4)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[const BentCell(1,2), const BentCell(1,3)], escape:ArrowDir.up,    color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[const BentCell(4,2), const BentCell(4,3)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  BentArrowData(id:14, segs:[const BentCell(2,1), const BentCell(3,1)], escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[const BentCell(2,4), const BentCell(3,4)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:16, segs:[const BentCell(2,2)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:17, segs:[const BentCell(2,3)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:18, segs:[const BentCell(3,2)], escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[const BentCell(3,3)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
];

class GameScreenLvl2 extends StatefulWidget {
  const GameScreenLvl2({super.key});
  @override State<GameScreenLvl2> createState() => _State();
}

class _State extends State<GameScreenLvl2> with BentLevelStateMixin<GameScreenLvl2> {
  @override int get levelNumber => 2;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl3();

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
          Text('Circle · 6×6 · 20 Arrows',
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
