import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/constants.dart';

class VictoryOverlay extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const VictoryOverlay({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned.fill(
      child: Container(
        color: Colors.black.withAlpha(160),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConstants.victory,
                width: screenWidth * 0.7,
                height: screenHeight * 0.25,
                fit: BoxFit.contain,
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                'Level Complete!',
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  color: AppColors.green,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: AppColors.green.withAlpha(150),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Congratulations! You cleared the path!',
                style: TextStyle(
                  fontSize: screenWidth * 0.038,
                  color: Colors.white.withAlpha(160),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward, color: Colors.white),
                label: Text(
                  'NEXT LEVEL',
                  style: TextStyle(
                    fontSize: screenWidth * 0.048,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: screenHeight * 0.018,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  ),
                  elevation: 8,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              TextButton.icon(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_ios_new,
                    color: Colors.white.withAlpha(180),
                    size: screenWidth * 0.04),
                label: Text(
                  'BACK',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}