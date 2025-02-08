import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import '../services/music_service.dart';


class MusicProvider extends ChangeNotifier {
  final MusicService _musicService = MusicService();
  List<MediaItem> _songs = [];
  List<MediaItem> _searchResults = [];
  bool _isLoading = false;
  String _error = '';
  String _searchQuery = '';

  // Getters for state variables
  List<MediaItem> get songs => _searchQuery.isEmpty ? _songs : _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get searchQuery => _searchQuery;

  MusicProvider() {
    _initializeProvider();
  }

  // Initializes the provider by loading songs from API or cache
  Future<void> _initializeProvider() async {
    _setLoading(true);
    try {
      await _loadSongsFromAPI();
    } catch (e) {
      debugPrint('Error loading songs from API: $e');
      await _loadSongsFromCache();
    } finally {
      _setLoading(false);
    }
  }

  // Loads songs from the API
  Future<void> _loadSongsFromAPI() async {
    try {
      final fetchedSongs = await _musicService.getTopTrendingMusic();
      if (fetchedSongs.isNotEmpty) {
        _songs = fetchedSongs;
        await _cacheSongs(_songs);
      }
    } catch (e) {
      throw Exception('Failed to fetch songs from API: $e');
    }
  }

  // Loads songs from the cache
  Future<void> _loadSongsFromCache() async {
    try {
      final cacheData = await _readCache();
      if (cacheData != null) {
        _songs = cacheData
            .map((songJson) => MediaItem(
                  id: songJson['id'],
                  title: songJson['title'],
                  artist: songJson['artist'] ?? 'Unknown Artist',
                  duration: Duration(milliseconds: songJson['duration'] ?? 0),
                  artUri: Uri.tryParse(songJson['artUri'] ?? ''),
                  extras: {
                    'url': songJson['url'],
                  },
                ))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading songs from cache: $e');
    }
  }

  // Saves songs to the cache
  Future<void> _cacheSongs(List<MediaItem> songs) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/songs_cache.json');
      final songsJson = songs
          .map((song) => {
                'id': song.id,
                'title': song.title,
                'artist': song.artist,
                'duration': song.duration?.inMilliseconds,
                'artUri': song.artUri?.toString(),
                'url': song.extras?['url'],
              })
          .toList();
      await file.writeAsString(jsonEncode(songsJson));
    } catch (e) {
      debugPrint('Error caching songs: $e');
    }
  }

  // Reads cache data
  Future<List<dynamic>?> _readCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/songs_cache.json');
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        return jsonDecode(jsonString) as List<dynamic>;
      }
    } catch (e) {
      debugPrint('Error reading cache: $e');
    }
    return null;
  }

  // Updates the loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Searches songs based on the query
  Future<void> searchSongs(String query) async {
    _searchQuery = query.toLowerCase();
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _searchResults = _songs.where((song) {
      final title = song.title.toLowerCase();
      final artist = song.artist?.toLowerCase() ?? '';
      return title.contains(_searchQuery) || artist.contains(_searchQuery);
    }).toList();
    notifyListeners();
  }

  // Refreshes songs by reloading from API
  Future<void> refreshSongs() async {
    _setLoading(true);
    try {
      await _loadSongsFromAPI();
    } catch (e) {
      _error = 'Error refreshing songs: $e';
      debugPrint(_error);
    } finally {
      _setLoading(false);
    }
  }

  // Fetches recommended songs from the service
 
}
