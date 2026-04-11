// lib/utils/constants.dart
// Central configuration file for the entire app.
// All magic numbers, asset paths, storage keys, and durations live here
// so they can be changed in one place without hunting through every file.

class AppConstants {
  // ── Game Configuration ────────────────────────────────────────────────────
  // Default grid dimension used by the legacy GameScreen provider.
  static const int gridSize = 6;

  // Hearts / lives a player starts each level with.
  static const int initialLives = 3;

  // Fraction of grid cells to fill with obstacles (legacy game mode).
  static const double obstacleDensity = 0.2;

  // ── Animation Durations ───────────────────────────────────────────────────
  // How long the splash logo stays on screen before connectivity check.
  static const Duration splashDuration = Duration(seconds: 3);

  // How long the slide-out animation plays when an arrow escapes.
  static const Duration arrowMoveDuration = Duration(milliseconds: 400);

  // Delay before showing the game-over overlay after lives hit zero.
  static const Duration gameOverDelay = Duration(milliseconds: 500);

  // ── Arrow Types (legacy provider) ─────────────────────────────────────────
  static const List<String> arrowDirections = [
    'up',
    'down',
    'left',
    'right',
    'white',
  ];

  // ── SharedPreferences Storage Keys ───────────────────────────────────────
  // Game stat counters persisted locally between sessions.
  static const String keyTotalWins    = 'total_wins';
  static const String keyTotalLosses  = 'total_losses';
  static const String keyTotalMatches = 'total_matches';
  static const String keyTotalDays    = 'total_days';

  // Auth state keys.
  static const String keyUsername   = 'username';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Level-unlock persistence: stores the highest level number the player
  // has unlocked so far (1 = only Level 1 available, 10 = all unlocked).
  // Saved both locally AND to Supabase so progress persists across devices.
  static const String keyHighestUnlockedLevel = 'highest_unlocked_level';

  // ── Asset Paths — Images ──────────────────────────────────────────────────
  static const String logoWithBg  = 'assets/images/LOGO.png';
  static const String background  = 'assets/images/background.png';
  static const String heartRed    = 'assets/images/heart icon Red.png';
  static const String heartBlack  = 'assets/images/heart icon Black.png';
  static const String gameOver    = 'assets/images/Game Over.png';
  static const String victory     = 'assets/images/Victory.png';

  // ── Asset Paths — Sounds ──────────────────────────────────────────────────
  static const String soundArrow       = 'assets/sounds/Arrow-Sound.mp3';
  static const String soundFirstMusic  = 'assets/sounds/First-Music.mp3';
  static const String soundSecondMusic = 'assets/sounds/Second-Music.mp3';
  static const String soundWin         = 'assets/sounds/Win-Sound.mp3';
  static const String soundLose        = 'assets/sounds/Lose-Sound.mp3';
}
