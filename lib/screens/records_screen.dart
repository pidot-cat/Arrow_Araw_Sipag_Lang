// lib/screens/records_screen.dart
// Compact records screen — max-height 60dp stat rows, accurate stats display.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background_wrapper.dart';
import '../providers/game_provider.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().refreshStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: Consumer<GameProvider>(
          builder: (context, gp, _) {
            final stats = gp.stats;
            final winRate = stats.totalMatches > 0
                ? (stats.totalWins / stats.totalMatches * 100)
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.03),
                  Image.asset(AppConstants.logoWithBg, width: 140, height: 140),
                  const SizedBox(height: 10),
                  const Text(
                    'Records',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2),
                  ),
                  SizedBox(height: size.height * 0.02),

                  // ── Compact stat rows (max-height 60dp) ──────────────────
                  _compactStat('Wins',    '${stats.totalWins}',    Colors.greenAccent,  Icons.emoji_events_rounded),
                  const SizedBox(height: 8),
                  _compactStat('Losses',  '${stats.totalLosses}',  Colors.redAccent,    Icons.close_rounded),
                  const SizedBox(height: 8),
                  _compactStat('Matches', '${stats.totalMatches}', Colors.cyanAccent,   Icons.sports_esports_rounded),
                  const SizedBox(height: 8),
                  _compactStat('Days Active', '${stats.totalDays}', Colors.orangeAccent, Icons.calendar_today_rounded),
                  const SizedBox(height: 12),

                  // ── Win Rate gradient card ────────────────────────────────
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 60),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.cyan.withAlpha(60),
                            blurRadius: 10,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                              color: Colors.white.withAlpha(26),
                              borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.bar_chart_rounded,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Win Rate',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Text(
                          '${winRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Compact stat row — constrained to max 60dp height.
  Widget _compactStat(String label, String value, Color color, IconData icon) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 60),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(70), width: 1),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(40),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                  color: color.withAlpha(40),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
