import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();

  bool _isMusicOn = true;
  bool _isSfxOn = true;
  String _currentMusic = '';

  bool get isMusicOn => _isMusicOn;
  bool get isSfxOn => _isSfxOn;

  void toggleMusic() {
    _isMusicOn = !_isMusicOn;
    if (!_isMusicOn) {
      _musicPlayer.stop();
    } else {
      if (_currentMusic == 'game') {
        playGameMusic();
      } else {
        playMenuMusic();
      }
    }
  }

  void toggleSfx() {
    _isSfxOn = !_isSfxOn;
  }

  Future<void> playMenuMusic() async {
    if (!_isMusicOn) return;
    if (_currentMusic == 'menu') return; // already playing, don't restart
    _currentMusic = 'menu';
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/First-Music.mp3'));
  }

  Future<void> playGameMusic() async {
    if (!_isMusicOn) return;
    if (_currentMusic == 'game') return; // already playing
    _currentMusic = 'game';
    await _musicPlayer.stop();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('sounds/Second-Music.mp3'));
  }

  Future<void> stopGameMusic() async {
    // Call this when leaving game screen — resume menu music
    _currentMusic = '';
    await _musicPlayer.stop();
    await Future.delayed(const Duration(milliseconds: 200));
    await playMenuMusic();
  }

  Future<void> playArrowSound() async {
    if (!_isSfxOn) return;
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Arrow-Sound.mp3'));
  }

  Future<void> playWinSound() async {
    if (!_isSfxOn) return;
    _currentMusic = 'win';
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Win-Sound.mp3'));
  }

  Future<void> playLoseSound() async {
    if (!_isSfxOn) return;
    _currentMusic = 'lose';
    await _musicPlayer.stop();
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('sounds/Lose-Sound.mp3'));
  }

  void stopAll() {
    _musicPlayer.stop();
    _sfxPlayer.stop();
    _currentMusic = '';
  }
}