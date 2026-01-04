import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'database/firebase_setup.dart';
import 'providers/music_player_provider.dart';
import 'providers/home_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await FirebaseSetup.initialize();
    print('✅ Firebase setup completed');
  } catch (e) {
    print('❌ Firebase setup failed: $e');
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Chỉ bật trong chế độ debug/profile
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Clone',
      debugShowCheckedModeBanner: false,
      // Cấu hình Device Preview
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF1DB954),
      ),
      home: const HomeScreen(),
    );
  }
}
