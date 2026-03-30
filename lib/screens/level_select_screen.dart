import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  // Spec: L1=Heart, L2=Circle, L3=Triangle, L4=Square, L5=Pentagon,
  //       L6=Hexagon, L7=Heptagon, L8=Octagon, L9=Nonagon, L10=Decagon
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

  // Spec: L1=Blue, L2=Green, 3-4=Yellow, 5-6=Orange, 7-8=Red, 9-10=Purple
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
      // Blue/Black theme
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
          child: Container(
            height: 1,
            color: Colors.white.withAlpha(30),
          ),
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
              childAspectRatio: 1.05,
            ),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildLevelCard(context, index + 1);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, int level) {
    final color = _levelColors[level - 1];
    final difficulty = _getDifficulty(level);
    final name = _levelNames[level - 1];

    return InkWell(
      onTap: () {
        context.read<GameProvider>().initLevel(level);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GameScreen()),
        );
      },
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
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'LVL',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withAlpha(120),
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              '$level',
              style: TextStyle(
                fontSize: 40,
                color: color,
                fontWeight: FontWeight.bold,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: color.withAlpha(180),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withAlpha(80), width: 1),
              ),
              child: Text(
                difficulty,
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
