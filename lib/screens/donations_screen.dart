import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class DonationsScreen extends StatefulWidget {
  const DonationsScreen({super.key});

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDonationsTab(),
          _buildCampaignsTab(),
        ],
      ),
    );
  }

  Widget _buildDonationsTab() {
    // This is placeholder data - in a real app you would fetch from your database
    final donations = List.generate(
      5,
      (index) => {
        'id': 'don_${index + 1}',
        'campaign': 'Campaign ${index + 1}',
        'amount': (index + 1) * 100,
        'date': DateTime.now().subtract(Duration(days: index * 3)),
        'status': index % 2 == 0 ? 'Completed' : 'Processing',
      },
    );

    if (donations.isEmpty) {
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
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              donation['campaign'] as String,
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
            },
          ),
        ).animate().fadeIn(duration: 300.ms, delay: (50 * index).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildCampaignsTab() {
    // This is placeholder data - in a real app you would fetch from your database
    final campaigns = List.generate(
      3,
      (index) => {
        'id': 'camp_${index + 1}',
        'title': 'My Campaign ${index + 1}',
        'goalAmount': (index + 1) * 1000,
        'currentAmount': (index + 1) * 500,
        'endDate': DateTime.now().add(Duration(days: 30 - index * 5)),
        'donorCount': (index + 1) * 10,
        'status': index == 0 ? 'Active' : (index == 1 ? 'Completed' : 'Expired'),
      },
    );

    if (campaigns.isEmpty) {
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
                // TODO: Navigate to create campaign screen
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
      itemCount: campaigns.length,
      itemBuilder: (context, index) {
        final campaign = campaigns[index];
        final progress = (campaign['currentAmount'] as int) / (campaign['goalAmount'] as int);
        final daysLeft = (campaign['endDate'] as DateTime).difference(DateTime.now()).inDays;
        
        Color statusColor;
        if (campaign['status'] == 'Active') {
          statusColor = Colors.green;
        } else if (campaign['status'] == 'Completed') {
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
                        campaign['title'] as String,
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
                        campaign['status'] as String,
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
                      '\$${campaign['currentAmount']} raised',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Goal: \$${campaign['goalAmount']}',
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
                      '${campaign['donorCount']} donors',
                      style: GoogleFonts.nunito(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (campaign['status'] == 'Active')
                      Text(
                        '$daysLeft days left',
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
                        // TODO: Edit campaign
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
                        // TODO: View details
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
