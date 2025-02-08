import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_music/providers/music_provider.dart';
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SongList extends StatelessWidget {
  const SongList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MusicProvider, AudioProvider>(
      builder: (context, musicProvider, audioProvider, child) {
        if (musicProvider.songs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: musicProvider.songs.length,
          itemBuilder: (context, index) {
            final song = musicProvider.songs[index];
            final isPlaying = audioProvider.currentSong?.id == song.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isPlaying ? Colors.white.withOpacity(0.1) : Colors.transparent,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: song.artUri?.toString() ?? '',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.music_note),
                    ),
                  ),
                ),
                title: Text(
                  song.title,
                  style: TextStyle(
                    color: isPlaying ? Theme.of(context).primaryColor : Colors.white,
                    fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist ?? 'Unknown Artist',
                  style: TextStyle(
                    color: isPlaying ? Theme.of(context).primaryColor.withOpacity(0.7) : Colors.grey[400],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPlaying)
                      Icon(
                        Icons.equalizer,
                        color: Theme.of(context).primaryColor,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDuration(song.duration ?? Duration.zero),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  if (isPlaying) {
                    if (audioProvider.isPlaying) {
                      audioProvider.pause();
                    } else {
                      audioProvider.play();
                    }
                  } else {
                    audioProvider.playSong(song);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
