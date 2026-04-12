// lib/services/audio_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — AudioService v4  (FIXED: Asset Paths + State Machine)
//
// [FIX 3] ASSET PATH CORRECTION
//   OLD: AssetSource('audio/Lobby-Music.mp3')
//        pubspec.yaml declared: assets/sounds/
//        Physical files lived in: assets/sounds/
//   → All three were inconsistent. audioplayers' AssetSource resolves relative
//     to the assets/ root declared in pubspec.yaml. If pubspec declares
//     assets/sounds/ but code says audio/, the file is not found → silence.
//
//   NEW: pubspec.yaml now declares: assets/audio/
//        Files have been moved to:  assets/audio/
//        Code uses AssetSource('audio/Lobby-Music.mp3')  ← all consistent ✓
//
// MUSIC ROUTING
// ─────────────
//   Lobby-Music.mp3  ← loops on: Home, Records, Settings, Contact,
//                       Terms, Privacy, About. NO restart between these screens.
//   Ingame-Music.mp3 ← loops ONLY during active gameplay.
//
// SFX ROUTING
// ────────────
//   Arrow-Sound.mp3      → playArrowSound()      ← on successful release
//   Wrong Move-Sound.mp3 → playWrongSound()       ← on blocked move
//   Win-Sound.mp3        → playWinSound()         ← ONLY when Victory overlay mounts
//   Lose-Sound.mp3       → playGameOverSound()    ← ONLY when GameOver overlay mounts
//
// STATE MACHINE  '' | 'menu' | 'game' | 'win' | 'lose'
// ─────────────────────────────────────────────────────────────────────────────

import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // ── Players ────────────────────────────────────────────────────────────────
  final AudioPlayer _musicPlayer = AudioPlayer(); // music (lobby / ingame)
  final AudioPlayer _sfxPlayer   = AudioPlayer(); // arrow, win, lose sfx
  final AudioPlayer _wrongPlayer = AudioPlayer(); // dedicated wrong-move channel

  // ── Toggle state ───────────────────────────────────────────────────────────
  bool _isMusicOn = true;
  bool _isSfxOn   = true;

  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn   => _isSfxOn;

  // ── Music state  '' | 'menu' | 'game' | 'win' | 'lose' ───────────────────
  String _currentMusic = '';

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
  //
  // [FIX 3] All asset paths now use the 'audio/' prefix which matches the
  // pubspec.yaml declaration of 'assets/audio/'. audioplayers resolves
  // AssetSource(path) as assets/<path>, so 'audio/Lobby-Music.mp3' →
  // 'assets/audio/Lobby-Music.mp3' — exactly where the file lives.

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

  // ── SFX ────────────────────────────────────────────────────────────────────

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
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Win-Sound.mp3'));
  }

  Future<void> playGameOverSound() async {
    _currentMusic = 'lose';
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Lose-Sound.mp3'));
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  Future<void> stopAll() async {
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _wrongPlayer.stop();
    _currentMusic = '';
  }

  // ── Legacy shims ───────────────────────────────────────────────────────────

  Future<void> playLoseSound() async => playGameOverSound();

  Future<void> stopGameMusic() async {
    await _musicPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 150));
    await resumeMenuMusic();
  }
}
