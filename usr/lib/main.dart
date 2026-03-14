import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'screens/scan_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/video_player_screen.dart';

void main() {
  runApp(const LearnLensApp());
}

class LearnLensApp extends StatelessWidget {
  const LearnLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LearnLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo - Academic feel
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/scan': (context) => const ScanScreen(),
        '/processing': (context) => const ProcessingScreen(),
        '/player': (context) => const VideoPlayerScreen(),
      },
    );
  }
}
