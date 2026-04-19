import 'package:flutter/material.dart';

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      appBar: AppBar(
        title: const Text('Terms & Privacy'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1A1C18),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Terms of Service',
              content:
                  'Welcome to SmartLabour Marketplace. By using our platform, you agree to comply with and be bound by the following terms and conditions. Our service connects local professionals with clients. We do not employ the workers ourselves; they are independent contractors. You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.',
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'Privacy Policy',
              content:
                  'Your privacy is important to us. We collect personal information (name, phone number, location) only to facilitate the hiring process. Your location data is used to show nearby workers/jobs. We use Stripe and other payment gateways to handle financial transactions securely; we do not store your credit card details on our servers. Your profile information (name, profession, skills) is visible to other users of the platform.',
            ),
            const SizedBox(height: 32),
            _buildSection(
              title: 'User Conduct',
              content:
                  'Users must provide accurate information and maintain professional conduct. Any form of harassment, fraud, or misuse of the platform will result in immediate termination of access. Workers are encouraged to complete high-quality verification to gain trust.',
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                'Last Updated: April 2026',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1C18),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
