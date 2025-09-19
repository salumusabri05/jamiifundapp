import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/screens/verification_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class CreateCampaignScreen extends StatefulWidget {
  const CreateCampaignScreen({super.key});

  @override
  State<CreateCampaignScreen> createState() => _CreateCampaignScreenState();
}

class _CreateCampaignScreenState extends State<CreateCampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalAmountController = TextEditingController();
  final _videoUrlController = TextEditingController();
  
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _selectedCategory = 'Education';
  bool _isVerified = false;
  bool _isLoading = true;
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  final List<String> _categories = [
    'Education',
    'Health',
    'Water',
    'Food',
    'Housing',
    'Agriculture',
    'Technology',
    'Other'
  ];
  
  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }
  
  // Check if user is verified to create campaigns
  Future<void> _checkVerificationStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final user = UserService.getCurrentUser();
      if (user != null) {
        final isVerified = await VerificationService.isUserVerified(user.id);
        setState(() => _isVerified = isVerified);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking verification status: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Navigate to verification screen
  void _navigateToVerificationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VerificationScreen(),
      ),
    ).then((_) {
      // Refresh verification status when returning from verification screen
      _checkVerificationStatus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalAmountController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }
  
  // Widget to display when verification is required
  Widget _buildVerificationRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 80,
              color: Colors.amber[700],
            ).animate().fade(duration: const Duration(milliseconds: 600)),
            const SizedBox(height: 24),
            Text(
              'Verification Required',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fade(delay: const Duration(milliseconds: 200)),
            const SizedBox(height: 16),
            Text(
              'To create a campaign on JamiiFund, your account must be verified first. Verification helps ensure trust and security on our platform.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ).animate().fade(delay: const Duration(milliseconds: 400)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _navigateToVerificationScreen,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Complete Verification',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fade(delay: const Duration(milliseconds: 600)).moveY(begin: 20, end: 0),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Go Back',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ).animate().fade(delay: const Duration(milliseconds: 800)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Create Campaign',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 3), // Updated to 3 since we added community tab
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_isVerified
              ? _buildVerificationRequired()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildImageSelector(),
                        const SizedBox(height: 24.0),
              _buildTitleField(),
              const SizedBox(height: 16.0),
              _buildCategoryDropdown(),
              const SizedBox(height: 16.0),
              _buildGoalAmountField(),
              const SizedBox(height: 16.0),
              _buildEndDatePicker(),
              const SizedBox(height: 16.0),
              _buildVideoUrlField(),
              const SizedBox(height: 16.0),
              _buildDescriptionField(),
              const SizedBox(height: 32.0),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: ${e.toString()}')),
      );
    }
  }
  
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImageSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Campaign Images',
          style: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8.0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              if (_selectedImages.isEmpty)
                InkWell(
                  onTap: _pickImages,
                  child: Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'Add Campaign Images',
                          style: GoogleFonts.nunito(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Select multiple images',
                          style: GoogleFonts.nunito(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected Images (${_selectedImages.length})',
                            style: GoogleFonts.nunito(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add More'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF8A2BE2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: kIsWeb
                                      ? Image.network(
                                          _selectedImages[index].path,
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        )
                                      : Image.file(
                                          File(_selectedImages[index].path),
                                          width: 120,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Campaign Title',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a campaign title';
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedCategory = newValue;
          });
        }
      },
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildGoalAmountField() {
    return TextFormField(
      controller: _goalAmountController,
      decoration: InputDecoration(
        labelText: 'Goal Amount (USD)',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.attach_money),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a goal amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        if (double.parse(value) <= 0) {
          return 'Goal amount must be greater than zero';
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildEndDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _endDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && picked != _endDate) {
          setState(() {
            _endDate = picked;
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: 'End Date',
            labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          controller: TextEditingController(
            text: "${_endDate.day}/${_endDate.month}/${_endDate.year}",
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }
  
  Widget _buildVideoUrlField() {
    return TextFormField(
      controller: _videoUrlController,
      decoration: InputDecoration(
        labelText: 'Video URL (Optional)',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        hintText: 'Enter YouTube or other video link',
        hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.video_library_outlined),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          // Simple URL validation
          final urlPattern = RegExp(
            r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.?be|vimeo\.com)\/.*',
            caseSensitive: false,
          );
          if (!urlPattern.hasMatch(value)) {
            return 'Please enter a valid video URL';
          }
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 275.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Campaign Description',
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        hintText: 'Describe your campaign and how the funds will be used...',
        hintStyle: GoogleFonts.nunito(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      maxLines: 5,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a campaign description';
        }
        if (value.trim().length < 50) {
          return 'Description should be at least 50 characters';
        }
        return null;
      },
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Future<void> _createCampaign() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image for your campaign'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Creating campaign...'),
        backgroundColor: Color(0xFF8A2BE2),
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      setState(() => _isLoading = true);
      
      final user = UserService.getCurrentUser();
      if (user == null) {
        throw Exception('User not logged in');
      }
      
      // Get user profile to access the name
      final userProfile = await UserService.getUserProfileById(user.id);
      if (userProfile == null) {
        throw Exception('User profile not found');
      }
      
      // 1. Upload images to storage and get URLs
      String? imageUrl;
      if (_selectedImages.isNotEmpty) {
        final file = _selectedImages.first;
        final fileBytes = await file.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
        final filePath = 'campaign-images/${user.id}/$fileName';
        
        // Upload to Supabase storage
        await UserService.supabase
            .storage
            .from('campaign-images')
            .uploadBinary(filePath, fileBytes);
            
        // Get public URL
        imageUrl = UserService.supabase
            .storage
            .from('campaign-images')
            .getPublicUrl(filePath);
      }
      
      // 2. Create campaign in Supabase
      final campaign = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _selectedCategory,
        'goal_amount': int.parse(_goalAmountController.text),
        'current_amount': 0,
        'end_date': _endDate.toIso8601String(),
        'image_url': imageUrl,
        'created_by': user.id,
        'created_by_name': userProfile.fullName,
        'is_featured': false,
        'donor_count': 0,
        'video_url': _videoUrlController.text.isNotEmpty ? _videoUrlController.text : null,
      };
      
      // Insert into campaigns table
      final response = await UserService.supabase
          .from('campaigns')
          .insert(campaign)
          .select();
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Campaign created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to discover screen
        Navigator.pushReplacementNamed(context, '/discover');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating campaign: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _createCampaign,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A2BE2),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: Text(
        'Create Campaign',
        style: GoogleFonts.nunito(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 350.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), duration: 300.ms);
  }
}
