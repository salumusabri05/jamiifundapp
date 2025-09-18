import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF8A2BE2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'JamiiFund',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fundraising for a Better Tanzania',
                  style: GoogleFonts.nunito(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildExpandableSection(
            context,
            title: 'About Us',
            icon: Icons.info_outline,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about_us');
            },
          ),
          _buildExpandableSection(
            context,
            title: 'How It Works',
            icon: Icons.help_outline,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/how_it_works');
            },
          ),
          _buildExpandableSection(
            context,
            title: 'Resources',
            icon: Icons.book_outlined,
            children: [
              _buildSubMenuItem(
                context,
                title: 'Blog',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/blog');
                },
              ),
              _buildSubMenuItem(
                context,
                title: 'Success Stories',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/success_stories');
                },
              ),
              _buildSubMenuItem(
                context,
                title: 'Fundraising Tips',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/fundraising_tips');
                },
              ),
            ],
          ),
          _buildExpandableSection(
            context,
            title: 'Legal',
            icon: Icons.gavel_outlined,
            children: [
              _buildSubMenuItem(
                context,
                title: 'Terms of Service',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/terms_of_service');
                },
              ),
              _buildSubMenuItem(
                context,
                title: 'Community Guidelines',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/community_guidelines');
                },
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: Text(
              'Contact Support',
              style: GoogleFonts.nunito(),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/support');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    VoidCallback? onTap,
    List<Widget>? children,
  }) {
    if (children == null) {
      return ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: GoogleFonts.nunito(),
        ),
        onTap: onTap,
      );
    }

    return ExpansionTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: GoogleFonts.nunito(),
      ),
      children: children,
    );
  }

  Widget _buildSubMenuItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 56.0, right: 24.0),
      title: Text(
        title,
        style: GoogleFonts.nunito(),
      ),
      onTap: onTap,
    );
  }
}
