import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class HowItWorksPage extends StatelessWidget {
  const HowItWorksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'How It Works',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Raising Funds on JamiiFund',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'JamiiFund makes it easy to raise funds for causes you care about. Here\'s how the process works:',
              style: GoogleFonts.nunito(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildStepItem(
              context,
              number: '1',
              title: 'Create Your Campaign',
              description: 'Sign up for a JamiiFund account and create your fundraising campaign. Add a compelling title, description, photos, and set your fundraising goal.',
            ),
            _buildStepItem(
              context,
              number: '2',
              title: 'Share Your Story',
              description: 'Tell potential donors why your cause matters. Share the impact their contribution will make and why they should support you.',
            ),
            _buildStepItem(
              context,
              number: '3',
              title: 'Promote Your Campaign',
              description: 'Share your campaign with friends, family, and social networks. Use the tools in our app to spread the word.',
            ),
            _buildStepItem(
              context,
              number: '4',
              title: 'Collect Donations',
              description: 'As people donate, you\'ll see your progress toward your goal. All payments are secure and transparent.',
            ),
            _buildStepItem(
              context,
              number: '5',
              title: 'Receive Funds',
              description: 'Once your campaign ends, funds will be transferred to your account (minus our small service fee to maintain the platform).',
            ),
            _buildStepItem(
              context,
              number: '6',
              title: 'Update Supporters',
              description: 'Keep your donors informed about how their contributions are being used. Share progress updates and success stories.',
            ),
            const SizedBox(height: 32),
            Text(
              'Donating on JamiiFund',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Supporting causes you care about is simple and secure:',
              style: GoogleFonts.nunito(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildStepItem(
              context,
              number: '1',
              title: 'Discover Campaigns',
              description: 'Browse campaigns by category or search for specific causes you care about.',
            ),
            _buildStepItem(
              context,
              number: '2',
              title: 'Make a Donation',
              description: 'Choose the amount you want to donate and complete a secure payment through our platform.',
            ),
            _buildStepItem(
              context,
              number: '3',
              title: 'Track Impact',
              description: 'Follow the progress of campaigns you\'ve supported and see the difference your donation is making.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8A2BE2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Commitment to You',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'JamiiFund is committed to transparency and security. We verify all campaigns before they go live and monitor for fraudulent activity. Our platform fee is among the lowest in the industry, ensuring more of your donation goes directly to the causes you support.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
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

  Widget _buildStepItem(
    BuildContext context, {
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF8A2BE2),
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

