import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MusicService {
  static const String baseUrl = 'https://api.deezer.com';
  static const String corsProxyUrl = 'https://corsproxy.io/?';

  final List<MediaItem> _sampleSongs = [
    MediaItem(
      id: '1',
      title: 'A New Beginning',
      artist: 'Bensound',
      duration: const Duration(minutes: 2, seconds: 35),
      artUri: Uri.parse('https://www.bensound.com/bensound-img/betterdays.jpg'),
      extras: {
        'url': 'https://www.bensound.com/bensound-music/bensound-betterdays.mp3',
      },
    ),
    MediaItem(
      id: '2',
      title: 'Creative Minds',
      artist: 'Bensound',
      duration: const Duration(minutes: 2, seconds: 27),
      artUri:
          Uri.parse('https://www.bensound.com/bensound-img/creativeminds.jpg'),
      extras: {
        'url':
            'https://www.bensound.com/bensound-music/bensound-creativeminds.mp3',
      },
    ),
  ];

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Fetch top trending music from Deezer API
  Future<List<MediaItem>> getTopTrendingMusic() async {
    try {
      final response = await http.get(
        Uri.parse('$corsProxyUrl$baseUrl/chart/0/tracks'),
        headers: {'Origin': 'http://localhost'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTracks(data['data']);
      } else {
        throw Exception('Failed to fetch trending music. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching top trending music: $e');
      return _sampleSongs; // Fallback to sample songs
    }
  }

  // Search music from Deezer API
  Future<List<MediaItem>> searchMusic(String query) async {
    if (query.isEmpty) return [];
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse('$corsProxyUrl$baseUrl/search?q=$encodedQuery'),
        headers: {'Origin': 'http://localhost'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseTracks(data['data']);
      } else {
        throw Exception('Failed to search music. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching music: $e');
      return [];
    }
  }

  // Parse tracks from API response
  List<MediaItem> _parseTracks(List<dynamic> tracks) {
    return tracks.map((track) {
      try {
        return MediaItem(
          id: track['id'].toString(),
          title: track['title'] ?? 'Unknown Title',
          artist: track['artist']?['name'] ?? 'Unknown Artist',
          duration: Duration(seconds: track['duration'] ?? 0),
          artUri: Uri.parse(track['album']?['cover_xl'] ?? ''),
          extras: {'url': track['preview'] ?? ''}, // Deezer provides a 30-sec preview URL
        );
      } catch (e) {
        print('Error parsing track: $e');
        return null;
      }
    }).whereType<MediaItem>().toList();
  }

  // Save the last played song
  Future<void> saveLastPlayedSong(String url,
      {String? title, String? artist}) async {
    final prefs = await _prefs;
    await prefs.setString('lastPlayedUrl', url);
    if (title != null) prefs.setString('lastPlayedTitle', title);
    if (artist != null) prefs.setString('lastPlayedArtist', artist);
  }

  // Get the last played song
  Future<Map<String, String>> getLastPlayedSong() async {
    final prefs = await _prefs;
    return {
      'url': prefs.getString('lastPlayedUrl') ?? '',
      'title': prefs.getString('lastPlayedTitle') ?? 'Unknown Title',
      'artist': prefs.getString('lastPlayedArtist') ?? 'Unknown Artist',
    };
  }
}
