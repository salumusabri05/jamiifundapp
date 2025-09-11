import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/screens/discover_screen.dart';
import 'package:jamiifund/screens/create_campaign_screen.dart';
import 'package:jamiifund/screens/donations_screen.dart';
import 'package:jamiifund/screens/profile_screen.dart';
import 'package:jamiifund/services/campaign_service.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of screens for bottom navigation
    final screens = [
      const HomeContent(),
      const DiscoverScreen(),
      const CreateCampaignScreen(),
      const DonationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'JamiiFund',
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
      body: IndexedStack(
        index: _selectedIndex, 
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex),
    );
  }
}

// Separate widget for Home tab content
class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with TickerProviderStateMixin {
  bool _isLoading = true;
  List<Campaign> _activeCampaigns = [];
  String _errorMessage = '';
  
  // Mock data for fallback
  final List<Campaign> _mockCampaigns = [
    Campaign(
      id: '1',
      title: 'Help Build a School in Rural Tanzania',
      description: 'We aim to build a primary school in Mwanza region to support 300 children.',
      category: 'Education',
      goalAmount: 15000,
      currentAmount: 7500,
      endDate: DateTime.now().add(const Duration(days: 45)),
      imageUrl: 'https://images.unsplash.com/photo-1509062522246-3755977927d7',
      isFeatured: true,
    ),
    Campaign(
      id: '2',
      title: 'Clean Water for Arusha Village',
      description: 'Help us bring clean water to over 500 families in Arusha.',
      category: 'Water',
      goalAmount: 8000,
      currentAmount: 5600,
      endDate: DateTime.now().add(const Duration(days: 30)),
      imageUrl: 'https://images.unsplash.com/photo-1594398901394-4e34939a4fd0',
      isFeatured: true,
    ),
  ];
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    
    // Fetch campaigns data
    _fetchCampaigns();
  }

  // Fetch campaign data from Supabase
  Future<void> _fetchCampaigns() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      print('Fetching all campaigns...');
      final all = await CampaignService.getAllCampaigns();
      print('All campaigns fetched: ${all.length}');
      
      // Filter active campaigns
      final active = all.where((c) => c.isActive).toList();
      print('Active campaigns: ${active.length}');
      
      // Update state with fetched data
      if (mounted) {
        setState(() {
          _activeCampaigns = active;
          _isLoading = false;
          
          // If no campaigns found, use mock data
          if (_activeCampaigns.isEmpty) {
            print('No active campaigns found, using mock data');
            _activeCampaigns = _mockCampaigns;
          }
        });
      }
    } catch (e) {
      print('Error fetching campaigns: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load campaigns: $e';
          _isLoading = false;
          
          // Use mock data on error
          _activeCampaigns = _mockCampaigns;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
          : _errorMessage.isNotEmpty && _activeCampaigns.isEmpty
              ? Center(child: Text(_errorMessage))
              : RefreshIndicator(
                  color: const Color(0xFF8A2BE2),
                  onRefresh: _fetchCampaigns,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome banner
                        _buildWelcomeBanner()
                            .animate(controller: _fadeController)
                            .fadeIn(duration: 800.ms, curve: Curves.easeOut),
                        
                        const SizedBox(height: 16),
                        
                        // Categories
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildCategories()
                              .animate(controller: _slideController)
                              .slideX(begin: 0.2, end: 0, curve: Curves.easeOut),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Active campaigns
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Active Campaigns',
                            style: GoogleFonts.nunito(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Campaign list
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _activeCampaigns.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemBuilder: (context, index) {
                            return _buildCampaignCard(_activeCampaigns[index], index)
                                .animate(controller: _slideController)
                                .slideX(
                                  begin: 0.2,
                                  end: 0,
                                  delay: (100 * index).ms,
                                  curve: Curves.easeOut,
                                );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  // Categories
  Widget _buildCategories() {
    final categories = ['All', 'Education', 'Health', 'Water', 'Food', 'Housing'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(
                    categories[index],
                    style: GoogleFonts.nunito(
                      color: index == 0 ? Colors.white : Colors.black87,
                      fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF8A2BE2),
                  selected: index == 0,
                  onSelected: (bool selected) {
                    // TODO: Implement category filtering
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Welcome banner
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to JamiiFund',
            style: GoogleFonts.nunito(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8A2BE2),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Support community projects across Tanzania',
            style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey[700]),
          ),
          // Removed buttons as requested
        ],
      ),
    );
  }

  // Campaign card
  Widget _buildCampaignCard(Campaign campaign, int index) {
    // Calculate percentage of goal reached
    final percentComplete = campaign.goalAmount > 0
        ? (campaign.currentAmount / campaign.goalAmount * 100).clamp(0, 100)
        : 0.0;
    
    // Calculate days remaining
    final daysRemaining = campaign.endDate.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campaign image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              campaign.imageUrl ?? 'https://placehold.co/600x400?text=No+Image',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Campaign details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  campaign.title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  campaign.description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TSh ${campaign.currentAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8A2BE2),
                          ),
                        ),
                        Text(
                          'TSh ${campaign.goalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.nunito(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentComplete / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8A2BE2),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percentComplete.toStringAsFixed(0)}% funded',
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '$daysRemaining days left',
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Category chip and donate button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Chip(
                      label: Text(
                        campaign.category,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: const Color(0xFF8A2BE2),
                        ),
                      ),
                      backgroundColor: const Color(0xFF8A2BE2).withOpacity(0.1),
                      padding: EdgeInsets.zero,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Navigate to campaign details
                      },
                      icon: const Icon(
                        Icons.volunteer_activism,
                        size: 18,
                      ),
                      label: Text(
                        'Donate',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF8A2BE2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
