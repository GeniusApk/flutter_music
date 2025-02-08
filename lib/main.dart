import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_music/screens/home_screen.dart';
import 'package:flutter_music/providers/music_provider.dart';
import 'package:flutter_music/providers/audio_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.flutter_music.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProxyProvider<MusicProvider, AudioProvider>(
          create: (context) => AudioProvider(context.read<MusicProvider>()),
          update: (context, musicProvider, previous) => AudioProvider(musicProvider),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Music',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
