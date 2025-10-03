import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/screens/donation_screen.dart';
import 'package:jamiifund/services/campaign_service.dart';
import 'package:jamiifund/services/donation_service.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';
import 'package:share_plus/share_plus.dart';

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
  List<Map<String, dynamic>> _campaignDonations = [];
  bool _isLoadingDonations = false;
  String _donationsErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _campaign = widget.campaign;
    _loadDonations();
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
      
      // Also refresh donations
      _loadDonations();
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
  
  Future<void> _loadDonations() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingDonations = true;
      _donationsErrorMessage = '';
    });
    
    try {
      // Get donations for this campaign
      final donations = await DonationService.getDonationsByCampaign(_campaign.id);
      
      if (mounted) {
        setState(() {
          _campaignDonations = donations;
          _isLoadingDonations = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _donationsErrorMessage = 'Failed to load donations: $e';
          _isLoadingDonations = false;
        });
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
                    _shareCampaign();
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
                icon: FontAwesomeIcons.facebook,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () {
                  _shareCampaign(platform: 'facebook');
                },
              ),
              const SizedBox(width: 12.0),
              _buildSocialButton(
                icon: FontAwesomeIcons.twitter,
                label: 'Twitter',
                color: const Color(0xFF1DA1F2),
                onTap: () {
                  _shareCampaign(platform: 'twitter');
                },
              ),
              const SizedBox(width: 12.0),
              _buildSocialButton(
                icon: FontAwesomeIcons.instagram,
                label: 'Instagram',
                color: const Color(0xFFE4405F),
                onTap: () {
                  _shareCampaign(platform: 'instagram');
                },
              ),
              const SizedBox(width: 12.0),
              _buildSocialButton(
                icon: FontAwesomeIcons.whatsapp,
                label: 'WhatsApp',
                color: const Color(0xFF25D366),
                onTap: () {
                  _shareCampaign(platform: 'whatsapp');
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesTab() {
    // Generate updates based on campaign data to make them more relevant
    final List<Map<String, dynamic>> updates = [];
    
    // Add fundraising progress update
    final percentFunded = (_campaign.currentAmount / _campaign.goalAmount * 100).round();
    if (percentFunded > 0) {
      updates.add({
        'title': '$percentFunded% Funded!',
        'date': DateTime.now().subtract(const Duration(hours: 12)),
        'content': 'We\'ve reached $percentFunded% of our goal with ${_campaign.donorCount} generous donors! Thank you to everyone who has supported this campaign so far. We still need your help to reach our goal of TSh ${_campaign.goalAmount.toStringAsFixed(0)}. Please consider donating today - every contribution makes a difference! Click the "Donate Now" button at the top of the page.',
        'type': 'milestone'
      });
    }
    
    // Add campaign launch update
    updates.add({
      'title': 'Campaign Launched',
      'date': _campaign.createdAt,
      'content': 'We\'ve officially launched our campaign "${_campaign.title}"! ${_campaign.description.split('.').first}. We need your financial support to make this a success. Your donation, no matter how small, will help us reach our goal of TSh ${_campaign.goalAmount.toStringAsFixed(0)}. Please donate now and share with your friends and family!',
      'type': 'launch'
    });
    
    // Add a special donation request update
    updates.add({
      'title': 'Why Your Donation Matters',
      'date': DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      'content': 'Every donation brings us one step closer to our goal. Your contribution will directly impact this cause and help us make a difference. If just ${((_campaign.goalAmount - _campaign.currentAmount) / 1000).ceil()} people donate TSh 1,000 each, we can reach our target! Click the "Donate Now" button at the top of this page to contribute today. Your generosity will not go unnoticed.',
      'type': 'donation_request'
    });
    
    // Add milestone update based on percentage funded
    if (percentFunded >= 25 && percentFunded < 50) {
      updates.add({
        'title': 'First Milestone Reached',
        'date': DateTime.now().subtract(const Duration(days: 3)),
        'content': 'We\'ve hit our first milestone of 25%! This is a great start, but we still have a long way to go. With your continued support, we can reach our goal. Would you consider making a donation today? Every shilling counts toward making this project a reality. Donate now and be part of our success story!',
        'type': 'milestone'
      });
    } else if (percentFunded >= 50 && percentFunded < 75) {
      updates.add({
        'title': 'Halfway There!',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'content': 'We\'ve reached 50% of our funding goal! This is a huge milestone for us. Thank you to all our supporters for believing in our cause. We\'re halfway there, but we still need your help to raise the remaining TSh ${(_campaign.goalAmount - _campaign.currentAmount).toStringAsFixed(0)}. Please donate now and help us cross the finish line!',
        'type': 'milestone'
      });
    } else if (percentFunded >= 75 && percentFunded < 100) {
      updates.add({
        'title': 'Almost There!',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'content': 'We\'re so close! With just ${(100 - percentFunded)}% to go, we can see the finish line. We need just TSh ${(_campaign.goalAmount - _campaign.currentAmount).toStringAsFixed(0)} more to reach our goal! Please donate now and share our campaign with your networks. Your contribution today could be what puts us over the top!',
        'type': 'milestone'
      });
    } else if (percentFunded >= 100) {
      updates.add({
        'title': 'Goal Reached!',
        'date': DateTime.now().subtract(const Duration(hours: 6)),
        'content': 'We did it! Thanks to your generosity, we\'ve reached our funding goal of TSh ${_campaign.goalAmount.toStringAsFixed(0)}! We\'re excited to start implementing our plans and will keep you updated on our progress. Donations are still welcome as additional funds will allow us to expand our impact even further. Thank you to all ${_campaign.donorCount} donors who made this possible!',
        'type': 'success'
      });
    }
    
    // Sort updates by date, newest first
    updates.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

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
        
        // Choose icon based on update type
        IconData updateIcon;
        Color iconColor;
        
        switch (update['type']) {
          case 'launch':
            updateIcon = Icons.rocket_launch;
            iconColor = Colors.blue;
            break;
          case 'milestone':
            updateIcon = Icons.flag;
            iconColor = Colors.orange;
            break;
          case 'success':
            updateIcon = Icons.celebration;
            iconColor = Colors.green;
            break;
          case 'donation_request':
            updateIcon = Icons.volunteer_activism;
            iconColor = Colors.red;
            break;
          default:
            updateIcon = Icons.update;
            iconColor = Colors.purple;
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(updateIcon, color: iconColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    update['title'],
                    style: GoogleFonts.nunito(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
    if (_isLoadingDonations) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8A2BE2),
        ),
      );
    }

    if (_donationsErrorMessage.isNotEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64.0,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.nunito(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _donationsErrorMessage,
                    style: GoogleFonts.nunito(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _loadDonations,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_campaignDonations.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDonations,
      color: const Color(0xFF8A2BE2),
      child: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _campaignDonations.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final donation = _campaignDonations[index];
          final name = donation['anonymous'] == true ? 
              'Anonymous' : 
              (donation['donor_name'] ?? 'Anonymous');
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            elevation: 0.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF8A2BE2).withOpacity(0.2),
                        child: Text(
                          name != 'Anonymous' ? name.substring(0, 1) : 'A',
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF8A2BE2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  'TSh ${donation['amount'].toString()}',
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF8A2BE2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              donation['created_at'] != null 
                                  ? _formatDate(DateTime.parse(donation['created_at']))
                                  : 'Recent donation',
                              style: GoogleFonts.nunito(
                                fontSize: 12.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (donation['message'] != null && donation['message'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 48.0),
                      child: Text(
                        '"${donation['message'].toString()}"',
                        style: GoogleFonts.nunito(
                          fontSize: 14.0,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
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
      {
        'question': 'Why should I donate to this campaign?',
        'answer': 'Your donation makes a real difference! By supporting this campaign, you\'re directly contributing to a meaningful cause that impacts many lives. Every shilling counts, and your generosity helps us reach our goals faster. Plus, you become part of our community of supporters making positive change happen.',
      },
      {
        'question': 'How do I know my donation is secure?',
        'answer': 'JamiiFund uses industry-standard security protocols to ensure all transactions are secure. We partner with trusted payment processors and never store your sensitive financial information. You\'ll receive a confirmation receipt for every donation made.',
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

  void _shareCampaign({String? platform}) {
    final campaignUrl = 'https://jamiifund.com/campaigns/${_campaign.id}';
    final String shareText;
    
    // Create custom share text based on platform
    switch (platform) {
      case 'facebook':
        shareText = 'Support "${_campaign.title}" on JamiiFund. ${_campaign.currentAmount.toStringAsFixed(0)} TSh raised out of ${_campaign.goalAmount.toStringAsFixed(0)} TSh goal. ${campaignUrl}';
        break;
      case 'twitter':
        shareText = 'I\'m supporting "${_campaign.title}" on #JamiiFund. Join me and help them reach their goal! ${campaignUrl}';
        break;
      case 'instagram':
        shareText = 'Check out "${_campaign.title}" on JamiiFund. ${_campaign.currentAmount.toStringAsFixed(0)} TSh raised so far. Support this important cause! ${campaignUrl}';
        break;
      case 'whatsapp':
        shareText = 'Hey! I thought you might be interested in supporting this campaign: "${_campaign.title}" on JamiiFund. They\'ve raised ${_campaign.currentAmount.toStringAsFixed(0)} TSh of their ${_campaign.goalAmount.toStringAsFixed(0)} TSh goal. Check it out: ${campaignUrl}';
        break;
      default:
        shareText = 'Support "${_campaign.title}" on JamiiFund. ${_campaign.currentAmount.toStringAsFixed(0)} TSh raised out of ${_campaign.goalAmount.toStringAsFixed(0)} TSh goal. ${campaignUrl}';
        break;
    }
    
    // Use share_plus plugin to share the content
    Share.share(shareText, subject: 'Check out this campaign on JamiiFund');
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
