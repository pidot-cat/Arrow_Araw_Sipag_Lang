// lib/levels/game_screen_lvl_7.dart
// Level 7 — 11×11 Grid — HEPTAGON shape — 55 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_8.dart';

const int _rows = 11, _cols = 11;

// Heptagon: 7-sided polygon approximated on grid
const Set<(int, int)> _shapeCells = {
  (0,4),(0,5),(0,6),
  (1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),
  (2,1),(2,2),(2,3),(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),
  (3,0),(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),(3,9),(3,10),
  (4,0),(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),(4,9),(4,10),
  (5,0),(5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),(5,9),(5,10),
  (6,0),(6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),(6,8),(6,9),(6,10),
  (7,0),(7,1),(7,2),(7,3),(7,4),(7,5),(7,6),(7,7),(7,8),(7,9),
  (8,1),(8,2),(8,3),(8,4),(8,5),(8,6),(8,7),(8,8),
  (9,3),(9,4),(9,5),(9,6),(9,7),
  (10,4),(10,5),(10,6),
};

List<BentArrowData> _buildArrows() => [
  // Top edge
  BentArrowData(id:0,  segs:[BentCell(0,4)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(0,5)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(0,6)], escape:ArrowDir.up,    color:AppColors.arrowYellow),
  // Upper-left
  BentArrowData(id:3,  segs:[BentCell(1,2)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[BentCell(1,3)], escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[BentCell(2,1)], escape:ArrowDir.left,  color:AppColors.arrowBlue),
  // Upper-right
  BentArrowData(id:6,  segs:[BentCell(1,7)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[BentCell(1,8)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[BentCell(2,9)], escape:ArrowDir.right, color:AppColors.arrowRed),
  // Left edge
  BentArrowData(id:9,  segs:[BentCell(3,0)], escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[BentCell(4,0)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[BentCell(5,0)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[BentCell(6,0)], escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[BentCell(7,0)], escape:ArrowDir.left,  color:AppColors.arrowBlue),
  // Right edge
  BentArrowData(id:14, segs:[BentCell(3,10)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[BentCell(4,10)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:16, segs:[BentCell(5,10)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:17, segs:[BentCell(6,10)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  // Lower-left
  BentArrowData(id:18, segs:[BentCell(7,9)],  escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[BentCell(8,1)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:20, segs:[BentCell(8,2)],  escape:ArrowDir.left,  color:AppColors.arrowCyan),
  // Lower-right
  BentArrowData(id:21, segs:[BentCell(8,8)],  escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:22, segs:[BentCell(9,7)],  escape:ArrowDir.right, color:AppColors.arrowPurple),
  // Bottom
  BentArrowData(id:23, segs:[BentCell(9,3)],  escape:ArrowDir.down,  color:AppColors.arrowPink),
  BentArrowData(id:24, segs:[BentCell(9,4)],  escape:ArrowDir.down,  color:AppColors.arrowRed),
  BentArrowData(id:25, segs:[BentCell(9,5)],  escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:26, segs:[BentCell(9,6)],  escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:27, segs:[BentCell(10,4)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
  BentArrowData(id:28, segs:[BentCell(10,5)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:29, segs:[BentCell(10,6)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  // Inner cells to reach 55
  BentArrowData(id:30, segs:[BentCell(1,4)],  escape:ArrowDir.up,    color:AppColors.arrowPurple),
  BentArrowData(id:31, segs:[BentCell(1,5)],  escape:ArrowDir.up,    color:AppColors.arrowPink),
  BentArrowData(id:32, segs:[BentCell(1,6)],  escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:33, segs:[BentCell(2,2)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:34, segs:[BentCell(2,3)],  escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:35, segs:[BentCell(2,7)],  escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:36, segs:[BentCell(2,8)],  escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:37, segs:[BentCell(3,1)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:38, segs:[BentCell(3,9)],  escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:39, segs:[BentCell(4,1)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:40, segs:[BentCell(4,9)],  escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:41, segs:[BentCell(5,1)],  escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:42, segs:[BentCell(5,9)],  escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:43, segs:[BentCell(6,1)],  escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:44, segs:[BentCell(6,9)],  escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:45, segs:[BentCell(7,1)],  escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:46, segs:[BentCell(7,8)],  escape:ArrowDir.right, color:AppColors.arrowPurple),
  BentArrowData(id:47, segs:[BentCell(7,2)],  escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:48, segs:[BentCell(7,7)],  escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:49, segs:[BentCell(8,3)],  escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:50, segs:[BentCell(8,4)],  escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:51, segs:[BentCell(8,5)],  escape:ArrowDir.down,  color:AppColors.arrowGreen),
  BentArrowData(id:52, segs:[BentCell(8,6)],  escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:53, segs:[BentCell(8,7)],  escape:ArrowDir.down,  color:AppColors.arrowBlue),
  BentArrowData(id:54, segs:[BentCell(7,3)],  escape:ArrowDir.down,  color:AppColors.arrowPurple),
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
