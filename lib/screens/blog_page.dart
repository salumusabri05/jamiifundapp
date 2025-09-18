import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class BlogPage extends StatelessWidget {
  const BlogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock blog posts
    final blogPosts = [
      {
        'title': '5 Ways to Make Your Fundraising Campaign Stand Out',
        'date': 'September 5, 2025',
        'image': 'https://images.unsplash.com/photo-1559030623-0226b1241edd',
        'excerpt': 'Learn the key strategies that can help your campaign reach more donors...',
        'author': 'Maria Joseph',
      },
      {
        'title': 'The Impact of Community Fundraising in Rural Tanzania',
        'date': 'August 28, 2025',
        'image': 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09',
        'excerpt': 'How local fundraising efforts are transforming communities across the country...',
        'author': 'John Mbeki',
      },
      {
        'title': 'Digital Fundraising: Tips for the Modern Campaigner',
        'date': 'August 15, 2025',
        'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
        'excerpt': 'Utilizing social media, email, and mobile platforms to reach a wider audience...',
        'author': 'Sophia Wang',
      },
      {
        'title': 'The Psychology of Giving: Why People Donate',
        'date': 'August 3, 2025',
        'image': 'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6',
        'excerpt': 'Understanding donor motivations can help you craft more effective campaigns...',
        'author': 'David Kimathi',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blog',
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
              'JamiiFund Blog',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Insights, tips, and stories to help you fundraise effectively',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Featured post
            _buildFeaturedPost(context, blogPosts[0]),
            const SizedBox(height: 24),
            // Blog post list
            Text(
              'Latest Posts',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...blogPosts.skip(1).map((post) => _buildBlogPostCard(context, post)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPost(BuildContext context, Map<String, String> post) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              post['image']!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FEATURED',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A2BE2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['title']!,
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post['excerpt']!,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Color(0xFF8A2BE2),
                        child: Icon(Icons.person, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post['author']!,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        post['date']!,
                        style: GoogleFonts.nunito(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogPostCard(BuildContext context, Map<String, String> post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to blog post detail page
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['image']!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title']!,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['excerpt']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${post['date']!} • ${post['author']}',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

