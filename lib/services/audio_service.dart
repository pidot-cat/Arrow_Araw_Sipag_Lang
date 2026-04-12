// lib/services/audio_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — AudioService v5  (FINAL RECTIFICATION)
//
// [FIX A] IDLE MUSIC RESUME — startIdleResumeTimer() restarts a 2-second
//         countdown on every tap. If the player is idle for 2 s while
//         in-game music state is 'game', _musicPlayer.resume() is called.
//
// [FIX B] APP LIFECYCLE HARD STOP — WidgetsBindingObserver stops ALL audio
//         (music + SFX) when the app is paused, detached, or hidden.
//         Call attachLifecycleObserver() once from main().
//
// [FIX C] MUSIC NEVER CUTS ON TAP — SFX players are separate from
//         _musicPlayer, so arrow/wrong sounds never interrupt the music.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';

class AudioService with WidgetsBindingObserver {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // ── Players ────────────────────────────────────────────────────────────────
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer   = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();

  // ── Settings ───────────────────────────────────────────────────────────────
  bool _isMusicOn = true;
  bool _isSfxOn   = true;
  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn   => _isSfxOn;

  // ── State: '' | 'menu' | 'game' | 'win' | 'lose' ─────────────────────────
  String _currentMusic = '';

  // ── [FIX A] Idle resume timer ──────────────────────────────────────────────
  Timer? _idleTimer;

  /// Call on every player tap (correct, wrong, or miss) to reset the 2s timer.
  void startIdleResumeTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 2), _resumeIfGame);
  }

  /// Stop and discard the idle timer (game-over, victory, quit, dispose).
  void cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  Future<void> _resumeIfGame() async {
    if (_currentMusic != 'game' || !_isMusicOn) return;
    await _musicPlayer.resume();
  }

  // ── [FIX B] AppLifecycle hard stop ────────────────────────────────────────
  bool _observerAttached = false;

  /// Register once from main() to enable background audio hard-stop.
  void attachLifecycleObserver() {
    if (_observerAttached) return;
    _observerAttached = true;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused   ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      stopAll(); // Hard stop — no ghost audio in background
    }
    if (state == AppLifecycleState.resumed) {
      if (_currentMusic == 'menu' && _isMusicOn) _musicPlayer.resume();
    }
  }

  // ── Toggle controls ────────────────────────────────────────────────────────
  Future<void> toggleMusic() async {
    _isMusicOn = !_isMusicOn;
    if (!_isMusicOn) {
      await _musicPlayer.pause();
    } else {
      if (_currentMusic == 'menu' || _currentMusic == 'game') {
        await _musicPlayer.resume();
      }
    }
  }

  void toggleSfx() => _isSfxOn = !_isSfxOn;

  // ── Music playback ─────────────────────────────────────────────────────────
  Future<void> playMenuMusic() async {
    if (_currentMusic == 'menu') return;
    _currentMusic = 'menu';
    await _musicPlayer.stop();
    if (!_isMusicOn) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/Lobby-Music.mp3'));
  }

  Future<void> playGameMusic() async {
    if (_currentMusic == 'game') return;
    _currentMusic = 'game';
    await _musicPlayer.stop();
    if (!_isMusicOn) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/Ingame-Music.mp3'));
  }

  Future<void> resumeMenuMusic() async {
    _currentMusic = '';
    await playMenuMusic();
  }

  // ── SFX — [FIX C] never touch _musicPlayer ────────────────────────────────
  Future<void> playArrowSound() async {
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Arrow-Sound.mp3'));
  }

  Future<void> playWrongSound() async {
    if (!_isSfxOn) return;
    await _wrongPlayer.stop();
    await _wrongPlayer.play(AssetSource('audio/Wrong Move-Sound.mp3'));
  }

  Future<void> playWinSound() async {
    _currentMusic = 'win';
    cancelIdleTimer();
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Win-Sound.mp3'));
  }

  Future<void> playGameOverSound() async {
    _currentMusic = 'lose';
    cancelIdleTimer();
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Lose-Sound.mp3'));
  }

  // ── Utility ────────────────────────────────────────────────────────────────
  Future<void> stopAll() async {
    cancelIdleTimer();
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _wrongPlayer.stop();
    _currentMusic = '';
  }

  // ── Legacy shims ───────────────────────────────────────────────────────────
  Future<void> playLoseSound()  async => playGameOverSound();
  Future<void> stopGameMusic()  async {
    await _musicPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 150));
    await resumeMenuMusic();
  }
}
