import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:untitled4/screens/signin_screen.dart';
import 'package:untitled4/screens/dashboard.dart';
import 'package:untitled4/services/auth_service.dart';
import './theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize current user
  await AuthService().initializeUser();

  runApp(const MyApp());
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
      home: AuthService().isAuthenticated
          ? const Dashboard()
          : const SignInScreen(),
    );
  }
}
