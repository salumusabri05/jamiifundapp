import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/screens/home_screen.dart';
import 'package:jamiifund/screens/auth_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 2;

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _numPages; i++) {
      indicators.add(
        Container(
          width: 10.0,
          height: 10.0,
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? const Color(0xFF8A2BE2)
                : const Color(0xFFD8D8D8),
          ),
        ),
      );
    }
    return indicators;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                    );
                  },
                  child: Text(
                    'Skip',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF8A2BE2),
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(), // Improve scroll behavior
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  ValuePropositionPage(),
                  CallToActionPage(),
                ],
              ),
            ),
            
            // Page indicators and navigation buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _currentPage == 0
                      ? const SizedBox(width: 70.0)
                      : TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.arrow_back_ios,
                                color: Color(0xFF8A2BE2),
                                size: 16.0,
                              ),
                              const SizedBox(width: 5.0),
                              Text(
                                'Back',
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFF8A2BE2),
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                  
                  // Page indicators
                  Row(
                    children: _buildPageIndicator(),
                  ),
                  
                  // Next or Get Started button
                  TextButton(
                    onPressed: () {
                      if (_currentPage == _numPages - 1) {
                        // Last page, navigate to home screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const AuthPage()),
                        );
                      } else {
                        // Go to next page
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          _currentPage == _numPages - 1 ? 'Get Started' : 'Next',
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF8A2BE2),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF8A2BE2),
                          size: 16.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ValuePropositionPage extends StatelessWidget {
  const ValuePropositionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Use minimum space
          children: [
            Text(
              'Why JamiiFund?',
              style: GoogleFonts.nunito(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8A2BE2),
              ),
            ),
            const SizedBox(height: 30.0), // Reduced spacing
            
            // Feature 1
            FeatureItem(
              icon: Icons.create_rounded,
              title: 'Easy campaign creation',
              description: 'Set up your fundraising campaign in minutes with our simple interface.',
            ),
            
            const SizedBox(height: 25.0), // Reduced spacing
            
            // Feature 2
            FeatureItem(
              icon: Icons.security_rounded,
              title: 'Secure donations',
              description: 'All transactions are secured with the latest encryption technology.',
            ),
            
            const SizedBox(height: 25.0), // Reduced spacing
            
            // Feature 3
            FeatureItem(
              icon: Icons.visibility_rounded,
              title: 'Transparent progress tracking',
              description: 'Keep supporters updated with real-time progress reports and updates.',
            ),
          ],
        ),
      ),
    );
  }
}

class CallToActionPage extends StatelessWidget {
  const CallToActionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Use minimum space
          children: [
            Text(
              'Join the JamiiFund Community',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8A2BE2),
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'Start your campaign or support others today.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 18.0,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30.0),
            
            // Image with improved fitting
            Container(
              height: 220.0,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: const Color(0xFFF0E6FF),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.asset(
                  'assets/images/Diversity1.png',
                  fit: BoxFit.contain, // Changed from cover to contain
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150.0,
                      width: 150.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E6FF),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.people_alt_rounded,
                          size: 60.0,
                          color: Color(0xFF8A2BE2),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 30.0), // Reduced spacing
            
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const AuthPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E6FF),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF8A2BE2),
            size: 28.0,
          ),
        ),
        const SizedBox(width: 16.0),
        
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                description,
                style: GoogleFonts.nunito(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
