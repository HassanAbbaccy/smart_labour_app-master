import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:untitled4/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'package:untitled4/services/auth_service.dart';
import './theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Handle Flutter errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  try {
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Firebase initialization timed out');
        throw TimeoutException('Firebase initialization timed out');
      },
    );
    debugPrint('Firebase initialized');

    // Initialize current user with a timeout to prevent hanging the app on startup
    await AuthService().initializeUser().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('User initialization timed out');
      },
    );

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Fatal Startup Error: $e');
    // Still run the app but maybe show an error UI if needed
    // For now, just letting it run to see if we can get a stable connection
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Fatal Initialization Error: $e')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartLabour Marketplace',
      theme: lightMode,
      home: const SplashScreen(),
    );
  }
}
