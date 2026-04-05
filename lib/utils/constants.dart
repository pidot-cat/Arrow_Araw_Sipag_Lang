class AppConstants {
  // Game Configuration
  static const int gridSize = 6;
  static const int initialLives = 3;
  static const double obstacleDensity = 0.2;

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration arrowMoveDuration = Duration(milliseconds: 400);
  static const Duration gameOverDelay = Duration(milliseconds: 500);

  // Arrow Types
  static const List<String> arrowDirections = [
    'up',
    'down',
    'left',
    'right',
    'white',
  ];

  // Storage Keys
  static const String keyTotalWins = 'total_wins';
  static const String keyTotalLosses = 'total_losses';
  static const String keyTotalMatches = 'total_matches';
  static const String keyTotalDays = 'total_days';
  static const String keyUsername = 'username';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Asset Paths — Images
  static const String logoWithBg = 'assets/images/LOGO.png';
  static const String background = 'assets/images/background.png';
  static const String heartRed = 'assets/images/heart icon Red.png';
  static const String heartBlack = 'assets/images/heart icon Black.png';
  static const String gameOver = 'assets/images/Game Over.png';
  static const String victory = 'assets/images/Victory.png';
  // ✅ FIXED: Removed backButton asset constant — walang file, ginagamit na built-in icon

  // Asset Paths — Sounds
  static const String soundArrow = 'assets/sounds/Arrow-Sound.mp3';
  static const String soundFirstMusic = 'assets/sounds/First-Music.mp3';
  static const String soundSecondMusic = 'assets/sounds/Second-Music.mp3';
  static const String soundWin = 'assets/sounds/Win-Sound.mp3';
  static const String soundLose = 'assets/sounds/Lose-Sound.mp3';
}
