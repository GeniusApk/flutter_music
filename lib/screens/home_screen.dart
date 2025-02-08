import 'package:flutter/material.dart';
import 'package:flutter_music/widgets/music_player.dart';
import 'package:flutter_music/widgets/song_list.dart';
import 'package:flutter_music/screens/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedIndex == 0
                          ? 'Home'
                          : _selectedIndex == 1
                              ? 'Search'
                              : _selectedIndex == 2
                                  ? 'Your Library'
                                  : 'Music',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        // TODO: Implement settings
                      },
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    // Home Tab
                    const Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SongList(),
                        ),
                      ],
                    ),
                    // Search Tab
                    const SearchScreen(),
                    // Library Tab
                    Center(
                      child: Text(
                        'Library Coming Soon',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              // Mini Player
              const MusicPlayer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music),
            label: 'Library',
          ),
        ],
      ),
    );
  }
}
