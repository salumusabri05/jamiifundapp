import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/screens/donation_screen.dart';
import 'package:jamiifund/services/campaign_service.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class CampaignDetailsPage extends StatefulWidget {
  final Campaign campaign;

  const CampaignDetailsPage({
    super.key,
    required this.campaign,
  });

  @override
  State<CampaignDetailsPage> createState() => _CampaignDetailsPageState();
}

class _CampaignDetailsPageState extends State<CampaignDetailsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isExpanded = false;
  late Campaign _campaign;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _campaign = widget.campaign;
  }
  
  Future<void> _refreshCampaignDetails() async {
    try {
      // Fetch updated campaign details
      final updatedCampaign = await CampaignService.getCampaignById(_campaign.id);
      
      if (mounted) {
        setState(() {
          _campaign = updatedCampaign;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh campaign details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate percentage of goal reached
    final percentComplete = _campaign.goalAmount > 0
        ? (_campaign.currentAmount / _campaign.goalAmount * 100)
            .clamp(0, 100)
        : 0.0;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 250.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF8A2BE2),
              iconTheme: const IconThemeData(color: Colors.white),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Campaign image
                    Hero(
                      tag: 'campaign_image_${_campaign.id}',
                      child: Image.network(
                        _campaign.imageUrl ?? 
                            'https://placehold.co/600x400?text=No+Image',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.error_outline,
                                color: Colors.grey,
                                size: 60,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient overlay for text visibility
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    // Title and category at the bottom
                    Positioned(
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _campaign.title,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              _campaign.category,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Share button
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  onPressed: () {
                    // TODO: Implement share functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing campaign...')),
                    );
                  },
                ),
                // Favorite/bookmark button
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // TODO: Implement bookmark functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Campaign bookmarked!')),
                    );
                  },
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF8A2BE2),
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: const Color(0xFF8A2BE2),
                  tabs: const [
                    Tab(text: 'Story'),
                    Tab(text: 'Updates'),
                    Tab(text: 'Donors'),
                    Tab(text: 'FAQs'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: Column(
          children: [
            // Progress section
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TSh ${_campaign.currentAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: const Color(0xFF8A2BE2),
                        ),
                      ),
                      Text(
                        'Goal: TSh ${_campaign.goalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.nunito(
                          fontSize: 14.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  LinearProgressIndicator(
                    value: percentComplete / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF8A2BE2),
                    ),
                    minHeight: 8.0,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_campaign.donorCount} donors',
                        style: GoogleFonts.nunito(
                          color: Colors.grey[600],
                          fontSize: 14.0,
                        ),
                      ),
                      Text(
                        '${_campaign.daysLeft} days left',
                        style: GoogleFonts.nunito(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DonationScreen(campaign: _campaign),
                        ),
                      ).then((donated) {
                        // If donation was successful, refresh the campaign details
                        if (donated == true) {
                          _refreshCampaignDetails();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thank you for your donation!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8A2BE2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      minimumSize: const Size(double.infinity, 48.0),
                    ),
                    child: Text(
                      'Donate Now',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1.0),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Story tab
                  _buildStoryTab(),
                  
                  // Updates tab
                  _buildUpdatesTab(),
                  
                  // Donors tab
                  _buildDonorsTab(),
                  
                  // FAQs tab
                  _buildFAQsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildStoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Story',
            style: GoogleFonts.nunito(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          AnimatedCrossFade(
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _campaign.description,
                  style: GoogleFonts.nunito(fontSize: 16.0),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  child: Text(
                    'Read More',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF8A2BE2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _campaign.description,
                  style: GoogleFonts.nunito(fontSize: 16.0),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = false;
                    });
                  },
                  child: Text(
                    'Show Less',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF8A2BE2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 24.0),
          Text(
            'Campaign Creator',
            style: GoogleFonts.nunito(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8A2BE2).withOpacity(0.2),
              child: const Icon(
                Icons.person,
                color: Color(0xFF8A2BE2),
              ),
            ),
            title: Text(
              _campaign.createdByName ?? 'Anonymous',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Campaign created on ${_formatDate(_campaign.createdAt)}',
              style: GoogleFonts.nunito(
                fontSize: 12.0,
                color: Colors.grey[600],
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.message_outlined,
                color: Color(0xFF8A2BE2),
              ),
              onPressed: () {
                // TODO: Implement contact creator functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contact feature coming soon'),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const SizedBox(height: 24.0),
          Text(
            'Share this campaign',
            style: GoogleFonts.nunito(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () {
                  // TODO: Share to Facebook
                },
              ),
              const SizedBox(width: 12.0),
              _buildSocialButton(
                icon: Icons.link,
                label: 'Copy Link',
                color: Colors.grey[700]!,
                onTap: () {
                  Clipboard.setData(ClipboardData(
                    text: 'https://jamiifund.com/campaigns/${_campaign.id}',
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied to clipboard')),
                  );
                },
              ),
              const SizedBox(width: 12.0),
              _buildSocialButton(
                icon: Icons.message,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {
                  // TODO: Share to WhatsApp
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab() {
    // Example updates, in a real app these would come from your database
    final List<Map<String, dynamic>> updates = [
      {
        'title': 'Construction has begun!',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'content': 'We are excited to announce that construction has begun on our project. Thanks to your generous donations, we have been able to hire local workers and purchase materials.',
      },
      {
        'title': 'First milestone reached',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'content': 'We have reached our first milestone! The foundation has been laid and we are now working on the walls.',
      },
    ];

    if (updates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.update_disabled,
              size: 64.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16.0),
            Text(
              'No updates yet',
              style: GoogleFonts.nunito(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Check back later for updates on this campaign',
              style: GoogleFonts.nunito(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: updates.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final update = updates[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  update['title'],
                  style: GoogleFonts.nunito(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(update['date']),
                  style: GoogleFonts.nunito(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              update['content'],
              style: GoogleFonts.nunito(fontSize: 14.0),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDonorsTab() {
    // Example donors, in a real app these would come from your database
    final List<Map<String, dynamic>> donors = [
      {
        'name': 'John Doe',
        'amount': 5000,
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'comment': 'Great initiative! Keep up the good work.',
      },
      {
        'name': 'Jane Smith',
        'amount': 10000,
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'comment': 'Happy to support this important cause.',
      },
      {
        'name': 'Anonymous',
        'amount': 2000,
        'date': DateTime.now().subtract(const Duration(days: 7)),
        'comment': null,
      },
    ];

    if (donors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              size: 64.0,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16.0),
            Text(
              'No donors yet',
              style: GoogleFonts.nunito(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Be the first to donate to this campaign!',
              style: GoogleFonts.nunito(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationScreen(campaign: _campaign),
                  ),
                ).then((donated) {
                  if (donated == true) {
                    _refreshCampaignDetails();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Donate Now',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshCampaignDetails,
      color: const Color(0xFF8A2BE2),
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: donors.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final donor = donors[index];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8A2BE2).withOpacity(0.2),
              child: Text(
                donor['name'].substring(0, 1),
                style: GoogleFonts.nunito(
                  color: const Color(0xFF8A2BE2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Text(
                  donor['name'],
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8.0),
                Text(
                  'TSh ${donor['amount'].toStringAsFixed(0)}',
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF8A2BE2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(donor['date']),
                  style: GoogleFonts.nunito(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
                if (donor['comment'] != null) ...[
                  const SizedBox(height: 4.0),
                  Text(
                    donor['comment'],
                    style: GoogleFonts.nunito(
                      fontSize: 14.0,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFAQsTab() {
    // Example FAQs, in a real app these would come from your database
    final List<Map<String, dynamic>> faqs = [
      {
        'question': 'How will the funds be used?',
        'answer': 'The funds will be used to purchase materials, hire labor, and cover administrative costs. We provide regular updates on how the money is being spent.',
      },
      {
        'question': 'Is my donation tax-deductible?',
        'answer': 'Yes, all donations are tax-deductible. You will receive a receipt for your donation that you can use for tax purposes.',
      },
      {
        'question': 'What happens if the goal is not reached?',
        'answer': 'Even if we don\'t reach our full goal, we will still use the funds collected to make as much progress as possible on the project. We are committed to completing the project regardless.',
      },
      {
        'question': 'Can I donate anonymously?',
        'answer': 'Yes, you can choose to make your donation anonymous during the checkout process.',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ExpansionTile(
            title: Text(
              faq['question'],
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                fontSize: 16.0,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Text(
                  faq['answer'],
                  style: GoogleFonts.nunito(fontSize: 14.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20.0,
            ),
            const SizedBox(width: 8.0),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
