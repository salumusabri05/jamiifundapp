import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/services/donation_service.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _userDonations = [];
  List<Campaign> _userCampaigns = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    final user = UserService.getCurrentUser();
    if (user == null) {
      setState(() {
        _errorMessage = 'Please log in to view your donations';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Load user donations and campaigns in parallel
      final userDonations = await DonationService.getDonationsByUserId(user.id);
      final userCampaigns = await DonationService.getCampaignsByUserId(user.id);
      
      if (mounted) {
        setState(() {
          _userDonations = userDonations;
          _userCampaigns = userCampaigns;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Donations',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF8A2BE2),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8A2BE2),
          tabs: const [
            Tab(text: 'My Donations'),
            Tab(text: 'My Campaigns'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4), // Updated to 4 since we added community tab
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDonationsTab(),
            _buildCampaignsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8A2BE2),
        ),
      );
    }
    
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _errorMessage,
                style: GoogleFonts.nunito(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_userDonations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No donations yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your donations will appear here',
              style: GoogleFonts.nunito(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userDonations.length,
      itemBuilder: (context, index) {
        final donation = _userDonations[index];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              donation['campaign_title'] as String,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  'Donated on: ${(donation['date'] as DateTime).day}/${(donation['date'] as DateTime).month}/${(donation['date'] as DateTime).year}',
                  style: GoogleFonts.nunito(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: donation['status'] == 'Completed' 
                        ? Colors.green.shade100 
                        : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    donation['status'] as String,
                    style: GoogleFonts.nunito(
                      color: donation['status'] == 'Completed' 
                          ? Colors.green.shade800 
                          : Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Text(
              '\$${donation['amount']}',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF8A2BE2),
              ),
            ),
            onTap: () {
              // TODO: Navigate to donation details
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => CampaignDetailsPage(
              //       campaignId: donation['campaign_id'] as String,
              //     ),
              //   ),
              // );
            },
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildCampaignsTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No campaigns yet',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Campaigns you create will appear here',
              style: GoogleFonts.nunito(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate to create campaign screen
                Navigator.pushNamed(context, '/create-campaign');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Create a Campaign',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _userCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = _userCampaigns[index];
        final double progress = campaign.currentAmount / campaign.goalAmount;
        
        Color statusColor;
        if (campaign.isActive) {
          statusColor = Colors.green;
        } else if (campaign.isSuccessful) {
          statusColor = Colors.blue;
        } else {
          statusColor = Colors.red;
        }
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.title,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        campaign.isActive ? 'Active' : (campaign.isSuccessful ? 'Completed' : 'Expired'),
                        style: GoogleFonts.nunito(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8A2BE2)),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${campaign.currentAmount} raised',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Goal: \$${campaign.goalAmount}',
                      style: GoogleFonts.nunito(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${campaign.donorCount} donors',
                      style: GoogleFonts.nunito(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (campaign.isActive)
                      Text(
                        '${campaign.daysLeft} days left',
                        style: GoogleFonts.nunito(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to campaign edit
                        Navigator.pushNamed(
                          context, 
                          '/edit-campaign',
                          arguments: {'campaignId': campaign.id},
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8A2BE2),
                        side: const BorderSide(color: Color(0xFF8A2BE2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to campaign details
                        Navigator.pushNamed(
                          context,
                          '/campaign-details',
                          arguments: {'id': campaign.id},
                        );
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('Details'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8A2BE2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
