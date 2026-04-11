// lib/levels/game_screen_lvl_3.dart
// Level 3 — 7×7 Grid — TRIANGLE shape — 25 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_4.dart';

const int _rows = 7, _cols = 7;

// Triangle: apex at top-centre, widens to base at bottom row
const Set<(int, int)> _shapeCells = {
  (0,3),
  (1,2),(1,3),(1,4),
  (2,1),(2,2),(2,3),(2,4),(2,5),
  (3,1),(3,2),(3,3),(3,4),(3,5),
  (4,0),(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),
  (5,0),(5,1),(5,2),(5,3),(5,4),(5,5),(5,6),
};

List<BentArrowData> _buildArrows() => [
  BentArrowData(id:0,  segs:[BentCell(0,3)],               escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(1,2)],               escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(1,4)],               escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[BentCell(2,1)],               escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[BentCell(2,5)],               escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[BentCell(3,1)],               escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[BentCell(3,5)],               escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[BentCell(4,0)],               escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[BentCell(4,6)],               escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[BentCell(5,0)],               escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[BentCell(5,6)],               escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[BentCell(1,3)],               escape:ArrowDir.up,    color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[BentCell(2,2)],               escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[BentCell(2,3)],               escape:ArrowDir.up,    color:AppColors.arrowBlue),
  BentArrowData(id:14, segs:[BentCell(2,4)],               escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[BentCell(3,2)],               escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:16, segs:[BentCell(3,3)],               escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:17, segs:[BentCell(3,4)],               escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:18, segs:[BentCell(4,1)],               escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[BentCell(4,2)],               escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:20, segs:[BentCell(4,3)],               escape:ArrowDir.up,    color:AppColors.arrowCyan),
  BentArrowData(id:21, segs:[BentCell(4,4)],               escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:22, segs:[BentCell(4,5)],               escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:23, segs:[BentCell(5,1)],               escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:24, segs:[BentCell(5,5)],               escape:ArrowDir.right, color:AppColors.arrowRed),
];

class GameScreenLvl3 extends StatefulWidget {
  const GameScreenLvl3({super.key});
  @override State<GameScreenLvl3> createState() => _State();
}

class _State extends State<GameScreenLvl3> with BentLevelStateMixin<GameScreenLvl3> {
  @override int get levelNumber => 3;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl4();

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
          Text('Triangle · 7×7 · 25 Arrows',
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
