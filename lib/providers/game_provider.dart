// lib/providers/game_provider.dart
// Central state container for game stats AND level-unlock progress.
//
// Responsibilities:
//   • Tracks aggregate stats (wins / losses / matches / days).
//   • Tracks highestUnlockedLevel — the gate that controls which levels are
//     accessible in LevelSelectScreen.
//   • Persists both to SharedPreferences (offline cache) and Supabase (cloud).
//   • Provides unlockNextLevel() which is called by each level screen upon
//     victory to advance the gate by one step.
//   • Legacy GameProvider timer logic kept intact for GameScreen compatibility.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/arrow_model.dart';
import '../models/game_stats_model.dart';
import '../services/audio_service.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';

class GameProvider with ChangeNotifier {
  // ── Legacy GameScreen state ───────────────────────────────────────────────
  // These fields are only used by the generic GameScreen (not level screens).
  int _currentLevel = 1;
  int get currentLevel => _currentLevel;

  final List<ArrowModel> _arrows = [];
  List<ArrowModel> get arrows => _arrows;

  final int _gridSize = 5;
  int get gridSize => _gridSize;

  final String _shapeName = '';
  String get shapeName => _shapeName;

  int _lives = AppConstants.initialLives;
  int get lives => _lives;

  int _timeLeft = 60;
  int get timeLeft => _timeLeft;

  bool _isGameOver = false;
  bool get isGameOver => _isGameOver;

  bool _isLevelWon = false;
  bool get isLevelWon => _isLevelWon;

  Timer? _timer;
  final AudioService _audioService = AudioService();

  // ── Game Stats ────────────────────────────────────────────────────────────
  // Aggregate win/loss counters shown on the Records screen.
  GameStatsModel _stats = GameStatsModel();
  GameStatsModel get stats => _stats;

  // ── Level Unlock ──────────────────────────────────────────────────────────
  // The highest level the player has earned access to.
  // Level 1 is always unlocked; calling unlockNextLevel() advances this.
  int _highestUnlockedLevel = 1;

  /// Read-only accessor used by LevelSelectScreen to decide which cards are
  /// tappable vs. locked.
  int get highestUnlockedLevel => _highestUnlockedLevel;

  // ── Constructor ───────────────────────────────────────────────────────────
  GameProvider() {
    // Load both stats and level progress from local cache and Supabase.
    _loadStats();
    _loadLevelProgress();
  }

  // ── Stats Persistence ─────────────────────────────────────────────────────

  /// Loads stats from SharedPreferences first (fast, works offline), then
  /// overwrites with the Supabase copy if available (authoritative).
  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    _stats = GameStatsModel(
      totalWins:    prefs.getInt(AppConstants.keyTotalWins)    ?? 0,
      totalLosses:  prefs.getInt(AppConstants.keyTotalLosses)  ?? 0,
      totalMatches: prefs.getInt(AppConstants.keyTotalMatches) ?? 0,
      totalDays:    prefs.getInt(AppConstants.keyTotalDays)    ?? 1,
    );
    notifyListeners();
    try {
      final remoteStats = await SupabaseService.fetchGameStats();
      if (remoteStats != null) {
        _stats = remoteStats;
        await _saveLocalStats();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error syncing stats from Supabase: $e');
    }
  }

  /// Saves stats to SharedPreferences and then attempts to sync to Supabase.
  Future<void> _saveStats() async {
    await _saveLocalStats();
    try {
      await SupabaseService.saveGameStats(_stats);
    } catch (e) {
      debugPrint('Error saving stats to Supabase: $e');
    }
  }

  /// Writes the current stats object to SharedPreferences only (no network).
  Future<void> _saveLocalStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyTotalWins,    _stats.totalWins);
    await prefs.setInt(AppConstants.keyTotalLosses,  _stats.totalLosses);
    await prefs.setInt(AppConstants.keyTotalMatches, _stats.totalMatches);
    await prefs.setInt(AppConstants.keyTotalDays,    _stats.totalDays);
  }

  // ── Level Unlock Persistence ──────────────────────────────────────────────

  /// Loads the highest unlocked level from SharedPreferences (fast) then
  /// cross-checks with Supabase, keeping whichever value is higher so offline
  /// play and multi-device play are both handled correctly.
  Future<void> _loadLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    // Local cache — instant, works offline.
    final local = prefs.getInt(AppConstants.keyHighestUnlockedLevel) ?? 1;
    _highestUnlockedLevel = local;
    notifyListeners();

    try {
      // Supabase is authoritative; take the max in case local is ahead
      // (e.g. the user played offline and we haven't synced yet).
      final remote = await SupabaseService.fetchLevelProgress();
      if (remote > _highestUnlockedLevel) {
        _highestUnlockedLevel = remote;
        await prefs.setInt(AppConstants.keyHighestUnlockedLevel, _highestUnlockedLevel);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading level progress from Supabase: $e');
    }
  }

  /// Saves the current [_highestUnlockedLevel] to both local cache and Supabase.
  Future<void> _saveLevelProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyHighestUnlockedLevel, _highestUnlockedLevel);
    try {
      await SupabaseService.saveLevelProgress(_highestUnlockedLevel);
    } catch (e) {
      debugPrint('Error saving level progress to Supabase: $e');
    }
  }

  /// Called by each level screen's triggerVictory() to advance the gate.
  /// If [completedLevel] equals the current highest, unlock the next one.
  /// No-op if the player already has access to higher levels or if they just
  /// beat the final level.
  Future<void> unlockNextLevel(int completedLevel) async {
    // Only advance if this victory is on the frontier (not a replay).
    if (completedLevel >= _highestUnlockedLevel && completedLevel < 10) {
      _highestUnlockedLevel = completedLevel + 1;
      notifyListeners();
      await _saveLevelProgress();
    }
  }

  /// Re-fetches stats from Supabase — called by RecordsScreen on open.
  Future<void> refreshStats() async => await _loadStats();

  /// Clears all stats and level progress locally.
  /// Called on account deletion so a re-registration starts fresh.
  Future<void> resetStats() async {
    _stats = GameStatsModel();
    _highestUnlockedLevel = 1;
    await _saveLocalStats();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyHighestUnlockedLevel, 1);
    notifyListeners();
  }

  // ── Legacy GameScreen Methods ─────────────────────────────────────────────
  // The methods below are used only by the generic GameScreen widget.
  // The per-level screens (game_screen_lvl_X.dart) manage their own state
  // through BentLevelStateMixin and do NOT call these methods.

  void initLevel(int level) {
    _timer?.cancel();
    _currentLevel = level;
    _lives = AppConstants.initialLives;
    _timeLeft = 60;
    _isGameOver = false;
    _isLevelWon = false;
    _startTimer();
    notifyListeners();
  }

  /// Cancels the timer cleanly.  Call before Navigator.pop() to prevent the
  /// timer callback from firing lose-sound after the screen is unmounted.
  void stopLevel() {
    _timer?.cancel();
    _timer = null;
    _isGameOver = false;
    _isLevelWon = false;
    notifyListeners();
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
      if (_lives <= 0) _handleLivesGameOver();
      notifyListeners();
    }
  }

  bool _canEscape(ArrowModel arrow) {
    for (final other in _arrows) {
      if (identical(other, arrow) || other.isRemoved || other.isEscaping) {
        continue;
      }
      for (final otherSegment in other.segments) {
        for (final segment in arrow.segments) {
          switch (arrow.direction) {
            case ArrowDirection.up:
              if (otherSegment.x == segment.x && otherSegment.y < segment.y) {
                return false;
              }
              break;
            case ArrowDirection.down:
              if (otherSegment.x == segment.x && otherSegment.y > segment.y) {
                return false;
              }
              break;
            case ArrowDirection.left:
              if (otherSegment.y == segment.y && otherSegment.x < segment.x) {
                return false;
              }
              break;
            case ArrowDirection.right:
              if (otherSegment.y == segment.y && otherSegment.x > segment.x) {
                return false;
              }
              break;
            case ArrowDirection.white:
              return true;
          }
        }
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

  void nextLevel() {
    if (_currentLevel < 10) initLevel(_currentLevel + 1);
  }

  void playErrorSound()  => _audioService.playLoseSound();
  void playArrowSound()  => _audioService.playArrowSound();
  void playWinSound()    => _audioService.playWinSound();
  void playGameMusic()   => _audioService.playGameMusic();
  void resumeMenuMusic() => _audioService.resumeMenuMusic();

  /// Called by BentLevelStateMixin.triggerVictory() in each level screen.
  /// Records a win in stats AND advances the level-unlock gate.
  void recordLevelComplete({
    required int level,
    required int time,
    required int lives,
  }) {
    _stats.addWin();
    _saveStats();
    _audioService.playWinSound();
    // Unlock the next level if this is a frontier victory.
    unlockNextLevel(level);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
