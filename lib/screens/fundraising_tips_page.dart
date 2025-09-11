import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class FundraisingTipsPage extends StatelessWidget {
  const FundraisingTipsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Categories of tips
    final tipCategories = [
      {
        'icon': Icons.campaign,
        'title': 'Campaign Strategy',
        'tips': [
          {
            'title': 'Set a realistic fundraising goal',
            'description': 'Research similar campaigns and consider your network size when setting your target amount.',
          },
          {
            'title': 'Create a compelling campaign story',
            'description': 'Share personal experiences, be specific about your needs, and explain the impact donations will make.',
          },
          {
            'title': 'Use high-quality visuals',
            'description': 'Include clear photos and videos that show your project, beneficiaries, or the problem you are solving.',
          },
        ],
      },
      {
        'icon': Icons.share,
        'title': 'Promotion & Sharing',
        'tips': [
          {
            'title': 'Leverage social media platforms',
            'description': 'Share your campaign on WhatsApp, Instagram, Facebook, and Twitter to reach different audiences.',
          },
          {
            'title': 'Create shareable content',
            'description': 'Design eye-catching images with your campaign link that supporters can easily share with their networks.',
          },
          {
            'title': 'Send personalized messages',
            'description': 'Reach out directly to close contacts with personal messages rather than generic campaign links.',
          },
        ],
      },
      {
        'icon': Icons.people,
        'title': 'Engaging Supporters',
        'tips': [
          {
            'title': 'Provide regular updates',
            'description': 'Keep donors informed about your progress, milestones, and how their contributions are being used.',
          },
          {
            'title': 'Thank donors promptly',
            'description': 'Send personalized thank-you messages to each donor and recognize them publicly (with permission).',
          },
          {
            'title': 'Offer different ways to help',
            'description': 'In addition to monetary donations, suggest ways supporters can help by sharing or volunteering.',
          },
        ],
      },
      {
        'icon': Icons.trending_up,
        'title': 'Maintaining Momentum',
        'tips': [
          {
            'title': 'Create a fundraising calendar',
            'description': 'Plan key moments to promote your campaign, such as launch day, halfway point, and final push.',
          },
          {
            'title': 'Host virtual or in-person events',
            'description': 'Organize gatherings to raise awareness and collect donations from attendees.',
          },
          {
            'title': 'Partner with local businesses',
            'description': 'Ask businesses to promote your campaign or contribute a percentage of sales on certain days.',
          },
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fundraising Tips',
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
            // Banner section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF8A2BE2).withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expert Fundraising Tips',
                    style: GoogleFonts.nunito(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Strategies and advice to help your campaign succeed',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            // Intro text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Successfully raising funds requires strategy, persistence, and effective communication. Browse through our expert tips to maximize your campaign\'s potential.',
                style: GoogleFonts.nunito(
                  fontSize: 16,
                ),
              ),
            ),
            // Tips by category
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tipCategories.length,
              itemBuilder: (context, index) {
                final category = tipCategories[index];
                return _buildTipCategory(context, category);
              },
            ),
            // Final CTA
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8A2BE2).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF8A2BE2).withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline,
                        color: Color(0xFF8A2BE2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ready to start fundraising?',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apply these tips to create a campaign that resonates with donors and achieves your fundraising goals.',
                    style: GoogleFonts.nunito(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to create campaign
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A2BE2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Create Your Campaign',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildTipCategory(BuildContext context, Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Icon(
            category['icon'] as IconData,
            color: const Color(0xFF8A2BE2),
          ),
          title: Text(
            category['title'] as String,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (category['tips'] as List).length,
              itemBuilder: (context, index) {
                final tip = category['tips'][index];
                return _buildTipItem(context, tip);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(BuildContext context, Map<String, String> tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: Color(0xFF8A2BE2),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip['title']!,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              tip['description']!,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Divider(
              color: Colors.grey[200],
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

