// lib/levels/game_screen_lvl_4.dart
// Level 4 — 8×8 Grid — SQUARE shape — 30 arrows (outline only)

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/game_over_overlay.dart';
import '../widgets/victory_overlay.dart';
import 'level_base.dart';
import 'game_screen_lvl_5.dart';

const int _rows = 8, _cols = 8;

// Square outline — all perimeter cells
const Set<(int, int)> _shapeCells = {
  (0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),(0,7),
  (1,0),(1,7),
  (2,0),(2,7),
  (3,0),(3,7),
  (4,0),(4,7),
  (5,0),(5,7),
  (6,0),(6,7),
  (7,0),(7,1),(7,2),(7,3),(7,4),(7,5),(7,6),(7,7),
};

List<BentArrowData> _buildArrows() => [
  // Top row — exits up
  BentArrowData(id:0,  segs:[BentCell(0,0)], escape:ArrowDir.up,    color:AppColors.arrowRed),
  BentArrowData(id:1,  segs:[BentCell(0,1)], escape:ArrowDir.up,    color:AppColors.arrowOrange),
  BentArrowData(id:2,  segs:[BentCell(0,2)], escape:ArrowDir.up,    color:AppColors.arrowYellow),
  BentArrowData(id:3,  segs:[BentCell(0,3)], escape:ArrowDir.up,    color:AppColors.arrowGreen),
  BentArrowData(id:4,  segs:[BentCell(0,4)], escape:ArrowDir.up,    color:AppColors.arrowCyan),
  BentArrowData(id:5,  segs:[BentCell(0,5)], escape:ArrowDir.up,    color:AppColors.arrowBlue),
  BentArrowData(id:6,  segs:[BentCell(0,6)], escape:ArrowDir.up,    color:AppColors.arrowPurple),
  BentArrowData(id:7,  segs:[BentCell(0,7)], escape:ArrowDir.up,    color:AppColors.arrowPink),
  // Right column — exits right
  BentArrowData(id:8,  segs:[BentCell(1,7)], escape:ArrowDir.right, color:AppColors.arrowRed),
  BentArrowData(id:9,  segs:[BentCell(2,7)], escape:ArrowDir.right, color:AppColors.arrowOrange),
  BentArrowData(id:10, segs:[BentCell(3,7)], escape:ArrowDir.right, color:AppColors.arrowYellow),
  BentArrowData(id:11, segs:[BentCell(4,7)], escape:ArrowDir.right, color:AppColors.arrowGreen),
  BentArrowData(id:12, segs:[BentCell(5,7)], escape:ArrowDir.right, color:AppColors.arrowCyan),
  BentArrowData(id:13, segs:[BentCell(6,7)], escape:ArrowDir.right, color:AppColors.arrowBlue),
  // Bottom row — exits down
  BentArrowData(id:14, segs:[BentCell(7,7)], escape:ArrowDir.down,  color:AppColors.arrowPurple),
  BentArrowData(id:15, segs:[BentCell(7,6)], escape:ArrowDir.down,  color:AppColors.arrowPink),
  BentArrowData(id:16, segs:[BentCell(7,5)], escape:ArrowDir.down,  color:AppColors.arrowRed),
  BentArrowData(id:17, segs:[BentCell(7,4)], escape:ArrowDir.down,  color:AppColors.arrowOrange),
  BentArrowData(id:18, segs:[BentCell(7,3)], escape:ArrowDir.down,  color:AppColors.arrowYellow),
  BentArrowData(id:19, segs:[BentCell(7,2)], escape:ArrowDir.down,  color:AppColors.arrowGreen),
  BentArrowData(id:20, segs:[BentCell(7,1)], escape:ArrowDir.down,  color:AppColors.arrowCyan),
  BentArrowData(id:21, segs:[BentCell(7,0)], escape:ArrowDir.down,  color:AppColors.arrowBlue),
  // Left column — exits left
  BentArrowData(id:22, segs:[BentCell(6,0)], escape:ArrowDir.left,  color:AppColors.arrowPurple),
  BentArrowData(id:23, segs:[BentCell(5,0)], escape:ArrowDir.left,  color:AppColors.arrowPink),
  BentArrowData(id:24, segs:[BentCell(4,0)], escape:ArrowDir.left,  color:AppColors.arrowRed),
  BentArrowData(id:25, segs:[BentCell(3,0)], escape:ArrowDir.left,  color:AppColors.arrowOrange),
  BentArrowData(id:26, segs:[BentCell(2,0)], escape:ArrowDir.left,  color:AppColors.arrowYellow),
  BentArrowData(id:27, segs:[BentCell(1,0)], escape:ArrowDir.left,  color:AppColors.arrowGreen),
  // 2 inner L-bends to reach 30 total
  BentArrowData(id:28, segs:[BentCell(2,1),BentCell(2,2)], escape:ArrowDir.up,   color:AppColors.arrowCyan),
  BentArrowData(id:29, segs:[BentCell(5,5),BentCell(5,6)], escape:ArrowDir.down, color:AppColors.arrowBlue),
];

class GameScreenLvl4 extends StatefulWidget {
  const GameScreenLvl4({super.key});
  @override State<GameScreenLvl4> createState() => _State();
}

class _State extends State<GameScreenLvl4> with BentLevelStateMixin<GameScreenLvl4> {
  @override int get levelNumber => 4;
  @override int get rows => _rows;
  @override int get cols => _cols;
  @override List<BentArrowData> Function() get buildArrowsFn => _buildArrows;
  @override Widget Function() get nextLevelBuilder => () => const GameScreenLvl5();

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
          Text('Square · 8×8 · 30 Arrows',
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
