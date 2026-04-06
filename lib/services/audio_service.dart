import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer _musicPlayer = AudioPlayer();
  AudioPlayer _sfxPlayer   = AudioPlayer();

  bool _isMusicOn = true;
  bool _isSfxOn   = true;
  String _currentMusic = '';   // 'menu' | 'game' | 'win' | 'lose' | ''

  // Idle-resume timer: game music resumes X seconds after last arrow tap
  Timer? _resumeTimer;
  static const _resumeDelay = Duration(seconds: 3);
  bool _gameMusicPaused = false; // true = paused-by-tap (not by toggle)

  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn   => _isSfxOn;

  // ── Toggle Music ──────────────────────────────────────────────────────────
  Future<void> toggleMusic() async {
    _isMusicOn = !_isMusicOn;
    if (!_isMusicOn) {
      _resumeTimer?.cancel();
      await _musicPlayer.pause();
    } else {
      // Resume whatever was playing (if game music was paused by tap, keep it paused)
      if (!_gameMusicPaused) {
        await _musicPlayer.resume();
      }
    }
  }

  // ── Toggle SFX ───────────────────────────────────────────────────────────
  void toggleSfx() {
    _isSfxOn = !_isSfxOn;
  }

  // ── Menu Music (First-Music, looping) ────────────────────────────────────
  // Call from: HomeScreen, SettingsScreen, RecordsScreen, About/Contact/Terms/Policy
  Future<void> playMenuMusic() async {
    if (_currentMusic == 'menu') return;
    _resumeTimer?.cancel();
    _gameMusicPaused = false;
    _currentMusic = 'menu';
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      if (_isMusicOn) {
        await _musicPlayer.play(AssetSource('sounds/First-Music.mp3'));
      }
    } catch (e) {
      // AudioPlayer may be in a bad state after release; recreate and retry
      try {
        await _musicPlayer.dispose();
      } catch (_) {}
      // Re-init is not possible on a final field — reset via stop only
      if (_isMusicOn) {
        await _musicPlayer.play(AssetSource('sounds/First-Music.mp3'));
      }
    }
  }

  // ── Game Music (Second-Music) ─────────────────────────────────────────────
  // Call from: initLevelState (level screens)
  Future<void> playGameMusic() async {
    if (_currentMusic == 'game' && !_gameMusicPaused) return;
    _resumeTimer?.cancel();
    _gameMusicPaused = false;
    _currentMusic = 'game';
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    if (_isMusicOn) {
      await _musicPlayer.play(AssetSource('sounds/Second-Music.mp3'));
    }
  }

  // ── Called on every correct/wrong arrow tap ───────────────────────────────
  // Pauses game music immediately; schedules resume after idle period.
  Future<void> onArrowTap() async {
    if (_currentMusic != 'game') return;
    _resumeTimer?.cancel();
    if (!_gameMusicPaused) {
      _gameMusicPaused = true;
      await _musicPlayer.pause();
    }
    // Schedule resume after idle
    _resumeTimer = Timer(_resumeDelay, _resumeGameMusic);
  }

  Future<void> _resumeGameMusic() async {
    if (_currentMusic != 'game') return;
    _gameMusicPaused = false;
    if (_isMusicOn) {
      await _musicPlayer.resume();
    }
  }

  // ── Arrow tap sound ───────────────────────────────────────────────────────
  Future<void> playArrowSound() async {
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Arrow-Sound.mp3'));
    // Also pause/schedule resume for game music
    await onArrowTap();
  }

  // ── Win Sound ─────────────────────────────────────────────────────────────
  Future<void> playWinSound() async {
    _resumeTimer?.cancel();
    _gameMusicPaused = false;
    _currentMusic = 'win';
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Win-Sound.mp3'));
  }

  // ── Lose Sound ────────────────────────────────────────────────────────────
  Future<void> playLoseSound() async {
    _resumeTimer?.cancel();
    _gameMusicPaused = false;
    _currentMusic = 'lose';
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Lose-Sound.mp3'));
  }

  // ── Resume menu music (after level ends / back to lobby) ─────────────────
  Future<void> resumeMenuMusic() async {
    _resumeTimer?.cancel();
    _gameMusicPaused = false;
    await playMenuMusic();
  }

  // ── Stop all (logout / screens that need silence) ────────────────────────
  void stopAll() {
    _resumeTimer?.cancel();
    _gameMusicPaused = false;
    _currentMusic = '';
    _musicPlayer.stop();
    _sfxPlayer.stop();
  }

  // ── Force play menu music (ignores _currentMusic guard) ──────────────────
  // Use this when returning to home from login/logout to ensure music starts.
  Future<void> forcePlayMenuMusic() async {
    _currentMusic = ''; // reset so playMenuMusic() won't skip
    await playMenuMusic();
  }
}
