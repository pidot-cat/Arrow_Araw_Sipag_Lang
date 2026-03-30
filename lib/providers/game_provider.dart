import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/arrow_model.dart';
import '../models/game_stats_model.dart';
import '../services/audio_service.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
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

class GameProvider with ChangeNotifier {
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  List<ArrowModel> _arrows = [];
  List<ArrowModel> get arrows => _arrows;

  int _gridSize = 5;
  int get gridSize => _gridSize;

  String _shapeName = '';
  String get shapeName => _shapeName;

  int _lives = AppConstants.initialLives;
  int get lives => _lives;

  int _timeLeft = 60;
  int get timeLeft => _timeLeft;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  bool _isLevelWon = false;
  bool get isLevelWon => _isLevelWon;

  GameStatsModel _stats = GameStatsModel();
  GameStatsModel get stats => _stats;

  Timer? _timer;
  final AudioService _audioService = AudioService();

  GameProvider() {
    _loadStats();
  }

  Future<void> _loadStats() async {
    // 1. Load from local SharedPreferences first for quick display
    final prefs = await SharedPreferences.getInstance();
    _stats = GameStatsModel(
      totalWins: prefs.getInt(AppConstants.keyTotalWins) ?? 0,
      totalLosses: prefs.getInt(AppConstants.keyTotalLosses) ?? 0,
      totalMatches: prefs.getInt(AppConstants.keyTotalMatches) ?? 0,
      totalDays: prefs.getInt(AppConstants.keyTotalDays) ?? 1,
    );
    notifyListeners();

    // 2. Sync from Supabase if logged in
    try {
      final remoteStats = await SupabaseService.fetchGameStats();
      if (remoteStats != null) {
        _stats = remoteStats;
        // Update local cache
        await _saveLocalStats();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing stats from Supabase: $e');
    }
  }

  Future<void> _saveStats() async {
    await _saveLocalStats();
    
    // Sync to Supabase if logged in
    try {
      await SupabaseService.saveGameStats(_stats);
    } catch (e) {
      debugPrint('Error saving stats to Supabase: $e');
    }
  }

  Future<void> _saveLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyTotalWins, _stats.totalWins);
    await prefs.setInt(AppConstants.keyTotalLosses, _stats.totalLosses);
    await prefs.setInt(AppConstants.keyTotalMatches, _stats.totalMatches);
    await prefs.setInt(AppConstants.keyTotalDays, _stats.totalDays);
  }

  void initLevel(int level) {
    _timer?.cancel();
    _currentLevel = level;
    _lives = AppConstants.initialLives;
    _timeLeft = 60;
    _isGameOver = false;
    _isLevelWon = false;
    _loadLevelData(level);
    _startTimer();
    notifyListeners();
  }

  void _loadLevelData(int level) {
    switch (level) {
      case 1:
        _arrows = Level1.getArrows();
        _gridSize = Level1.gridSize;
        _shapeName = Level1.shapeName;
      case 2:
        _arrows = Level2.getArrows();
        _gridSize = Level2.gridSize;
        _shapeName = Level2.shapeName;
      case 3:
        _arrows = Level3.getArrows();
        _gridSize = Level3.gridSize;
        _shapeName = Level3.shapeName;
      case 4:
        _arrows = Level4.getArrows();
        _gridSize = Level4.gridSize;
        _shapeName = Level4.shapeName;
      case 5:
        _arrows = Level5.getArrows();
        _gridSize = Level5.gridSize;
        _shapeName = Level5.shapeName;
      case 6:
        _arrows = Level6.getArrows();
        _gridSize = Level6.gridSize;
        _shapeName = Level6.shapeName;
      case 7:
        _arrows = Level7.getArrows();
        _gridSize = Level7.gridSize;
        _shapeName = Level7.shapeName;
      case 8:
        _arrows = Level8.getArrows();
        _gridSize = Level8.gridSize;
        _shapeName = Level8.shapeName;
      case 9:
        _arrows = Level9.getArrows();
        _gridSize = Level9.gridSize;
        _shapeName = Level9.shapeName;
      case 10:
        _arrows = Level10.getArrows();
        _gridSize = Level10.gridSize;
        _shapeName = Level10.shapeName;
      default:
        _arrows = Level1.getArrows();
        _gridSize = Level1.gridSize;
        _shapeName = Level1.shapeName;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isGameOver || _isLevelWon) {
        timer.cancel();
        return;
      }
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _handleTimerGameOver();
      }
    });
  }

  void _handleTimerGameOver() {
    _timer?.cancel();
    _isGameOver = true;
    _stats.addLoss();
    _saveStats();
    _audioService.playLoseSound();
    notifyListeners();
  }

  void tapArrow(ArrowModel arrow) {
    if (_isGameOver || _isLevelWon || arrow.isEscaping || arrow.isRemoved) {
      return;
    }

    if (_canEscape(arrow)) {
      _audioService.playArrowSound();
      arrow.isEscaping = true;
      notifyListeners();

      Future.delayed(AppConstants.arrowMoveDuration, () {
        arrow.isRemoved = true;
        arrow.isEscaping = false;
        _checkWinCondition();
        notifyListeners();
      });
    } else {
      _lives--;
      if (_lives <= 0) {
        _handleLivesGameOver();
      }
      notifyListeners();
    }
  }

  bool _canEscape(ArrowModel arrow) {
    for (final other in _arrows) {
      if (identical(other, arrow) || other.isRemoved) continue;

      switch (arrow.direction) {
        case ArrowDirection.up:
          if (other.x == arrow.x && other.y < arrow.y) return false;
        case ArrowDirection.down:
          if (other.x == arrow.x && other.y > arrow.y) return false;
        case ArrowDirection.left:
          if (other.y == arrow.y && other.x < arrow.x) return false;
        case ArrowDirection.right:
          if (other.y == arrow.y && other.x > arrow.x) return false;
        case ArrowDirection.white:
          return true;
      }
    }
    return true;
  }

  void _handleLivesGameOver() {
    _timer?.cancel();
    _isGameOver = true;
    _stats.addLoss();
    _saveStats();
    _audioService.playLoseSound();
    notifyListeners();
  }

  void _checkWinCondition() {
    if (_arrows.every((a) => a.isRemoved)) {
      _timer?.cancel();
      _isLevelWon = true;
      _stats.addWin();
      _saveStats();
      _audioService.playWinSound();
      notifyListeners();
    }
  }

  Future<void> refreshStats() async {
    await _loadStats();
  }

  void nextLevel() {
    if (_currentLevel < 10) {
      initLevel(_currentLevel + 1);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
