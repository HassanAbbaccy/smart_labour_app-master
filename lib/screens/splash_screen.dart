import 'package:flutter/material.dart';
import 'dart:async';
import 'package:untitled4/services/auth_service.dart';
import 'package:untitled4/screens/signin_screen.dart';
import 'package:untitled4/screens/home_screen.dart';
import 'package:untitled4/screens/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Show splash for a short period then navigate based on auth state
    Timer(const Duration(seconds: 2), _goNext);
  }

  void _goNext() {
    final isAuth = AuthService().isAuthenticated;
    if (!mounted) return;
    if (!isAuth) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
      return;
    }

    final role = AuthService().currentUser?.role;
    if (role == null || role.isEmpty) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Simple centered app title/logo
            const Icon(Icons.handshake, size: 84, color: Color(0xFF7C3AED)),
            const SizedBox(height: 16),
            const Text(
              'SmartLabour',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
