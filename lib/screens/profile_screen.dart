import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/services/verification_service.dart';
import 'package:jamiifund/services/supabase_client.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';
import 'package:jamiifund/widgets/verification_status_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizationNameController = TextEditingController();
  final _organizationRegNumberController = TextEditingController();
  final _organizationTypeController = TextEditingController();
  final _organizationDescriptionController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isOrganization = false;
  bool _isVerified = false;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProfile = await UserService.getCurrentUserProfile();
      
      // Check verification status directly from the verification service
      final user = UserService.getCurrentUser();
      bool verificationStatus = false;
      if (user != null) {
        try {
          // Import the verification service at the top of the file if not already imported
          verificationStatus = await VerificationService.isUserVerified(user.id);
        } catch (e) {
          // Fallback to profile data if service check fails
          verificationStatus = userProfile?.isVerified ?? false;
        }
      }
      
      if (userProfile != null) {
        setState(() {
          _nameController.text = userProfile.fullName ?? '';
          _emailController.text = userProfile.email ?? '';
          _usernameController.text = userProfile.username ?? '';
          _phoneController.text = userProfile.phone ?? '';
          _websiteController.text = userProfile.website ?? '';
          _addressController.text = userProfile.address ?? '';
          _cityController.text = userProfile.city ?? '';
          _regionController.text = userProfile.region ?? '';
          _postalCodeController.text = userProfile.postalCode ?? '';
          _bioController.text = userProfile.bio ?? '';
          _locationController.text = userProfile.location ?? '';
          _organizationNameController.text = userProfile.organizationName ?? '';
          _organizationRegNumberController.text = userProfile.organizationRegNumber ?? '';
          _organizationTypeController.text = userProfile.organizationType ?? '';
          _organizationDescriptionController.text = userProfile.organizationDescription ?? '';
          _isOrganization = userProfile.isOrganization ?? false;
          _isVerified = verificationStatus; // Use the verification status we checked
          _avatarUrl = userProfile.avatarUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Update user profile
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      await UserService.updateUserProfile(
        userId: userId,
        fullName: _nameController.text,
        username: _usernameController.text,
        phone: _phoneController.text,
        website: _websiteController.text,
        address: _addressController.text,
        city: _cityController.text,
        region: _regionController.text,
        postalCode: _postalCodeController.text,
        bio: _bioController.text,
        location: _locationController.text,
        isOrganization: _isOrganization,
        organizationName: _isOrganization ? _organizationNameController.text : null,
        organizationRegNumber: _isOrganization ? _organizationRegNumberController.text : null,
        organizationType: _isOrganization ? _organizationTypeController.text : null,
        organizationDescription: _isOrganization ? _organizationDescriptionController.text : null,
      );
      
      setState(() => _isEditMode = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Sign out
  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    
    try {
      await UserService.signOut();
      // Navigate to auth page after signing out
      if (!mounted) return;
      
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove default back button
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (!_isLoading && !_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => _isEditMode = true);
              },
            ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile avatar and name
                  Center(
                    child: Column(
                      children: [
                        _avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(_avatarUrl!),
                              )
                            : const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, size: 50, color: Colors.white),
                              ),
                        const SizedBox(height: 16),
                        Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text
                              : 'User',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _usernameController.text.isNotEmpty
                              ? '@${_usernameController.text}'
                              : _emailController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (_isVerified)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                'Verified Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Verification status card - only shown if user is not verified
                  if (!_isVerified) ... [
                    const VerificationStatusWidget(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Profile form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Basic information section
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixText: '@',
                          ),
                          enabled: _isEditMode,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: false, // Email can't be changed
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _bioController,
                          decoration: InputDecoration(
                            labelText: 'Bio',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                          maxLines: 3,
                        ),
                        
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _websiteController,
                          decoration: InputDecoration(
                            labelText: 'Website',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        
                        const SizedBox(height: 24),
                        Text(
                          'Address',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Street Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _regionController,
                          decoration: InputDecoration(
                            labelText: 'Region/State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _postalCodeController,
                          decoration: InputDecoration(
                            labelText: 'Postal Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: _isEditMode,
                        ),
                        
                        const SizedBox(height: 24),
                        // Organization section
                        Row(
                          children: [
                            Text(
                              'Organization',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (_isEditMode)
                              Switch(
                                value: _isOrganization,
                                onChanged: (value) {
                                  setState(() {
                                    _isOrganization = value;
                                  });
                                },
                              ),
                          ],
                        ),
                        
                        if (_isOrganization || (!_isEditMode && _organizationNameController.text.isNotEmpty)) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _organizationNameController,
                            decoration: InputDecoration(
                              labelText: 'Organization Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            enabled: _isEditMode,
                            validator: (value) {
                              if (_isOrganization && (value == null || value.isEmpty)) {
                                return 'Please enter organization name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _organizationRegNumberController,
                            decoration: InputDecoration(
                              labelText: 'Registration Number',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _organizationTypeController,
                            decoration: InputDecoration(
                              labelText: 'Organization Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            enabled: _isEditMode,
                          ),
                          const SizedBox(height: 16),
                          
                          TextFormField(
                            controller: _organizationDescriptionController,
                            decoration: InputDecoration(
                              labelText: 'Organization Description',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            enabled: _isEditMode,
                            maxLines: 3,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action buttons
                  if (_isEditMode)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Save Changes',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _isEditMode = false);
                              _loadUserData(); // Reload user data to reset form
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Sign out button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _signOut,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.red,
                      ),
                      child: Text(
                        'Sign Out',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _organizationNameController.dispose();
    _organizationRegNumberController.dispose();
    _organizationTypeController.dispose();
    _organizationDescriptionController.dispose();
    super.dispose();
  }
}
