import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:untitled4/screens/otp_screen.dart';
import 'package:untitled4/services/auth_service.dart';

import 'package:untitled4/screens/signin_screen.dart';
import 'package:untitled4/screens/role_selection_screen.dart';
import 'package:untitled4/screens/home_screen.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(bottom: 32),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black87,
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),

              // Title
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enter your mobile number to log in or sign up for a new account.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Mobile Number Label
              const Text(
                'Mobile Number',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C18),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),

              // Input Row
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    // Country Code
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      child: const Text(
                        'PK +92',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1C18),
                        ),
                      ),
                    ),
                    // Number Input
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: '300 0000000',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1A1C18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),

              // Or continue with
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 0.5,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Google Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: Logo(Logos.google, size: 24),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A1C18),
                          ),
                        )
                      : const Text(
                          'Google',
                          style: TextStyle(
                            color: Color(0xFF1A1C18),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFFF5F7F8),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Terms
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    children: [
                      const TextSpan(text: 'By continuing, you agree to our '),
                      const TextSpan(
                        text: 'Terms of Service\n',
                        style: TextStyle(color: Color(0xFF00BCD4)),
                      ),
                      const TextSpan(text: 'and '),
                      const TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Color(0xFF00BCD4)),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              // Email fallback
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                  child: const Text('Sign in with Email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyPhone() {
    final number = _phoneController.text.trim();
    if (number.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a number')));
      return;
    }

    // Basic formatting for PK
    final fullNumber = number.startsWith('0')
        ? '+92${number.substring(1)}'
        : '+92$number';

    setState(() => _isLoading = true);

    AuthService().verifyPhoneNumber(
      phoneNumber: fullNumber,
      codeSent: (verificationId, resendToken) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              verificationId: verificationId,
              phoneNumber: fullNumber,
            ),
          ),
        );
      },
      verificationFailed: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
      },
      verificationCompleted: (credential) async {
        // Auto-resolve
        await AuthService().signInWithCredential(credential);
        if (mounted) {
          // Navigate to Home as requested
          // (Assuming Role check is done in Home or AuthService auto-creates)
          Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
        }
      },
      codeAutoRetrievalTimeout: (id) {},
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final result = await AuthService().signInWithGoogle();
      if (result['success'] && mounted) {
        final user = AuthService().currentUser;
        if (user == null || user.role == null || user.role!.isEmpty) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Google Sign In failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
