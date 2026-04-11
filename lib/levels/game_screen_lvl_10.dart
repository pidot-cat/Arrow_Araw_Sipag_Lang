// lib/levels/game_screen_lvl_10.dart
// Level 10 — 14×14 Grid — CROSS shape — 66 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_1.dart';

const int _rows = 14, _cols = 14;

// Cross: vertical bar + horizontal bar intersecting at centre
const Set<(int, int)> _shapeCells = {
  // Vertical bar (cols 5-8)
  (0,5),(0,6),(0,7),(0,8),
  (1,5),(1,6),(1,7),(1,8),
  (2,5),(2,6),(2,7),(2,8),
  (3,5),(3,6),(3,7),(3,8),
  (4,5),(4,6),(4,7),(4,8),
  // Horizontal bar (rows 5-8)
  (5,0),(5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,9),(5,10),(5,11),(5,12),(5,13),
  (6,0),(6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,9),(6,10),(6,11),(6,12),(6,13),
  (7,0),(7,1),(7,2),(7,3),(7,4),(7,5),(7,6),(7,7),(7,8),(7,9),(7,10),(7,11),(7,12),(7,13),
  (8,0),(8,1),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7),(8,8),(8,9),(8,10),(8,11),(8,12),(8,13),
  // Vertical bar continued (cols 5-8)
  (9,5),(9,6),(9,7),(9,8),
  (10,5),(10,6),(10,7),(10,8),
  (11,5),(11,6),(11,7),(11,8),
  (12,5),(12,6),(12,7),(12,8),
  (13,5),(13,6),(13,7),(13,8),
};

List<BentArrowData> _buildArrows() => [
  // Top of vertical bar
  BentArrowData(id:0,  segs:[BentCell(0,5)],  escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(0,6)],  escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(0,7)],  escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[BentCell(0,8)],  escape:ArrowDir.up,    color:AppColors.arrowGreen),
  // Left sides of vertical bar (above cross)
  BentArrowData(id:4,  segs:[BentCell(1,5)],  escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[BentCell(2,5)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[BentCell(3,5)],  escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[BentCell(4,5)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  // Right sides of vertical bar (above cross)
  BentArrowData(id:8,  segs:[BentCell(1,8)],  escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[BentCell(2,8)],  escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[BentCell(3,8)],  escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[BentCell(4,8)],  escape:ArrowDir.right, color:AppColors.arrowGreen),
  // Top of horizontal bar (left arm)
  BentArrowData(id:12, segs:[BentCell(5,0)],  escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[BentCell(5,1)],  escape:ArrowDir.up,    color:AppColors.arrowBlue),
  BentArrowData(id:14, segs:[BentCell(5,2)],  escape:ArrowDir.up,    color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[BentCell(5,3)],  escape:ArrowDir.up,    color:AppColors.arrowPink),
  BentArrowData(id:16, segs:[BentCell(5,4)],  escape:ArrowDir.up,    color:AppColors.arrowRed),
  // Top of horizontal bar (right arm)
  BentArrowData(id:17, segs:[BentCell(5,9)],  escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:18, segs:[BentCell(5,10)], escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[BentCell(5,11)], escape:ArrowDir.up,    color:AppColors.arrowGreen),
  BentArrowData(id:20, segs:[BentCell(5,12)], escape:ArrowDir.up,    color:AppColors.arrowCyan),
  BentArrowData(id:21, segs:[BentCell(5,13)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  // Bottom of horizontal bar (left arm)
  BentArrowData(id:22, segs:[BentCell(8,0)],  escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:23, segs:[BentCell(8,1)],  escape:ArrowDir.down,  color:AppColors.arrowPink),
  BentArrowData(id:24, segs:[BentCell(8,2)],  escape:ArrowDir.down,  color:AppColors.arrowRed),
  BentArrowData(id:25, segs:[BentCell(8,3)],  escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:26, segs:[BentCell(8,4)],  escape:ArrowDir.down,  color:AppColors.arrowYellow),
  // Bottom of horizontal bar (right arm)
  BentArrowData(id:27, segs:[BentCell(8,9)],  escape:ArrowDir.down,  color:AppColors.arrowGreen),
  BentArrowData(id:28, segs:[BentCell(8,10)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:29, segs:[BentCell(8,11)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  BentArrowData(id:30, segs:[BentCell(8,12)], escape:ArrowDir.down,  color:AppColors.arrowPurple),
  BentArrowData(id:31, segs:[BentCell(8,13)], escape:ArrowDir.right, color:AppColors.arrowPink),
  // Left sides of vertical bar (below cross)
  BentArrowData(id:32, segs:[BentCell(9,5)],  escape:ArrowDir.left,  color:AppColors.arrowRed),
  BentArrowData(id:33, segs:[BentCell(10,5)], escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:34, segs:[BentCell(11,5)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:35, segs:[BentCell(12,5)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  // Right sides of vertical bar (below cross)
  BentArrowData(id:36, segs:[BentCell(9,8)],  escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:37, segs:[BentCell(10,8)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:38, segs:[BentCell(11,8)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:39, segs:[BentCell(12,8)], escape:ArrowDir.right, color:AppColors.arrowPink),
  // Bottom of vertical bar
  BentArrowData(id:40, segs:[BentCell(13,5)], escape:ArrowDir.down,  color:AppColors.arrowRed),
  BentArrowData(id:41, segs:[BentCell(13,6)], escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:42, segs:[BentCell(13,7)], escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:43, segs:[BentCell(13,8)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
  // Inner cells — horizontal bar middle rows + vertical bar inner cols to reach 66
  BentArrowData(id:44, segs:[BentCell(6,0)],  escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:45, segs:[BentCell(6,1)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:46, segs:[BentCell(6,2)],  escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:47, segs:[BentCell(6,3)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:48, segs:[BentCell(6,4)],  escape:ArrowDir.left,  color:AppColors.arrowRed),
  BentArrowData(id:49, segs:[BentCell(6,9)],  escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:50, segs:[BentCell(6,10)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:51, segs:[BentCell(6,11)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:52, segs:[BentCell(6,12)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:53, segs:[BentCell(6,13)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:54, segs:[BentCell(7,0)],  escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:55, segs:[BentCell(7,1)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:56, segs:[BentCell(7,2)],  escape:ArrowDir.left,  color:AppColors.arrowRed),
  BentArrowData(id:57, segs:[BentCell(7,3)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:58, segs:[BentCell(7,4)],  escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:59, segs:[BentCell(7,9)],  escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:60, segs:[BentCell(7,10)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:61, segs:[BentCell(7,11)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:62, segs:[BentCell(7,12)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:63, segs:[BentCell(7,13)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:64, segs:[BentCell(1,6)],  escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:65, segs:[BentCell(1,7)],  escape:ArrowDir.up,    color:AppColors.arrowOrange),
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
  // After Level 10, loop back to Level 1 for free replay
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl1();

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
        // isLastLevel: true — VictoryOverlay shows "All Levels Complete!" message
        if (victory) VictoryOverlay(isLastLevel: true, onNext: goNextLevel, onBack: quit),
      ]),
    );
  }
}
