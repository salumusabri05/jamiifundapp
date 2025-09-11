import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class SuccessStoriesPage extends StatelessWidget {
  const SuccessStoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock success stories
    final successStories = [
      {
        'title': 'Water Well Project in Moshi',
        'image': 'https://images.unsplash.com/photo-1576860525375-4e7b4e00155c',
        'amount': 'TSh 5,200,000',
        'location': 'Moshi, Tanzania',
        'description': 'After raising funds for a community water well, over 500 residents now have access to clean water daily. The project was completed in just 3 months after receiving full funding.',
        'impact': '500+ community members impacted',
      },
      {
        'title': 'Classroom Construction in Arusha',
        'image': 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6',
        'amount': 'TSh 8,750,000',
        'location': 'Arusha, Tanzania',
        'description': 'A rural school received funding for two new classrooms, allowing 80 more students to attend school. The campaign exceeded its goal by 15%, enabling additional supplies for students.',
        'impact': '80 additional students can attend school',
      },
      {
        'title': 'Medical Equipment for Zanzibar Clinic',
        'image': 'https://images.unsplash.com/photo-1584036561566-baf8f5f1b144',
        'amount': 'TSh 12,300,000',
        'location': 'Zanzibar, Tanzania',
        'description': 'A community health clinic received vital medical equipment thanks to 230 donors. The campaign provided ultrasound machines, blood pressure monitors, and other essential supplies.',
        'impact': 'Serves over 3,000 patients annually',
      },
      {
        'title': 'Agricultural Training for Women Farmers',
        'image': 'https://images.unsplash.com/photo-1629903552400-4a753299ca86',
        'amount': 'TSh 4,800,000',
        'location': 'Dodoma, Tanzania',
        'description': 'A successful campaign funded training for 45 women in sustainable farming techniques. Participants reported a 30% increase in crop yields within the first harvest season.',
        'impact': '45 women trained, 30% increased crop yields',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Success Stories',
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
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8A2BE2).withOpacity(0.8),
                    const Color(0xFF9370DB).withOpacity(0.9),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Real Impact, Real Stories',
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Discover how JamiiFund campaigns are making a difference in communities across Tanzania.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Success stories list
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Featured Success Stories',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...successStories.map((story) => _buildSuccessStoryCard(context, story)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessStoryCard(BuildContext context, Map<String, String> story) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              story['image']!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        'Funded: ${story['amount']}',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: const Color(0xFF8A2BE2),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    Text(
                      story['location']!,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  story['title']!,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  story['description']!,
                  style: GoogleFonts.nunito(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.volunteer_activism,
                      color: Color(0xFF8A2BE2),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      story['impact']!,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8A2BE2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to detailed success story
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8A2BE2),
                    side: const BorderSide(color: Color(0xFF8A2BE2)),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Read Full Story',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                    ),
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

