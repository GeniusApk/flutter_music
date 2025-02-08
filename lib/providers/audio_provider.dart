import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_music/providers/music_provider.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer audioPlayer = AudioPlayer();
  final MusicProvider musicProvider;

  MediaItem? _currentSong;
  bool _isPlaying = false;
  double _progress = 0.0;

  AudioProvider(this.musicProvider) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Initialize audio session
      await audioPlayer.setLoopMode(LoopMode.off);

      // Listen to player state changes
      audioPlayer.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        notifyListeners();
      });

      // Listen to position changes
      audioPlayer.positionStream.listen((position) {
        final duration = audioPlayer.duration;
        if (duration != null) {
          _progress = position.inMilliseconds / duration.inMilliseconds;
          notifyListeners();
        }
      });

      // Handle sequence state changes
      audioPlayer.sequenceStateStream.listen((sequenceState) {
        if (sequenceState?.currentSource != null) {
          _currentSong = sequenceState!.currentSource!.tag as MediaItem;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  // Getters
  MediaItem? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  double get progress => _progress;

  // Play a specific song
  Future<void> playSong(MediaItem song) async {
    try {
      if (song.extras?['url'] == null || song.extras!['url'].isEmpty) {
        throw Exception('Song URL is invalid');
      }

      await audioPlayer.stop();
      final Uri audioUri = Uri.parse(song.extras!['url']);

      await audioPlayer.setAudioSource(
        AudioSource.uri(
          audioUri,
          tag: song,
        ),
        preload: true,
      );

      await audioPlayer.play();
      _currentSong = song;
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
      _isPlaying = false;
      notifyListeners();
    }
  }

  // Playback controls
  Future<void> play() async {
    if (audioPlayer.processingState == ProcessingState.ready) {
      await audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> next() async {
    try {
      final songs = musicProvider.songs;
      if (songs.isEmpty || _currentSong == null) return;

      final currentIndex = songs.indexWhere((s) => s.id == _currentSong?.id);
      if (currentIndex == -1) return;

      final nextIndex = (currentIndex + 1) % songs.length;
      await playSong(songs[nextIndex]);
    } catch (e) {
      debugPrint('Error playing next song: $e');
    }
  }

  Future<void> previous() async {
    try {
      final songs = musicProvider.songs;
      if (songs.isEmpty || _currentSong == null) return;

      final currentIndex = songs.indexWhere((s) => s.id == _currentSong?.id);
      if (currentIndex == -1) return;

      final previousIndex = (currentIndex - 1 + songs.length) % songs.length;
      await playSong(songs[previousIndex]);
    } catch (e) {
      debugPrint('Error playing previous song: $e');
    }
  }

  Future<void> seek(Duration position) async {
    if (audioPlayer.processingState == ProcessingState.ready) {
      await audioPlayer.seek(position);
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
