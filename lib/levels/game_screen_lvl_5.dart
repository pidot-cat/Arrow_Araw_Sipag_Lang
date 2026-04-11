// lib/levels/game_screen_lvl_5.dart
// Level 5 — 9×9 Grid — PENTAGON shape — 38 arrows

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_6.dart';

const int _rows = 9, _cols = 9;

// Pentagon: flat top, two diagonal sides, flat bottom
const Set<(int, int)> _shapeCells = {
  (0,3),(0,4),(0,5),
  (1,2),(1,3),(1,4),(1,5),(1,6),
  (2,1),(2,2),(2,3),(2,4),(2,5),(2,6),(2,7),
  (3,0),(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),(3,7),(3,8),
  (4,0),(4,1),(4,2),(4,3),(4,4),(4,5),(4,6),(4,7),(4,8),
  (5,0),(5,1),(5,2),(5,3),(5,4),(5,5),(5,6),(5,7),(5,8),
  (6,1),(6,2),(6,3),(6,4),(6,5),(6,6),(6,7),
  (7,2),(7,3),(7,4),(7,5),(7,6),
};

List<BentArrowData> _buildArrows() => [
  // Top edge
  BentArrowData(id:0,  segs:[BentCell(0,3)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(0,4)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(0,5)], escape:ArrowDir.up,    color:AppColors.arrowYellow),
  // Upper-left diagonal
  BentArrowData(id:3,  segs:[BentCell(1,2)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[BentCell(2,1)], escape:ArrowDir.left,  color:AppColors.arrowCyan),
  // Upper-right diagonal
  BentArrowData(id:5,  segs:[BentCell(1,6)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[BentCell(2,7)], escape:ArrowDir.right, color:AppColors.arrowPurple),
  // Left edge
  BentArrowData(id:7,  segs:[BentCell(3,0)], escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:8,  segs:[BentCell(4,0)], escape:ArrowDir.left,  color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[BentCell(5,0)], escape:ArrowDir.left,  color:AppColors.arrowOrange),
  // Right edge
  BentArrowData(id:10, segs:[BentCell(3,8)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[BentCell(4,8)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[BentCell(5,8)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  // Lower-left
  BentArrowData(id:13, segs:[BentCell(6,1)], escape:ArrowDir.left,  color:AppColors.arrowBlue),
  BentArrowData(id:14, segs:[BentCell(7,2)], escape:ArrowDir.down,  color:AppColors.arrowPurple),
  // Lower-right
  BentArrowData(id:15, segs:[BentCell(6,7)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:16, segs:[BentCell(7,6)], escape:ArrowDir.down,  color:AppColors.arrowRed),
  // Bottom edge
  BentArrowData(id:17, segs:[BentCell(7,3)], escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:18, segs:[BentCell(7,4)], escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[BentCell(7,5)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
  // Inner fill arrows to reach 38
  BentArrowData(id:20, segs:[BentCell(1,3)], escape:ArrowDir.up,    color:AppColors.arrowCyan),
  BentArrowData(id:21, segs:[BentCell(1,4)], escape:ArrowDir.up,    color:AppColors.arrowBlue),
  BentArrowData(id:22, segs:[BentCell(1,5)], escape:ArrowDir.up,    color:AppColors.arrowPurple),
  BentArrowData(id:23, segs:[BentCell(2,2)], escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:24, segs:[BentCell(2,3)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:25, segs:[BentCell(2,4)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:26, segs:[BentCell(2,5)], escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:27, segs:[BentCell(2,6)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:28, segs:[BentCell(3,1)], escape:ArrowDir.left,  color:AppColors.arrowCyan),
  BentArrowData(id:29, segs:[BentCell(3,7)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  BentArrowData(id:30, segs:[BentCell(4,1)], escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:31, segs:[BentCell(4,7)], escape:ArrowDir.right, color:AppColors.arrowPink),
  BentArrowData(id:32, segs:[BentCell(5,1)], escape:ArrowDir.left,  color:AppColors.arrowRed),
  BentArrowData(id:33, segs:[BentCell(5,7)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:34, segs:[BentCell(6,2)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:35, segs:[BentCell(6,6)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:36, segs:[BentCell(6,3)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:37, segs:[BentCell(6,5)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
];

class GameScreenLvl5 extends StatefulWidget {
  const GameScreenLvl5({super.key});
  @override State<GameScreenLvl5> createState() => _State();
}

class _State extends State<GameScreenLvl5> with BentLevelStateMixin<GameScreenLvl5> {
  @override int get levelNumber => 5;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl6();

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
          Text('Pentagon · 9×9 · 38 Arrows',
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
