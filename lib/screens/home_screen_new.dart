import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/screens/campaign_details_page.dart';
import 'package:jamiifund/services/campaign_service.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      body: const HomeContent(),
      bottomNavigationBar: AppBottomNavBar(currentIndex: _selectedIndex),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  bool _isLoading = true;
  List<Campaign> _featuredCampaigns = [];
  String _errorMessage = '';
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _fetchCampaigns();
    _initializeVideo();
  }

  void _initializeVideo() {
    try {
      // Check if file exists by attempting to load it
      _videoController = VideoPlayerController.asset('assets/videos/fundraisingtips.mp4');
      
      // Initialize the controller
      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _videoController.setLooping(true);
            // Auto-play the first time
            _videoController.play();
          });
          print('Video initialized successfully');
        }
      }).catchError((error) {
        print('Error initializing video: $error');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
        
        // Fallback to network video if asset video fails
        _initializeNetworkVideo();
      });
    } catch (e) {
      print('Exception while creating video controller: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
      
      // Fallback to network video if asset video fails
      _initializeNetworkVideo();
    }
  }
  
  void _initializeNetworkVideo() {
    try {
      // Use a sample video from the internet as fallback
      _videoController = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4'
      );
      
      _videoController.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _videoController.setLooping(true);
          });
          print('Network video initialized successfully');
        }
      }).catchError((error) {
        print('Error initializing network video: $error');
        if (mounted) {
          setState(() {
            _isVideoInitialized = false;
          });
        }
      });
    } catch (e) {
      print('Exception while creating network video controller: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  Future<void> _fetchCampaigns() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Fetch featured campaigns
      final campaigns = await CampaignService.getFeaturedCampaigns();
      
      // Filter for active campaigns
      final activeCampaigns = campaigns.where((c) => c.isActive).toList();

      if (mounted) {
        setState(() {
          _featuredCampaigns = activeCampaigns;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load campaigns: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _fetchCampaigns,
      color: const Color(0xFF8A2BE2),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero section
            _buildHeroSection(),
            
            const SizedBox(height: 24),
            
            // Video section
            _buildVideoSection(),
            
            const SizedBox(height: 24),
            
            // Featured campaigns section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Featured Campaigns',
                style: GoogleFonts.nunito(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Campaigns
            _isLoading
              ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(color: Color(0xFF8A2BE2)),
                ))
              : _errorMessage.isNotEmpty && _featuredCampaigns.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(_errorMessage),
                    ),
                  )
                : _featuredCampaigns.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'No featured campaigns available.',
                          style: GoogleFonts.nunito(fontSize: 16),
                        ),
                      ),
                    )
                  : _buildCampaignsList(),
                  
            const SizedBox(height: 24),
            
            // How to get started section
            _buildHowToStartSection(),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  ImageProvider _heroImage() {
    try {
      return const AssetImage('assets/images/hero.jpeg');
    } catch (e) {
      print('Error loading hero image: $e');
      // Fallback to a network image if local asset fails
      return const NetworkImage('https://images.unsplash.com/photo-1608266625501-40e178df481a?q=80&w=1000&auto=format&fit=crop');
    }
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _heroImage(),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.4),
            BlendMode.darken,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empower Communities\nAcross Tanzania',
              style: GoogleFonts.nunito(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'JamiiFund connects donors with impactful projects that transform lives.',
              style: GoogleFonts.nunito(
                fontSize: 16.0,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/discover');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Browse Projects',
                style: GoogleFonts.nunito(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tips for Fundraising Success',
            style: GoogleFonts.nunito(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: _isVideoInitialized
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: VisibilityDetector(
                    key: const Key('video-player'),
                    onVisibilityChanged: (visibilityInfo) {
                      if (visibilityInfo.visibleFraction >= 0.8) {
                        if (_videoController.value.isInitialized) {
                          _videoController.play();
                        }
                      } else {
                        if (_videoController.value.isInitialized) {
                          _videoController.pause();
                        }
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        ),
                        if (!_videoController.value.isPlaying)
                          InkWell(
                            onTap: () {
                              if (_videoController.value.isInitialized) {
                                setState(() {
                                  _videoController.play();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Color(0xFF8A2BE2),
                                size: 40,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.videocam_off_outlined,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Video not available',
                        style: GoogleFonts.nunito(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _featuredCampaigns.length,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final campaign = _featuredCampaigns[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampaignDetailsPage(campaign: campaign),
              ),
            ).then((_) => _fetchCampaigns());
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
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              campaign.category,
                              style: GoogleFonts.nunito(
                                color: const Color(0xFF8A2BE2),
                                fontWeight: FontWeight.w500,
                                fontSize: 12.0,
                              ),
                            ),
                            backgroundColor: const Color(0xFF8A2BE2).withOpacity(0.1),
                            padding: EdgeInsets.zero,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CampaignDetailsPage(campaign: campaign),
                                ),
                              ).then((_) => _fetchCampaigns());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A2BE2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Donate Now',
                              style: GoogleFonts.nunito(
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
    );
  }

  Widget _buildHowToStartSection() {
    return Container(
      color: const Color(0xFF8A2BE2).withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to Get Started',
            style: GoogleFonts.nunito(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A2BE2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create an account',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up using your email address to get started with JamiiFund.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A2BE2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find a project',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse through our campaigns and find a cause that resonates with you.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF8A2BE2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make a difference',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Donate to support the project and track its progress as it makes a positive impact.',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8A2BE2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Text(
                'Start Your Own Campaign',
                style: GoogleFonts.nunito(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
