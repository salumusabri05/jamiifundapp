import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class CommunityGuidelinesPage extends StatelessWidget {
  const CommunityGuidelinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final guidelineCategories = [
      {
        'title': 'Campaign Transparency',
        'icon': Icons.visibility,
        'guidelines': [
          'Provide accurate and truthful information about your campaign purpose.',
          'Be specific about how funds will be used.',
          'Share regular updates on campaign progress.',
          'Disclose any personal benefit from the campaign.',
          'Include realistic fundraising goals and timelines.',
        ],
      },
      {
        'title': 'Respectful Communication',
        'icon': Icons.chat_bubble_outline,
        'guidelines': [
          'Be respectful to all community members.',
          'Avoid offensive language, harassment, or bullying.',
          'Do not make discriminatory statements based on race, religion, gender, etc.',
          'Respond to donors and comments in a timely, respectful manner.',
          'Focus on constructive dialogue when discussing differences.',
        ],
      },
      {
        'title': 'Content Standards',
        'icon': Icons.image_outlined,
        'guidelines': [
          'Do not post explicit, violent, or disturbing imagery.',
          'Obtain proper consent before sharing images of others.',
          'Ensure all content respects the dignity of those you are fundraising for.',
          'Do not use copyrighted material without permission.',
          'Sensitive situations (medical issues, etc.) should be portrayed with dignity.',
        ],
      },
      {
        'title': 'Fund Management',
        'icon': Icons.account_balance_wallet_outlined,
        'guidelines': [
          'Use funds only for the stated campaign purpose.',
          'Maintain accurate records of how funds are spent.',
          'Be prepared to provide evidence of fund usage if requested.',
          'Never use funds for illegal activities.',
          'Report any issues or delays in fund distribution promptly.',
        ],
      },
      {
        'title': 'Campaign Promotion',
        'icon': Icons.campaign_outlined,
        'guidelines': [
          'Do not spam potential donors with excessive messages.',
          'Avoid high-pressure or manipulative fundraising tactics.',
          'Be honest about campaign urgency and needs.',
          'Do not make false claims about endorsements or partnerships.',
          'Respect the privacy of your donors.',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community Guidelines',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              color: const Color(0xFF8A2BE2),
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Community Guidelines',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'These guidelines help ensure JamiiFund remains a trusted, safe, and respectful platform for all users.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Introduction
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'At JamiiFund, we believe in the power of community to create positive change. Our community guidelines establish the expectations for all users to maintain trust, safety, and respect on our platform. By using JamiiFund, you agree to follow these guidelines.',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                ),
              ),
            ),
            
            // Guidelines by category
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: guidelineCategories.length,
              itemBuilder: (context, index) {
                final category = guidelineCategories[index];
                return _buildGuidelineCategory(category);
              },
            ),
            
            // Consequences section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consequences of Violating Guidelines',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Depending on the severity and frequency of violations, JamiiFund may take one or more of the following actions:',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      _buildConsequenceItem('Issuing a warning'),
                      _buildConsequenceItem('Temporarily suspending your account'),
                      _buildConsequenceItem('Removing campaign content'),
                      _buildConsequenceItem('Permanently banning you from the platform'),
                      _buildConsequenceItem('Withholding funds pending review'),
                      _buildConsequenceItem('Legal action in severe cases'),
                    ],
                  ),
                ],
              ),
            ),
            
            // Reporting section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reporting Violations',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If you encounter content that violates these guidelines, please report it to help keep our community safe:',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  _buildReportStep('1', 'Click the "Report" button on the campaign or comment'),
                  _buildReportStep('2', 'Select the type of violation'),
                  _buildReportStep('3', 'Provide specific details about the violation'),
                  _buildReportStep('4', 'Submit your report'),
                  const SizedBox(height: 12),
                  Text(
                    'Our team will review all reports and take appropriate action. Thank you for helping maintain a positive community.',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Center(
              child: Text(
                'These guidelines may be updated periodically. Last updated: September 15, 2025',
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineCategory(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF8A2BE2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  category['title'] as String,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (category['guidelines'] as List<String>).map((guideline) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF8A2BE2),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          guideline,
                          style: GoogleFonts.nunito(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsequenceItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

