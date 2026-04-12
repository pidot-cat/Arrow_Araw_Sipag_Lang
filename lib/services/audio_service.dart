// lib/services/audio_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// Arrow Araw — AudioService v3  (Strict Routing)
//
// MUSIC ROUTING
// ─────────────
//   Lobby-Music.mp3  ← loops on: Home, Records, Settings, Contact,
//                       Terms of Service, Privacy Policy, About Us.
//                       NO restart when navigating between these screens.
//
//   Ingame-Music.mp3 ← loops ONLY during active gameplay (between level
//                       start and the win/lose overlay appearing).
//
// SFX ROUTING
// ────────────
//   Arrow-Sound.mp3      → playArrowSound()      ← only on successful release
//   Wrong Move-Sound.mp3 → playWrongSound()       ← only on blocked move
//   Win-Sound.mp3        → playWinSound()         ← ONLY when Victory overlay mounts
//   Lose-Sound.mp3       → playGameOverSound()    ← ONLY when GameOver overlay mounts
//
// STATE MACHINE
// ─────────────
//   _currentMusic tracks: '' | 'menu' | 'game' | 'win' | 'lose'
//   Transitions:
//     Any screen init → playMenuMusic()   (no-op if already 'menu')
//     Level start     → playGameMusic()   (no-op if already 'game')
//     Victory shown   → playWinSound()    (stops music, plays SFX)
//     GameOver shown  → playGameOverSound()
//     Back to lobby   → resumeMenuMusic() (forces 'menu', restarts if needed)
//     Settings open   → timer paused (handled by BentLevelStateMixin)
//     Settings close  → timer resumes (no music change needed)
//
// ASSET PATHS  (audioplayers uses AssetSource — path relative to assets/)
//   assets/audio/Lobby-Music.mp3
//   assets/audio/Ingame-Music.mp3
//   assets/audio/Arrow-Sound.mp3
//   assets/audio/Wrong Move-Sound.mp3
//   assets/audio/Win-Sound.mp3
//   assets/audio/Lose-Sound.mp3
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

  // ── Music state ────────────────────────────────────────────────────────────
  // '' | 'menu' | 'game' | 'win' | 'lose'
  String _currentMusic = '';

  // ── Toggle controls ────────────────────────────────────────────────────────

  /// Toggle background music on / off.  Resumes the current track if re-enabled.
  Future<void> toggleMusic() async {
    _isMusicOn = !_isMusicOn;
    if (!_isMusicOn) {
      await _musicPlayer.pause();
    } else {
      // Resume whichever track was playing before the toggle.
      if (_currentMusic == 'menu' || _currentMusic == 'game') {
        await _musicPlayer.resume();
      }
    }
  }

  /// Toggle SFX on / off (arrow sounds, wrong move, win, lose).
  void toggleSfx() => _isSfxOn = !_isSfxOn;

  // ── Music playback ─────────────────────────────────────────────────────────

  /// Starts `Lobby-Music.mp3` looping.
  /// NO-OP if lobby music is already playing — prevents mid-track restarts
  /// when navigating between lobby-family screens (Home ↔ Settings ↔ Records).
  Future<void> playMenuMusic() async {
    if (_currentMusic == 'menu') return; // already on lobby track — no restart
    _currentMusic = 'menu';
    await _musicPlayer.stop();
    if (!_isMusicOn) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/Lobby-Music.mp3'));
  }

  /// Starts `Ingame-Music.mp3` looping.
  /// NO-OP if in-game music is already playing.
  Future<void> playGameMusic() async {
    if (_currentMusic == 'game') return; // already on ingame track
    _currentMusic = 'game';
    await _musicPlayer.stop();
    if (!_isMusicOn) return;
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/Ingame-Music.mp3'));
  }

  /// Transitions from in-game back to lobby music.
  /// Forces a fresh lobby-music start even if state is ambiguous.
  Future<void> resumeMenuMusic() async {
    _currentMusic = ''; // clear current so playMenuMusic() will not no-op
    await playMenuMusic();
  }

  // ── SFX ────────────────────────────────────────────────────────────────────

  /// Arrow successfully released — called by `onTap` in BentLevelStateMixin.
  Future<void> playArrowSound() async {
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Arrow-Sound.mp3'));
  }

  /// Arrow path blocked — called by `wrongTap` in BentLevelStateMixin.
  Future<void> playWrongSound() async {
    if (!_isSfxOn) return;
    await _wrongPlayer.stop();
    await _wrongPlayer.play(AssetSource('audio/Wrong Move-Sound.mp3'));
  }

  /// Victory overlay is mounting — stops background music, plays win SFX.
  /// Called ONLY inside `triggerVictory()` (= only when overlay shown).
  Future<void> playWinSound() async {
    _currentMusic = 'win';
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Win-Sound.mp3'));
  }

  /// Game-over overlay is mounting — stops background music, plays lose SFX.
  /// Called ONLY inside `triggerGameOver()` (= only when overlay shown).
  Future<void> playGameOverSound() async {
    _currentMusic = 'lose';
    await _musicPlayer.stop();
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('audio/Lose-Sound.mp3'));
  }

  // ── Utility ────────────────────────────────────────────────────────────────

  /// Immediately silence every channel (e.g. on logout / app teardown).
  Future<void> stopAll() async {
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _wrongPlayer.stop();
    _currentMusic = '';
  }

  // ── Legacy shims (kept so existing call-sites compile without changes) ─────

  /// Legacy alias → delegates to `playGameOverSound()`.
  Future<void> playLoseSound() async => playGameOverSound();

  /// Legacy alias — stops game music then returns to lobby.
  Future<void> stopGameMusic() async {
    await _musicPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 150));
    await resumeMenuMusic();
  }
}