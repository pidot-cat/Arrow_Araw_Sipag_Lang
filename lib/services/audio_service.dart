// lib/services/audio_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — AudioService v6  (PRODUCTION FINAL)
//
// WIN-DEBOUNCE: playWinSound() is guarded by _winSoundPlayed boolean.
//   The flag is cleared only by resetWinSoundGuard() which is called from
//   restart() and initLevelState() — so the win sound fires EXACTLY ONCE
//   per level completion, even if triggerVictory() is called from multiple
//   simultaneous Future.delayed callbacks.
//
// LOBBY-MUSIC: playMenuMusic() is called from HomeScreen.initState() via
//   addPostFrameCallback. The AudioService singleton ensures a second call
//   while 'menu' is already playing is a no-op (early return guard).
//   resumeMenuMusic() forces a re-play (e.g. when returning from a game).
//
// [FIX A] IDLE MUSIC RESUME — startIdleResumeTimer() resets 2-second
//         countdown on every tap; resumes game music after idle period.
// [FIX B] APP LIFECYCLE — WidgetsBindingObserver hard-stops all audio
//         when app is paused/detached/hidden.
// [FIX C] MUSIC NEVER CUTS ON TAP — SFX players are separate from
//         _musicPlayer.
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

  // WIN-DEBOUNCE: Prevents multiple win-sound triggers in one level.
  bool _winSoundPlayed = false;

  /// Call from restart() and initLevelState() to reset the win-sound guard
  /// for the new level attempt.
  void resetWinSoundGuard() => _winSoundPlayed = false;

  // ── [FIX A] Idle resume timer ──────────────────────────────────────────────
  Timer? _idleTimer;

  void startIdleResumeTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(const Duration(seconds: 2), _resumeIfGame);
  }

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
      stopAll();
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

  // LOBBY-MUSIC: Early-return guard ensures a second call from HomeScreen
  // while lobby music is already playing is a no-op.
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

  // Forces lobby music to restart even if it was already playing.
  // Use when returning to HomeScreen from a game session.
  Future<void> resumeMenuMusic() async {
    _currentMusic = ''; // clear guard so playMenuMusic re-starts
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

  // WIN-DEBOUNCE: Plays exactly once per level. Guard reset by
  // resetWinSoundGuard() at level start / restart.
  Future<void> playWinSound() async {
    if (_winSoundPlayed) return; // debounce — ignore duplicate calls
    _winSoundPlayed = true;
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
