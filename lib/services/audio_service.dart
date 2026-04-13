// lib/services/audio_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — AudioService v7  (PRODUCTION FINAL — Fix 3 Applied)
//
// FIX-3b TOGGLE RESUME: toggleMusic() now force-restarts the menu player when
//         it was previously stopped (not just paused). AudioPlayer.resume() is
//         a no-op on a stopped player, so toggling Off→On in Settings used to
//         produce silence. Fixed by clearing the guard and calling playMenuMusic
//         or resuming game music as appropriate.
//
// FIX-3c LIFECYCLE PAUSE (not stop): didChangeAppLifecycleState now PAUSES
//         (not stops) audio on background so _currentMusic state is preserved.
//         On resume it restores whichever track was active — lobby OR game.
//         Previously, stopping cleared _currentMusic and always restarted
//         lobby music when the app foregrounded during a game session.
//
// WIN-DEBOUNCE  playWinSound() guarded by _winSoundPlayed; reset by
//               resetWinSoundGuard() from restart() / initLevelState().
// LOBBY-MUSIC   playMenuMusic() early-return guard (no-op on second call).
//               resumeMenuMusic() force-restarts regardless of guard.
// FIX-A         startIdleResumeTimer() — 2s idle → resume game music.
// FIX-C         SFX players are separate from _musicPlayer.
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

  // WIN-DEBOUNCE
  bool _winSoundPlayed = false;
  void resetWinSoundGuard() => _winSoundPlayed = false;

  // ── Idle resume timer (FIX-A) ─────────────────────────────────────────────
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

  // ── AppLifecycle observer (FIX-3c) ────────────────────────────────────────
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
      // FIX-3c: PAUSE (not stop) so _currentMusic is preserved for resume.
      // Stopping resets the player and forgets which track was playing,
      // causing lobby music to play when returning from an in-game session.
      _musicPlayer.pause();
      _sfxPlayer.stop();
      _wrongPlayer.stop();
      cancelIdleTimer();
    }
    if (state == AppLifecycleState.resumed && _isMusicOn) {
      // FIX-3c: Resume whichever track was active — lobby OR in-game.
      if (_currentMusic == 'menu' || _currentMusic == 'game') {
        _musicPlayer.resume();
      }
    }
  }

  // ── Toggle controls (FIX-3b) ───────────────────────────────────────────────
  Future<void> toggleMusic() async {
    _isMusicOn = !_isMusicOn;
    if (!_isMusicOn) {
      await _musicPlayer.pause();
    } else {
      // FIX-3b: AudioPlayer.resume() is a no-op when the player has been
      // stopped (e.g. after navigating away and back). Force-restart the
      // appropriate track so the toggle reliably resumes audio.
      if (_currentMusic == 'menu') {
        // Clear guard so playMenuMusic re-starts rather than early-returning.
        _currentMusic = '';
        await playMenuMusic();
      } else if (_currentMusic == 'game') {
        // Game music uses a looping player that was only paused — resume works.
        await _musicPlayer.resume();
      }
    }
  }

  void toggleSfx() => _isSfxOn = !_isSfxOn;

  // ── Music playback ─────────────────────────────────────────────────────────

  Future<void> playMenuMusic() async {
    if (_currentMusic == 'menu') return; // early-return guard (no-op)
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

  /// Force lobby music to restart even if already playing.
  /// Call when returning to HomeScreen from a game session.
  Future<void> resumeMenuMusic() async {
    _currentMusic = ''; // clear guard so playMenuMusic re-starts
    await playMenuMusic();
  }

  // ── SFX — separate players; never touch _musicPlayer ─────────────────────

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
    if (_winSoundPlayed) return;
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
