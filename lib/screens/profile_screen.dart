import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '+255 123 456 789');
  
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Fetch user profile from Supabase
      // This is placeholder implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would fetch from Supabase and update controllers:
      // final user = await UserService.getUserProfile();
      // _nameController.text = user.fullName;
      // _emailController.text = user.email;
      // _phoneController.text = user.phone;
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name and email cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Update user profile in Supabase
      // This is placeholder implementation
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would update in Supabase:
      // await UserService.updateUserProfile(
      //   name: _nameController.text,
      //   email: _emailController.text,
      //   phone: _phoneController.text,
      // );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF8A2BE2),
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Navigate to authentication screen
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF8A2BE2)),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserProfile(); // Reload original data
                });
              },
            ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24.0),
                  _buildProfileForm(),
                  const SizedBox(height: 32.0),
                  if (_isEditing) _buildUpdateButton(),
                  const SizedBox(height: 16.0),
                  _buildSignOutButton(),
                  const SizedBox(height: 16.0),
                  _buildDeleteAccountButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/300'),
              fit: BoxFit.cover,
            ),
          ),
        ).animate().fadeIn(duration: 500.ms).scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOut,
            ),
        const SizedBox(height: 16.0),
        if (_isEditing)
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement image picker
            },
            icon: const Icon(Icons.photo_camera, size: 16),
            label: Text(
              'Change Photo',
              style: GoogleFonts.nunito(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          enabled: _isEditing,
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16.0),
        _buildTextField(
          controller: _emailController,
          label: 'Email Address',
          enabled: _isEditing,
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16.0),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          enabled: _isEditing,
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24.0),
        if (!_isEditing) _buildStatistics(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: const Color(0xFF8A2BE2)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      keyboardType: keyboardType,
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Statistics',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatisticItem('5', 'Donations', Icons.volunteer_activism_outlined),
              _buildStatisticItem('3', 'Campaigns', Icons.campaign_outlined),
              _buildStatisticItem('\$750', 'Total', Icons.attach_money_outlined),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, duration: 300.ms);
  }

  Widget _buildStatisticItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF8A2BE2).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF8A2BE2)),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _updateProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8A2BE2),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.0,
              ),
            )
          : Text(
              'Update Profile',
              style: GoogleFonts.nunito(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSignOutButton() {
    return TextButton.icon(
      onPressed: _signOut,
      icon: const Icon(Icons.logout, color: Colors.grey),
      label: Text(
        'Sign Out',
        style: GoogleFonts.nunito(
          color: Colors.grey[700],
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return TextButton.icon(
      onPressed: () {
        // Show confirmation dialog before deletion
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Account',
              style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: GoogleFonts.nunito(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunito(color: Colors.grey[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement account deletion
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.nunito(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: Text(
        'Delete Account',
        style: GoogleFonts.nunito(
          color: Colors.red,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
