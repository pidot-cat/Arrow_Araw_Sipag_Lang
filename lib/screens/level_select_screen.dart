// lib/screens/level_select_screen.dart
// Grid of 10 level cards.  Cards are LOCKED (greyed-out padlock icon,
// non-tappable) for any level whose number exceeds
// GameProvider.highestUnlockedLevel.
//
// Unlock rule:
//   • New accounts start at highestUnlockedLevel = 1 (only Level 1 tappable).
//   • Completing Level N calls GameProvider.unlockNextLevel(N) which sets
//     highestUnlockedLevel = N + 1 and persists to both SharedPreferences
//     and the Supabase `level_progress` table.
//   • The selector rebuilds via Consumer<GameProvider> so it reflects the
//     new unlock instantly after returning from a level.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
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

  // ── Level metadata ────────────────────────────────────────────────────────
  // Shape names that match the level geometry spec.
  static const List<String> _levelNames = [
    'Heart',
    'Circle',
    'Triangle',
    'Square',
    'Pentagon',
    'Hexagon',
    'Heptagon',
    'Shield',
    'Nonagon',
    'Cross',
  ];

  // Grid dimensions displayed on each card.
  static const List<String> _levelGrids = [
    '5×5',
    '6×6',
    '7×7',
    '8×8',
    '9×9',
    '10×10',
    '11×11',
    '12×12',
    '13×13',
    '14×14',
  ];

  // Accent colour per level — pairs share a colour to form a visual difficulty
  // gradient from blue (easy) to purple (master).
  static const List<Color> _levelColors = [
    Color(0xFF1E88E5), // L1  — Blue     Easy
    Color(0xFF00C853), // L2  — Green    Easy
    Color(0xFFFFD600), // L3  — Yellow   Normal
    Color(0xFFFFD600), // L4  — Yellow   Normal
    Color(0xFFFF6D00), // L5  — Orange   Hard
    Color(0xFFFF6D00), // L6  — Orange   Hard
    Color(0xFFD50000), // L7  — Red      Expert
    Color(0xFFD50000), // L8  — Red      Expert
    Color(0xFFAA00FF), // L9  — Purple   Master
    Color(0xFFAA00FF), // L10 — Purple   Master
  ];

  // ── Level screen factory ──────────────────────────────────────────────────
  /// Returns the correct level screen widget for [level] (1-indexed).
  /// Each level screen is self-contained with its own arrow data; the generic
  /// GameScreen is NOT used.
  static Widget _levelScreen(int level) {
    switch (level) {
      case 1:  return const GameScreenLvl1();
      case 2:  return const GameScreenLvl2();
      case 3:  return const GameScreenLvl3();
      case 4:  return const GameScreenLvl4();
      case 5:  return const GameScreenLvl5();
      case 6:  return const GameScreenLvl6();
      case 7:  return const GameScreenLvl7();
      case 8:  return const GameScreenLvl8();
      case 9:  return const GameScreenLvl9();
      case 10: return const GameScreenLvl10();
      default: return const GameScreenLvl1();
    }
  }

  /// Maps a level number to a human-readable difficulty label.
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
        // Consumer<GameProvider> rebuilds the grid whenever highestUnlockedLevel
        // changes — e.g. immediately after returning from a won level.
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, _) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width > 600 ? 4 : 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final level = index + 1;
                  // A level is unlocked when its number is ≤ the player's
                  // current frontier.
                  final isUnlocked =
                      level <= gameProvider.highestUnlockedLevel;
                  return _buildLevelCard(
                      context, level, isUnlocked);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds one level card.  Locked cards show a padlock overlay and ignore
  /// tap events; unlocked cards navigate to the corresponding level screen.
  Widget _buildLevelCard(
      BuildContext context, int level, bool isUnlocked) {
    final color      = _levelColors[level - 1];
    final difficulty = _getDifficulty(level);
    final name       = _levelNames[level - 1];
    final grid       = _levelGrids[level - 1];

    // Locked levels get a muted colour so they visually recede.
    final displayColor = isUnlocked ? color : Colors.grey.shade700;

    return InkWell(
      // Locked levels are not tappable — onTap is null.
      onTap: isUnlocked
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => _levelScreen(level)),
              )
          : null,
      borderRadius: BorderRadius.circular(18),
      splashColor: isUnlocked ? color.withAlpha(60) : null,
      highlightColor: isUnlocked ? color.withAlpha(30) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // Locked cards have a darker background to signal unavailability.
          color: isUnlocked
              ? const Color(0xFF0D1B2A)
              : const Color(0xFF080F1A),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: displayColor.withAlpha(isUnlocked ? 160 : 60),
              width: 1.8),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                      color: color.withAlpha(80),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Stack(
          children: [
            // ── Level info ──────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'LVL',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withAlpha(isUnlocked ? 120 : 60),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                        fontSize: 38,
                        color: displayColor,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                        shadows: isUnlocked
                            ? [
                                Shadow(
                                    color: color.withAlpha(180),
                                    blurRadius: 12)
                              ]
                            : []),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 11,
                        color: isUnlocked
                            ? Colors.white70
                            : Colors.white.withAlpha(60)),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    grid,
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withAlpha(isUnlocked ? 100 : 40)),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: displayColor.withAlpha(isUnlocked ? 40 : 15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: displayColor
                              .withAlpha(isUnlocked ? 80 : 30),
                          width: 1),
                    ),
                    child: Text(
                      difficulty,
                      style: TextStyle(
                          fontSize: 10,
                          color: displayColor,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // ── Padlock overlay for locked levels ────────────────────────
            if (!isUnlocked)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      color: Colors.white54, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
