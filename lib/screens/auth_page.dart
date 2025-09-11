import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jamiifund/services/user_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  bool _isLogin = true;
  bool _isPasswordVisible = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
    
    if (_isLogin) {
      _tabController.animateTo(0);
    } else {
      _tabController.animateTo(1);
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use Supabase for authentication
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        if (response.session != null) {
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          _showErrorSnackBar('Invalid email or password');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to sign in: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showErrorSnackBar('Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use Supabase for authentication
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        data: {'full_name': _nameController.text.trim()},
      );

      if (mounted) {
        if (response.user != null) {
          // Create a profile record
          await Supabase.instance.client.from('profiles').insert({
            'id': response.user!.id,
            'full_name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'created_at': DateTime.now().toIso8601String(),
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully'),
              backgroundColor: Color(0xFF8A2BE2),
            ),
          );
          
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          _showErrorSnackBar('Failed to create account');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to sign up: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipAuth() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Welcome Text
                Center(
                  child: Text(
                    'JamiiFund',
                    style: GoogleFonts.nunito(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A2BE2),
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 10),
                
                Center(
                  child: Text(
                    'Fundraising for a Better Tanzania',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 200.ms, duration: 600.ms)
                .slideY(begin: -0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 50),
                
                // Tab Bar for Login/Register
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xFF8A2BE2),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onTap: (index) {
                      setState(() {
                        _isLogin = index == 0;
                      });
                    },
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Register'),
                    ],
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 600.ms, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 30),
                
                // TabBarView for Login/Register Forms
                SizedBox(
                  height: _isLogin ? 250 : 300, // Adjust height based on which tab is selected
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Login Form
                      _buildLoginForm()
                      .animate()
                      .fadeIn(duration: 600.ms),
                      
                      // Register Form
                      _buildRegisterForm()
                      .animate()
                      .fadeIn(duration: 600.ms),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Button (Login or Register)
                ElevatedButton(
                  onPressed: _isLoading ? null : (_isLogin ? _signIn : _signUp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8A2BE2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    disabledBackgroundColor: const Color(0xFF8A2BE2).withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isLogin ? 'Login' : 'Register',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms, curve: Curves.easeOutQuad),
                
                const SizedBox(height: 20),
                
                // Skip Button
                TextButton(
                  onPressed: _skipAuth,
                  child: Text(
                    'Skip - Continue as Guest',
                    style: GoogleFonts.nunito(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms),
                
                const SizedBox(height: 40),
                
                // Optional social login buttons would go here
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A2BE2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Password field
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A2BE2)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Handle forgot password
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.nunito(
                color: const Color(0xFF8A2BE2),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        // Name field
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Full Name',
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF8A2BE2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Email',
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A2BE2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Password field
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A2BE2)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
      ],
    );
  }
}
