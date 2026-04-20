import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smart_labour/services/auth_service.dart';
import 'package:smart_labour/screens/onboarding_screen.dart'; // Import Onboarding
import 'package:smart_labour/screens/home_screen.dart';
import 'package:smart_labour/screens/role_selection_screen.dart';
import 'package:smart_labour/services/session_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Auto-navigate after 3.5 seconds
    Timer(const Duration(milliseconds: 3500), _goNext);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() async {
    // Check for session timeout on startup
    final expired = await SessionService().isSessionExpired();
    if (expired && AuthService().isAuthenticated) {
      debugPrint('STARTUP SESSION EXPIRED: Logging out.');
      await AuthService().signOut();
    }
    await SessionService().clearSession();

    final isAuth = AuthService().isAuthenticated;
    if (!mounted) return;
    if (!isAuth) {
      // Navigate to Onboarding if not authenticated
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF7C3AED), // Purple
                      Color(0xFF00BCD4), // Cyan
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.handyman_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 32),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF00BCD4)],
                ).createShader(bounds),
                child: const Text(
                  'SmartLabour',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Quality Work, Right Away',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                color: Color(0xFF00BCD4),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
