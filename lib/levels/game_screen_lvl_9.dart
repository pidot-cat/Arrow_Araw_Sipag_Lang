// lib/levels/game_screen_lvl_9.dart
// Level 9 — 13×13 Grid — NONAGON shape — 70 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_10.dart';

const int _rows = 13, _cols = 13;

// Nonagon: 9-sided polygon approximated on grid
const Set<(int, int)> _shapeCells = {
  (0,5),(0,6),(0,7),
  (1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),
  (2,2),(2,3),(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),(2,10),
  (3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),(3,11),
  (4,0),(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),(4,9),(4,10),(4,11),(4,12),
  (5,0),(5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,9),(5,10),(5,11),(5,12),
  (6,0),(6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,9),(6,10),(6,11),(6,12),
  (7,0),(7,1),(7,2),(7,3),(7,4),(7,5),(7,6),(7,7),(7,8),(7,9),(7,10),(7,11),(7,12),
  (8,0),(8,1),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7),(8,8),(8,9),(8,10),(8,11),(8,12),
  (9,1),(9,2),(9,3),(9,4),(9,5),(9,6),(9,7),(9,8),(9,9),(9,10),(9,11),
  (10,2),(10,3),(10,4),(10,5),(10,6),(10,7),(10,8),(10,9),(10,10),
  (11,4),(11,5),(11,6),(11,7),(11,8),
  (12,5),(12,6),(12,7),
};

List<BentArrowData> _buildArrows() => [
  // Top edge
  BentArrowData(id:0,  segs:[BentCell(0,5)],  escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(0,6)],  escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(0,7)],  escape:ArrowDir.up,    color:AppColors.arrowYellow),
  // Upper diagonal sides
  BentArrowData(id:3,  segs:[BentCell(1,3)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[BentCell(1,4)],  escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[BentCell(2,2)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[BentCell(3,1)],  escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[BentCell(1,8)],  escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[BentCell(1,9)],  escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[BentCell(2,10)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[BentCell(3,11)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  // Left edge
  BentArrowData(id:11, segs:[BentCell(4,0)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[BentCell(5,0)],  escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[BentCell(6,0)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:14, segs:[BentCell(7,0)],  escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[BentCell(8,0)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  // Right edge
  BentArrowData(id:16, segs:[BentCell(4,12)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:17, segs:[BentCell(5,12)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:18, segs:[BentCell(6,12)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[BentCell(7,12)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:20, segs:[BentCell(8,12)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  // Lower diagonal sides
  BentArrowData(id:21, segs:[BentCell(9,1)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:22, segs:[BentCell(10,2)], escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:23, segs:[BentCell(11,4)], escape:ArrowDir.down,  color:AppColors.arrowPink),
  BentArrowData(id:24, segs:[BentCell(9,11)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:25, segs:[BentCell(10,10)],escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:26, segs:[BentCell(11,8)], escape:ArrowDir.down,  color:AppColors.arrowYellow),
  // Bottom edge
  BentArrowData(id:27, segs:[BentCell(12,5)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
  BentArrowData(id:28, segs:[BentCell(12,6)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:29, segs:[BentCell(12,7)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  // Inner ring to reach 70
  BentArrowData(id:30, segs:[BentCell(1,5)],  escape:ArrowDir.up,    color:AppColors.arrowPurple),
  BentArrowData(id:31, segs:[BentCell(1,6)],  escape:ArrowDir.up,    color:AppColors.arrowPink),
  BentArrowData(id:32, segs:[BentCell(1,7)],  escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:33, segs:[BentCell(2,3)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:34, segs:[BentCell(2,4)],  escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:35, segs:[BentCell(2,8)],  escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:36, segs:[BentCell(2,9)],  escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:37, segs:[BentCell(3,2)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:38, segs:[BentCell(3,10)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:39, segs:[BentCell(4,1)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:40, segs:[BentCell(4,11)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:41, segs:[BentCell(5,1)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:42, segs:[BentCell(5,11)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:43, segs:[BentCell(6,1)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:44, segs:[BentCell(6,11)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:45, segs:[BentCell(7,1)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:46, segs:[BentCell(7,11)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:47, segs:[BentCell(8,1)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:48, segs:[BentCell(8,11)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:49, segs:[BentCell(9,2)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:50, segs:[BentCell(9,10)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:51, segs:[BentCell(9,3)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:52, segs:[BentCell(9,9)],  escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:53, segs:[BentCell(10,3)], escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:54, segs:[BentCell(10,9)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:55, segs:[BentCell(10,4)], escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:56, segs:[BentCell(10,8)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:57, segs:[BentCell(11,5)], escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:58, segs:[BentCell(11,6)], escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:59, segs:[BentCell(11,7)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
  BentArrowData(id:60, segs:[BentCell(2,5)],  escape:ArrowDir.up,    color:AppColors.arrowCyan),
  BentArrowData(id:61, segs:[BentCell(2,6)],  escape:ArrowDir.up,    color:AppColors.arrowBlue),
  BentArrowData(id:62, segs:[BentCell(2,7)],  escape:ArrowDir.up,    color:AppColors.arrowPurple),
  BentArrowData(id:63, segs:[BentCell(3,3)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:64, segs:[BentCell(3,9)],  escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:65, segs:[BentCell(3,4)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:66, segs:[BentCell(3,8)],  escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:67, segs:[BentCell(9,4)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:68, segs:[BentCell(9,8)],  escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:69, segs:[BentCell(10,5)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
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
