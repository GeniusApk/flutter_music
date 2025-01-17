import 'package:flutter/material.dart';
import 'package:flutter_music/services/music_service.dart';

class MusicProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService();
  List<Map<String, dynamic>> _songs = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Map<String, dynamic>> get songs => _songs;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadTopTracks() async {
    _isLoading = true;
    notifyListeners();

    _songs = await _musicService.getTopTracks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchSongs(String query) async {
    if (query.isEmpty) {
      await loadTopTracks();
      return;
    }

    _searchQuery = query;
    _isLoading = true;
    notifyListeners();

    _songs = await _musicService.searchSongs(query);
    _isLoading = false;
    notifyListeners();
  }
}
