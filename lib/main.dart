import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AdService().initialize();
  await NotificationService().initialize();

  runApp(const LaSfidaDellaFedeApp());
}

class LaSfidaDellaFedeApp extends StatelessWidget {
  const LaSfidaDellaFedeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'La Sfida della Fede',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1A237E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E),
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFFC9A84C),
          surface: const Color(0xFFF5F0E8),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        textTheme: GoogleFonts.loraTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A237E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
