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
    // Refresh stats from Supabase on open
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
          builder: (context, gameProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // Standard top gap with logo
                  SizedBox(height: size.height * 0.055),
                  Image.asset(AppConstants.logoWithBg, width: 160, height: 160),
                  const SizedBox(height: 16),
                  const Text(
                    'Records',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: size.height * 0.03),
                  _buildStatCard(
                    context,
                    'Total Wins',
                    gameProvider.stats.totalWins.toString(),
                    Colors.greenAccent,
                    Icons.emoji_events_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildStatCard(
                    context,
                    'Total Losses',
                    gameProvider.stats.totalLosses.toString(),
                    Colors.redAccent,
                    Icons.close_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildStatCard(
                    context,
                    'Total Matches',
                    gameProvider.stats.totalMatches.toString(),
                    Colors.cyanAccent,
                    Icons.sports_esports_rounded,
                  ),
                  const SizedBox(height: 14),
                  _buildStatCard(
                    context,
                    'Total Days',
                    gameProvider.stats.totalDays.toString(),
                    Colors.orangeAccent,
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 20),
                  // Win Rate card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withAlpha(60),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(26),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.bar_chart_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 14),
                            const Text(
                              'Win Rate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${gameProvider.stats.winRate.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
