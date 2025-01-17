import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_music/providers/audio_provider.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        final palette = audioProvider.currentPalette;
        final backgroundColor = palette?.dominantColor?.color ?? Colors.black;
        final textColor = palette?.dominantColor?.bodyTextColor ?? Colors.white;

        return Container(
          color: backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Album Art
              if (audioProvider.audioPlayer.sequenceState?.currentSource?.tag?.artUri != null)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: audioProvider.audioPlayer.sequenceState!.currentSource!.tag.artUri.toString(),
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Title and Artist
              Text(
                audioProvider.audioPlayer.sequenceState?.currentSource?.tag?.title ?? 'No Track Selected',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                audioProvider.audioPlayer.sequenceState?.currentSource?.tag?.artist ?? 'Unknown Artist',
                style: TextStyle(
                  fontSize: 18,
                  color: textColor.withOpacity(0.7),
                ),
              ),

              // Progress Bar
              Slider(
                value: audioProvider.position.inSeconds.toDouble(),
                max: audioProvider.duration.inSeconds.toDouble(),
                onChanged: (value) {
                  audioProvider.audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),

              // Play/Pause Button
              IconButton(
                icon: Icon(
                  audioProvider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 64,
                  color: textColor,
                ),
                onPressed: () {
                  if (audioProvider.isPlaying) {
                    audioProvider.audioPlayer.pause();
                  } else {
                    audioProvider.audioPlayer.play();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
