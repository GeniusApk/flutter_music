import 'package:flutter/material.dart';
import 'package:flutter_music/widgets/music_player.dart';
import 'package:flutter_music/widgets/song_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Music player widget that shows current playing song
            const Expanded(
              flex: 2,
              child: MusicPlayer(),
            ),
            // Divider between player and list
            const Divider(height: 1),
            // List of songs
            const Expanded(
              flex: 3,
              child: SongList(),
            ),
          ],
        ),
      ),
    );
  }
}
