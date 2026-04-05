import 'package:flutter/material.dart';

class AppColors {
  // Primary Gradient Colors (Deep Blue to Dark Grey)
  static const Color primaryDark = Color(0xFF271E9A);
  static const Color primaryGrey = Color(0xFF212125);
  static const Color primary = Color(0xFF271E9A);

  // Secondary Gradient Colors (Silver Grey)
  static const Color secondaryLight = Color(0xFFA2A2A3);
  static const Color secondaryDark = Color(0xFF3D3D3D);

  // Background
  static const Color backgroundDark = Color(0xFF1A1A1D);
  static const Color surface = Color(0xFF2C2C2E);

  // Text Colors
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFFB0B0B0);

  // Arrow Colors (Vibrant & Colorful)
  static const Color cyan = Color(0xFF00E5FF);
  static const Color orange = Color(0xFFFF6D00);
  static const Color green = Color(0xFF00FF41);
  static const Color purple = Color(0xFFD500F9);
  static const Color red = Color(0xFFFF1744);
  static const Color yellow = Color(0xFFFFEA00);
  static const Color pink = Color(0xFFFF4081);
  static const Color white = Colors.white;

  // Arrow Colors List
  static const List<Color> arrowColors = [
    cyan,
    orange,
    green,
    purple,
    red,
    yellow,
    pink,
    white,
  ];

  // Arrow Color Aliases (used by level screens)
  static const Color arrowRed = red;
  static const Color arrowOrange = orange;
  static const Color arrowYellow = yellow;
  static const Color arrowGreen = green;
  static const Color arrowCyan = cyan;
  static const Color arrowBlue = Color(0xFF2979FF);
  static const Color arrowPurple = purple;
  static const Color arrowPink = pink;
  static const Color arrowWhite = white;

  // Dark Navy (used for scaffold/dialog backgrounds)
  static const Color darkNavy = Color(0xFF0D1B2A);

  // UI Elements
  static const Color heartRed = Color(0xFFFF1744);
  static const Color heartBlack = Color(0xFF2C2C2C);
  static const Color obstacleGrey = Color(0xFF4A4A4A);

  // Helper to replace withOpacity
  static Color alpha(Color color, double opacity) =>
      color.withAlpha((opacity * 255).toInt());

  // Gradients
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [primaryDark, primaryGrey],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient secondaryGradient = LinearGradient(
    colors: [
      alpha(secondaryLight, 0.9),
      alpha(secondaryDark, 0.9),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
