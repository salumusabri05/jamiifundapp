import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/services/campaign_service.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({Key? key}) : super(key: key);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final List<String> categories = [
    'All',
    'Education',
    'Health',
    'Water',
    'Food',
    'Housing',
    'Agriculture',
    'Technology'
  ];

  String selectedCategory = 'All';
  bool _isLoading = true;
  List<Campaign> _campaigns = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
  }

  Future<void> _fetchCampaigns() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      List<Campaign> campaigns;
      if (selectedCategory == 'All') {
        campaigns = await CampaignService.getAllCampaigns();
      } else {
        campaigns = await CampaignService.getCampaignsByCategory(selectedCategory);
      }

      // Filter for active campaigns
      final activeCampaigns = campaigns.where((c) => c.isActive).toList();

      setState(() {
        _campaigns = activeCampaigns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load campaigns: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Discover Campaigns',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF8A2BE2)),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: categories.map((category) {
                  final isSelected = category == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedCategory = category;
                        });
                        _fetchCampaigns(); // Fetch campaigns when category changes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF8A2BE2)
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        elevation: 0,
                      ),
                      child: Text(category),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
              : _errorMessage.isNotEmpty && _campaigns.isEmpty
                ? Center(child: Text(_errorMessage))
                : _campaigns.isEmpty
                  ? Center(
                      child: Text(
                        'No campaigns found for this category',
                        style: GoogleFonts.nunito(fontSize: 16),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchCampaigns,
                      color: const Color(0xFF8A2BE2),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = _campaigns[index];
                          return InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/campaign_details',
                                arguments: campaign,
                              );
                            },
                            borderRadius: BorderRadius.circular(16.0),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                      // Campaign image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16.0),
                        ),
                        child: Hero(
                          tag: 'campaign_image_${campaign.id}',
                          child: Image.network(
                            campaign.imageUrl ?? 'https://placehold.co/600x400?text=No+Image',
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      
                      // Campaign details
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              campaign.title,
                              style: GoogleFonts.nunito(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              campaign.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            LinearProgressIndicator(
                              value: campaign.currentAmount / campaign.goalAmount,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8A2BE2)),
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'TSh ${campaign.currentAmount.toStringAsFixed(0)} raised',
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Goal: TSh ${campaign.goalAmount.toStringAsFixed(0)}',
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${campaign.donorCount} donors',
                                  style: GoogleFonts.nunito(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${campaign.daysLeft} days left',
                                  style: GoogleFonts.nunito(
                                    color: Colors.red[400],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: null, // Button is just a visual indicator, card is already clickable
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    color: Color(0xFF8A2BE2),
                                    size: 16,
                                  ),
                                  label: Text(
                                    'View Details',
                                    style: GoogleFonts.nunito(
                                      color: const Color(0xFF8A2BE2),
                                      fontWeight: FontWeight.w600,
                                    ),
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
            },
          ),
          ),
        ),
        ],
      ),
    );
  }
}
