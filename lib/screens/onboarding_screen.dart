import 'package:flutter/material.dart';
import 'package:untitled4/screens/signin_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Find Trusted Workers',
      'description':
          'Connect with verified electricians, plumbers, and skilled labour in your area instantly.',
      'image':
          'https://i.imgur.com/example_painting.png', // Placeholder for new image
    },
    {
      'title': 'Verified Professionals',
      'description':
          'We ensure all workers are verified and skilled to provide you the best service.',
      'image':
          'https://i.imgur.com/example_logo.png', // Placeholder or use Icon
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAF3),
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  );
                },
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _buildPageContent(index),
              ),
            ),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildDot(index),
              ),
            ),

            const SizedBox(height: 32),

            // Continue Button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _onboardingData.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int index) {
    final data = _onboardingData[index];
    final bool isFirstPage = index == 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image / Icon Area
          if (isFirstPage)
            // Simulating the painting style image
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFFE0F2F1),
                image: const DecorationImage(
                  // In a real app, use the asset provided. For now, using a placeholder/network or container styling.
                  image: NetworkImage('https://i.pravatar.cc/300?u=painter'),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            // Gradient Logo style for 2nd page
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF00BCD4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.handyman_outlined,
                color: Colors.white,
                size: 60,
              ),
            ),

          const SizedBox(height: 48),

          Text(
            data['title']!,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00BCD4), // Cyan title for first page
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data['description']!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 6,
      width: _currentPage == index ? 24 : 6,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF00BCD4)
            : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
