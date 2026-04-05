// lib/screens/level_select_screen.dart
// FIX: Bug 1 — Routes to GameScreenLvlX screens directly instead of generic GameScreen.
// The generic GameScreen has no arrows wired; each level screen owns its own data.

import 'package:flutter/material.dart';
import '../levels/game_screen_lvl_1.dart';
import '../levels/game_screen_lvl_2.dart';
import '../levels/game_screen_lvl_3.dart';
import '../levels/game_screen_lvl_4.dart';
import '../levels/game_screen_lvl_5.dart';
import '../levels/game_screen_lvl_6.dart';
import '../levels/game_screen_lvl_7.dart';
import '../levels/game_screen_lvl_8.dart';
import '../levels/game_screen_lvl_9.dart';
import '../levels/game_screen_lvl_10.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  static const List<String> _levelNames = [
    'Heart',
    'Circle',
    'Triangle',
    'Square',
    'Pentagon',
    'Hexagon',
    'Heptagon',
    'Octagon',
    'Nonagon',
    'Decagon',
  ];

  static const List<String> _levelGrids = [
    '5×5',
    '6×6',
    '4×7',
    '8×8',
    '9×9',
    '10×10',
    '11×11',
    '12×12',
    '13×13',
    '14×14',
  ];

  static const List<Color> _levelColors = [
    Color(0xFF1E88E5), // L1  Blue
    Color(0xFF00C853), // L2  Green
    Color(0xFFFFD600), // L3  Yellow
    Color(0xFFFFD600), // L4  Yellow
    Color(0xFFFF6D00), // L5  Orange
    Color(0xFFFF6D00), // L6  Orange
    Color(0xFFD50000), // L7  Red
    Color(0xFFD50000), // L8  Red
    Color(0xFFAA00FF), // L9  Purple
    Color(0xFFAA00FF), // L10 Purple
  ];

  // FIX: each card navigates directly to the correct level screen with its own data
  static Widget _levelScreen(int level) {
    switch (level) {
      case 1:
        return const GameScreenLvl1();
      case 2:
        return const GameScreenLvl2();
      case 3:
        return const GameScreenLvl3();
      case 4:
        return const GameScreenLvl4();
      case 5:
        return const GameScreenLvl5();
      case 6:
        return const GameScreenLvl6();
      case 7:
        return const GameScreenLvl7();
      case 8:
        return const GameScreenLvl8();
      case 9:
        return const GameScreenLvl9();
      case 10:
        return const GameScreenLvl10();
      default:
        return const GameScreenLvl1();
    }
  }

  String _getDifficulty(int level) {
    if (level <= 2) return 'Easy';
    if (level <= 4) return 'Normal';
    if (level <= 6) return 'Hard';
    if (level <= 8) return 'Expert';
    return 'Master';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'SELECT LEVEL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.white.withAlpha(30)),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1628), Color(0xFF1A1A2E)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: size.width > 600 ? 4 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemCount: 10,
            itemBuilder: (context, index) =>
                _buildLevelCard(context, index + 1),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, int level) {
    final color = _levelColors[level - 1];
    final difficulty = _getDifficulty(level);
    final name = _levelNames[level - 1];
    final grid = _levelGrids[level - 1];

    return InkWell(
      // FIX: navigate to the specific level screen, not GameScreen
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _levelScreen(level)),
      ),
      borderRadius: BorderRadius.circular(18),
      splashColor: color.withAlpha(60),
      highlightColor: color.withAlpha(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: const Color(0xFF0D1B2A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withAlpha(160), width: 1.8),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(80),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('LVL',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withAlpha(120),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            Text('$level',
                style: TextStyle(
                    fontSize: 38,
                    color: color,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                    shadows: [
                      Shadow(color: color.withAlpha(180), blurRadius: 12)
                    ])),
            const SizedBox(height: 3),
            Text(name,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(grid,
                style: TextStyle(
                    fontSize: 10, color: Colors.white.withAlpha(100))),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(80), width: 1),
              ),
              child: Text(difficulty,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
          ],
        ),
      ),
    );
  }
}
