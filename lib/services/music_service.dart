import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicService {
  static const String baseUrl = 'https://api.deezer.com';

  Future<List<Map<String, dynamic>>> searchSongs(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'].map((x) => {
              'id': x['id'].toString(),
              'title': x['title'],
              'artist': x['artist']['name'],
              'url': x['preview'], // 30-second preview URL
              'artUrl': x['album']['cover_xl'],
              'duration': x['duration'],
            }));
      }
      return [];
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopTracks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chart/0/tracks'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'].map((x) => {
              'id': x['id'].toString(),
              'title': x['title'],
              'artist': x['artist']['name'],
              'url': x['preview'],
              'artUrl': x['album']['cover_xl'],
              'duration': x['duration'],
            }));
      }
      return [];
    } catch (e) {
      print('Error getting top tracks: $e');
      return [];
    }
  }
}
