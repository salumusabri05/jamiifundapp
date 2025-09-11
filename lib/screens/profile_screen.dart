import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/services/user_service.dart';
import 'package:jamiifund/widgets/verification_status_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    try {
      final userProfile = await UserService.getUserProfile();
      setState(() {
        _nameController.text = userProfile.fullName ?? '';
        _emailController.text = userProfile.email ?? '';
      });
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
      await UserService.updateUserProfile(
        fullName: _nameController.text,
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
      // Navigation will be handled by auth state listener
    } catch (e) {
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
                        const CircleAvatar(
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
                          _emailController.text,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Verification status card
                  const VerificationStatusWidget(),

                  const SizedBox(height: 24),
                  
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
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
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
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          enabled: false, // Email can't be changed
                        ),
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
    super.dispose();
  }
}
