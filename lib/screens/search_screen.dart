import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_music/providers/music_provider.dart';
import 'package:flutter_music/providers/audio_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_music/screens/now_playing_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search songs...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        context.read<MusicProvider>().searchSongs('');
                        setState(() {
                          _isSearching = false;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.grey[800],
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (value) {
              setState(() {
                _isSearching = value.isNotEmpty;
              });
              context.read<MusicProvider>().searchSongs(value);
            },
          ),
        ),

        // Search Results
        Expanded(
          child: Consumer2<MusicProvider, AudioProvider>(
            builder: (context, musicProvider, audioProvider, child) {
              if (musicProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (!_isSearching) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search,
                        size: 100,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Search for your favorite songs',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final songs = musicProvider.songs;
              if (songs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.music_off,
                        size: 100,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No songs found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final isPlaying = audioProvider.currentSong?.id == song.id;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.artUri?.toString() ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[850],
                            child: const Icon(
                              Icons.music_note,
                              color: Colors.white54,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: TextStyle(
                        color: isPlaying ? Colors.deepPurple : Colors.white,
                        fontWeight:
                            isPlaying ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      song.artist ?? 'Unknown Artist',
                      style: TextStyle(
                        color: isPlaying ? Colors.deepPurple[200] : Colors.grey,
                      ),
                    ),
                    trailing: isPlaying
                        ? const Icon(
                            Icons.equalizer,
                            color: Colors.deepPurple,
                          )
                        : null,
                    onTap: () async {
                      try {
                        await audioProvider.playSong(song);
                        if (!mounted) return;
                        // Navigate to now playing screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NowPlayingScreen(),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error playing song: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
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
