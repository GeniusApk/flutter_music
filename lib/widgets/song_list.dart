import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:flutter_music/providers/music_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SongList extends StatefulWidget {
  const SongList({super.key});

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  @override
  void initState() {
    super.initState();
    // Load top tracks when the widget is first created
    Future.microtask(() =>
        context.read<MusicProvider>().loadTopTracks());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search songs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
            ),
            onChanged: (value) {
              context.read<MusicProvider>().searchSongs(value);
            },
          ),
        ),
        
        // Song List
        Expanded(
          child: Consumer<MusicProvider>(
            builder: (context, musicProvider, child) {
              if (musicProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (musicProvider.songs.isEmpty) {
                return const Center(child: Text('No songs found'));
              }

              return ListView.builder(
                itemCount: musicProvider.songs.length,
                itemBuilder: (context, index) {
                  final song = musicProvider.songs[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CachedNetworkImage(
                        imageUrl: song['artUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Icon(Icons.music_note),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    title: Text(song['title']),
                    subtitle: Text(song['artist']),
                    onTap: () async {
                      final audioProvider = context.read<AudioProvider>();
                      // Update color palette
                      await audioProvider.updatePalette(
                        CachedNetworkImageProvider(song['artUrl']),
                      );
                      // Set and play audio
                      await audioProvider.setAudioSource(
                        song['url'],
                        song['title'],
                        song['artist'],
                        song['artUrl'],
                      );
                      audioProvider.audioPlayer.play();
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
