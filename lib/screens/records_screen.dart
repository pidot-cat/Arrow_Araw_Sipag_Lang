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
    return Scaffold(
      body: BackgroundWrapper(
        showBackButton: true,
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Image.asset(AppConstants.logoWithBg, width: 90, height: 90),
                    const SizedBox(height: 8),
                    const Text(
                      'Records',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatCard('Total Wins',
                        gameProvider.stats.totalWins.toString(),
                        Colors.greenAccent, Icons.emoji_events_rounded),
                    const SizedBox(height: 10),
                    _buildStatCard('Total Losses',
                        gameProvider.stats.totalLosses.toString(),
                        Colors.redAccent, Icons.close_rounded),
                    const SizedBox(height: 10),
                    _buildStatCard('Total Matches',
                        gameProvider.stats.totalMatches.toString(),
                        Colors.cyanAccent, Icons.sports_esports_rounded),
                    const SizedBox(height: 10),
                    _buildStatCard('Total Days',
                        gameProvider.stats.totalDays.toString(),
                        Colors.orangeAccent, Icons.calendar_today_rounded),
                    const SizedBox(height: 10),
                    // Win Rate card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withAlpha(60),
                            blurRadius: 10,
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(26),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.bar_chart_rounded,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Win Rate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${gameProvider.stats.winRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(51),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
