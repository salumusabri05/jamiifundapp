import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
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
              'Our Mission',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'JamiiFund is dedicated to empowering communities across Tanzania through transparent, effective fundraising. Our mission is to connect donors directly with impactful projects that create lasting change.',
              style: GoogleFonts.nunito(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Our Story',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Founded in 2023, JamiiFund began with a simple idea: to create a platform that makes fundraising accessible to all Tanzanians. We recognized that many worthy causes struggled to find funding, while many potential donors wanted to help but didn\'t know how or where their money would make the most impact.\n\nOur team of passionate changemakers came together to build a solution that bridges this gap, ensuring transparency and accountability in the fundraising process.',
              style: GoogleFonts.nunito(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Our Values',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildValueItem('Transparency', 'We believe in complete openness about where and how funds are used.'),
            _buildValueItem('Community', 'We empower local communities to lead their own development.'),
            _buildValueItem('Integrity', 'We uphold the highest ethical standards in all that we do.'),
            _buildValueItem('Impact', 'We focus on solutions that create lasting, sustainable change.'),
            const SizedBox(height: 24),
            Text(
              'Meet Our Team',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Our diverse team brings together expertise in technology, non-profit management, community development, and finance. What unites us is our shared commitment to positive social impact in Tanzania.',
              style: GoogleFonts.nunito(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            // Team members would go here
          ],
        ),
      ),
    );
  }

  Widget _buildValueItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF8A2BE2),
            size: 24,
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

