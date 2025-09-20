import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

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
      // Use Supabase auth directly
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (mounted) {
        if (response.session != null) {
          // Show success message
          _showSuccessSnackBar('Sign in successful');
          
          // Navigate to home
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          _showErrorSnackBar('Invalid email or password');
        }
      }
    } catch (e) {
      if (mounted) {
        // Handle common errors
        String errorMessage = 'Failed to sign in. Please try again.';
        
        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (e.toString().contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (e.toString().contains('Email not confirmed')) {
          errorMessage = 'Please confirm your email before signing in.';
        }
        
        _showErrorSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final resetEmailController = TextEditingController();
    bool isLoading = false;
    
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Reset Password',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter your email address and we\'ll send you a password reset link.',
                style: GoogleFonts.nunito(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.nunito(),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : () async {
                if (resetEmailController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please enter your email address'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                setState(() => isLoading = true);
                
                try {
                  await Supabase.instance.client.auth.resetPasswordForEmail(
                    resetEmailController.text.trim(),
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    _showSuccessSnackBar('Password reset link sent! Please check your email.');
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    _showErrorSnackBar('Failed to send reset link. Please try again.');
                  }
                }
              },
              child: Text(
                'Send Reset Link',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF8A2BE2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final fullName = _nameController.text.trim();
      
      // Use Supabase auth directly for signup - don't check profiles table first
      print('Attempting to sign up with email: $email');
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      if (mounted) {
        print('Sign-up response received: User: ${response.user != null ? 'present' : 'null'}, Session: ${response.session != null ? 'present' : 'null'}');
        
        if (response.user != null) {
          print('User registered successfully: ${response.user!.id}');
          
          // Try to create a profile for the user, with some delay to ensure auth is complete
          try {
            print('Waiting briefly before creating profile...');
            await Future.delayed(const Duration(milliseconds: 500));
            
            print('Attempting to create profile for user: ${response.user!.id}');
            final profileData = {
              'id': response.user!.id,
              'email': email,
              'full_name': fullName,
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            };
            print('Profile data: $profileData');
            
            final profileResult = await Supabase.instance.client
                .from('profiles')
                .insert(profileData)
                .select();
                
            print('Profile creation result: $profileResult');
          } catch (profileError) {
            // Log error but continue - we'll consider auth success even if profile creation fails
            print('Failed to create profile: $profileError');
          }
          
          // Check if we already have a session from signup
          if (response.session == null) {
            print('No session from signup, attempting auto sign-in');
            // Auto sign in the user since we have their credentials
            try {
              final signInResponse = await Supabase.instance.client.auth.signInWithPassword(
                email: email,
                password: password,
              );
              
              if (signInResponse.session != null) {
                print('User signed in successfully after registration');
              } else {
                print('Sign-in after registration returned null session');
              }
            } catch (signInError) {
              print('Error auto-signing in after registration: $signInError');
              // Continue anyway - registration was successful
            }
          } else {
            print('Already have session from signup, no need to sign in again');
          }
          
          // Check if we have a valid session now
          final currentSession = Supabase.instance.client.auth.currentSession;
          final currentUser = Supabase.instance.client.auth.currentUser;
          
          print('Current session after signup/signin: ${currentSession != null ? 'present' : 'null'}');
          print('Current user after signup/signin: ${currentUser != null ? 'present' : 'null'}');
          
          // Show success message
          _showSuccessSnackBar('Registration successful!');
          
          // Always redirect to home after successful registration
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Handle case where user is null but we might have a session
          if (response.session != null) {
            print('User is null but session exists, redirecting to home');
            _showSuccessSnackBar('Registration successful!');
            Navigator.of(context).pushReplacementNamed('/home');
          } else {
            print('Both user and session are null after signup');
            // Most likely case is that email confirmation is required
            _showSuccessSnackBar('Account created! Please check your email to confirm registration.');
            
            // Add a delay before redirecting to home screen anyway
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/home');
              }
            });
          }
        }
      }
    } catch (e) {
      print('Registration error: $e');
      if (mounted) {
        String errorMessage = 'Failed to sign up.';
        String errorString = e.toString().toLowerCase();
        
        if (errorString.contains('password')) {
          errorMessage = 'Password must be at least 6 characters.';
        } else if (errorString.contains('email')) {
          errorMessage = 'Please enter a valid email address.';
        } else if (errorString.contains('network')) {
          errorMessage = 'Network error. Please check your internet connection.';
        } else if (errorString.contains('already registered')) {
          errorMessage = 'This email is already registered. Please sign in instead.';
        } else if (errorString.contains('unique constraint')) {
          errorMessage = 'This email is already registered. Please sign in instead.';
        }
        
        print('Showing error to user: $errorMessage');
        _showErrorSnackBar(errorMessage);
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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
  
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF8A2BE2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
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
                
                const SizedBox(height: 16),
                
                // Forgot Password Button (Only shown in login mode)
                if (_isLogin)
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8A2BE2),
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 700.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 600.ms),
                
                const SizedBox(height: 16),
                
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
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A2BE2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF8A2BE2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Email field
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email address',
            prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A2BE2)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Password field
        TextField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Create a secure password',
            helperText: 'Password must be at least 6 characters',
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A2BE2)),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }
}
