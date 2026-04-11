// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer   = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();

  bool _isMusicOn = true;
  bool _isSfxOn   = true;
  String _currentMusic = '';

  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn   => _isSfxOn;

  Future<void> toggleMusic() async {
    _isMusicOn = !_isMusicOn;
    if (!_isMusicOn) {
      await _musicPlayer.pause();
    } else {
      await _musicPlayer.resume();
    }
  }

  void toggleSfx() => _isSfxOn = !_isSfxOn;

  Future<void> playMenuMusic() async {
    if (!_isMusicOn) return;
    if (_currentMusic == 'menu') return;
    _currentMusic = 'menu';
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/Lobby-Music.mp3'));
  }

  Future<void> playGameMusic() async {
    if (!_isMusicOn) return;
    if (_currentMusic == 'game') return;
    _currentMusic = 'game';
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/Ingame-Music.mp3'));
  }

  Future<void> stopGameMusic() async {
    await _musicPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 200));
    await resumeMenuMusic();
  }

  Future<void> resumeMenuMusic() async {
    if (!_isMusicOn) return;
    _currentMusic = '';
    await playMenuMusic();
  }

  void stopAll() {
    _musicPlayer.stop();
    _sfxPlayer.stop();
    _wrongPlayer.stop();
    _currentMusic = '';
  }

  Future<void> playArrowSound() async {
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Arrow-Sound.mp3'));
  }

  /// Wrong-move sound — plays on blocked tap, does NOT deduct lives.
  Future<void> playWrongSound() async {
    if (!_isSfxOn) return;
    await _wrongPlayer.stop();
    await _wrongPlayer.play(AssetSource('sounds/Wrong Move-Sound.mp3'));
  }

  Future<void> playWinSound() async {
    if (!_isSfxOn) return;
    _currentMusic = 'win';
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Win-Sound.mp3'));
  }

  /// Game-over sound — ONLY called when lives reach zero.
  Future<void> playGameOverSound() async {
    if (!_isSfxOn) return;
    _currentMusic = 'lose';
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Lose-Sound.mp3'));
  }

  /// Kept for legacy calls.
  Future<void> playLoseSound() async => playGameOverSound();
}
