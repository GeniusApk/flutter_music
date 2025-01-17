import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:audio_session/audio_session.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PaletteGenerator? _currentPalette;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  PaletteGenerator? get currentPalette => _currentPalette;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _isPlaying;

  AudioProvider() {
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to player state changes
    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    // Handle errors
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
  }

  Future<void> setAudioSource(String url, String title, String artist, String artUrl) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: title,
            artist: artist,
            artUri: Uri.parse(artUrl),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error setting audio source: $e");
    }
  }

  Future<void> updatePalette(ImageProvider imageProvider) async {
    try {
      _currentPalette = await PaletteGenerator.fromImageProvider(imageProvider);
      notifyListeners();
    } catch (e) {
      debugPrint("Error generating palette: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
