// lib/levels/game_screen_lvl_1.dart
// Level 1 — 5×5 Grid — HEART shape — 13 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_2.dart';

const int _rows = 5, _cols = 5;

const Set<(int, int)> _shapeCells = {
  (0,1),(0,2),(0,3),
  (1,0),(1,1),(1,2),(1,3),(1,4),
  (2,0),(2,1),(2,2),(2,3),(2,4),
  (3,1),(3,2),(3,3),
  (4,2),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0,  segs:[BentCell(0,1)],              escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(0,2)],              escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(0,3)],              escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[BentCell(1,0)],              escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[BentCell(1,1)],              escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[BentCell(1,3)],              escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[BentCell(1,4)],              escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[BentCell(2,0)],              escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[BentCell(2,4)],              escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[BentCell(3,1)],              escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[BentCell(3,3)],              escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[BentCell(1,2),BentCell(2,2)],escape:ArrowDir.up,    color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[BentCell(4,2),BentCell(3,2)],escape:ArrowDir.down,  color:AppColors.arrowCyan),
];

class GameScreenLvl1 extends StatefulWidget {
  const GameScreenLvl1({super.key});
  @override State<GameScreenLvl1> createState() => _State();
}

class _State extends State<GameScreenLvl1> with BentLevelStateMixin<GameScreenLvl1> {
  @override int get levelNumber => 1;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl2();

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
          Text('Heart · 5×5 · 13 Arrows',
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
