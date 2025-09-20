import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jamiifund/widgets/app_drawer.dart';
import 'package:jamiifund/widgets/app_bottom_nav_bar.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _selectedIssue = 'General Inquiry';
  bool _isSubmitting = false;
  bool _showSuccess = false;
  
  final List<String> _issueTypes = [
    'General Inquiry',
    'Account Issues',
    'Payment Problems',
    'Campaign Setup Help',
    'Report Abuse',
    'Technical Support',
    'Feature Request',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
          _showSuccess = true;
        });
        
        // Reset form after showing success message
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showSuccess = false;
              _nameController.clear();
              _emailController.clear();
              _subjectController.clear();
              _messageController.clear();
              _selectedIssue = 'General Inquiry';
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Support',
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
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8A2BE2),
                    const Color(0xFF9370DB),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We\'re Here to Help',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our support team is available to assist you with any questions or issues you may have.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            // Quick help section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Help',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickHelpCard(
                    'FAQs',
                    'Find answers to commonly asked questions',
                    Icons.question_answer_outlined,
                    () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const FAQsPage(),
                        ),
                      );
                    },
                  ),
                  _buildQuickHelpCard(
                    'User Guide',
                    'Learn how to use JamiiFund effectively',
                    Icons.menu_book_outlined,
                    () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const UserGuidePage(),
                        ),
                      );
                    },
                  ),
                  _buildQuickHelpCard(
                    'Video Tutorials',
                    'Watch step-by-step tutorial videos',
                    Icons.video_library_outlined,
                    () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const VideoTutorialsPage(),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Contact form
                  Text(
                    'Contact Form',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please fill out the form below and our team will get back to you within 24 hours.',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Success message
                  if (_showSuccess)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your message has been sent successfully. We\'ll get back to you soon!',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  if (_showSuccess) const SizedBox(height: 24),
                  
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Full Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('Email Address'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Issue type dropdown
                        DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Issue Type'),
                          value: _selectedIssue,
                          items: _issueTypes.map((String issue) {
                            return DropdownMenuItem<String>(
                              value: issue,
                              child: Text(issue),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedIssue = newValue;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Subject field
                        TextFormField(
                          controller: _subjectController,
                          decoration: _inputDecoration('Subject'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a subject';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Message field
                        TextFormField(
                          controller: _messageController,
                          decoration: _inputDecoration('Message').copyWith(
                            alignLabelWithHint: true,
                          ),
                          maxLines: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your message';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A2BE2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor: const Color(0xFF8A2BE2).withOpacity(0.6),
                            ),
                            child: _isSubmitting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  )
                                : Text(
                                    'Submit',
                                    style: GoogleFonts.nunito(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Alternative contact methods
                  Text(
                    'Other Ways to Reach Us',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactMethod(
                    'Email',
                    'support@jamiifund.co.tz',
                    Icons.email_outlined,
                  ),
                  _buildContactMethod(
                    'Phone',
                    '+255 123 456 789',
                    Icons.phone_outlined,
                  ),
                  _buildContactMethod(
                    'WhatsApp',
                    '+255 987 654 321',
                    Icons.chat_bubble_outline,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelpCard(
      String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF8A2BE2),
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF8A2BE2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactMethod(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8A2BE2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF8A2BE2),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.nunito(
        color: Colors.grey[600],
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}

// FAQs Page
class FAQsPage extends StatelessWidget {
  const FAQsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of FAQs with questions and answers
    final faqs = [
      {
        'question': 'What is JamiiFund?',
        'answer': 'JamiiFund is a community-driven crowdfunding platform designed specifically for Tanzanians to raise funds for various causes including education, healthcare, business ventures, and community projects.'
      },
      {
        'question': 'How do I create a campaign?',
        'answer': 'To create a campaign, log in to your account, click on the "Create" button in the bottom navigation bar, fill out the campaign details including title, description, goal amount, and upload relevant images, then submit for review.'
      },
      {
        'question': 'What fees does JamiiFund charge?',
        'answer': 'JamiiFund charges a 5% platform fee on successful campaigns to cover operational costs and payment processing. This fee is only applied when your campaign reaches its funding goal.'
      },
      {
        'question': 'How long can my campaign run?',
        'answer': 'Campaigns can run for up to 60 days. You can set your desired duration when creating your campaign, but we recommend 30-45 days for optimal results.'
      },
      {
        'question': 'What happens if I don\'t reach my funding goal?',
        'answer': 'JamiiFund operates on a flexible funding model, which means you keep all funds raised even if you don\'t reach your goal. However, we encourage setting realistic goals to build trust with donors.'
      },
      {
        'question': 'How do I withdraw my funds?',
        'answer': 'Once your campaign ends, you can withdraw funds through mobile money transfer services (M-Pesa, Tigo Pesa, or Airtel Money) or direct bank transfer. Withdrawals are processed within 3-5 business days.'
      },
      {
        'question': 'Can I edit my campaign after launching it?',
        'answer': 'Yes, you can edit certain aspects of your campaign after launching, including the description, updates, and adding new images. However, you cannot change the funding goal or campaign duration once published.'
      },
      {
        'question': 'Is my personal information secure?',
        'answer': 'Yes, JamiiFund takes data security seriously. We use industry-standard encryption and security practices to protect your personal and payment information. We never share your data with unauthorized third parties.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Frequently Asked Questions',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0FF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A2BE2),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to the most common questions about JamiiFund',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                ],
              ),
            ),
            
            // FAQ List
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Card(
                    elevation: 1,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        faq['question']!,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            faq['answer']!,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms * index).slideY(begin: 0.1, end: 0);
                },
              ),
            ),

            // Back to home button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Back to Support',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
          ],
        ),
      ),
    );
  }
}

// User Guide Page
class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final guideItems = [
      {
        'title': 'Getting Started',
        'icon': Icons.start,
        'steps': [
          'Create your JamiiFund account by signing up with your email or phone number',
          'Complete your profile with your personal information and profile picture',
          'Explore campaigns to get familiar with the platform',
          'Connect your preferred payment method for donating or receiving funds'
        ]
      },
      {
        'title': 'Creating a Campaign',
        'icon': Icons.create,
        'steps': [
          'Click on the "Create" button in the bottom navigation bar',
          'Fill out all required information including title, description, and funding goal',
          'Upload compelling images that represent your campaign',
          'Set a realistic timeline and funding goal',
          'Submit your campaign for review'
        ]
      },
      {
        'title': 'Promoting Your Campaign',
        'icon': Icons.campaign,
        'steps': [
          'Share your campaign on social media platforms',
          'Send personal messages to friends and family',
          'Update your campaign regularly with progress and new information',
          'Engage with donors by responding to comments and messages',
          'Consider organizing a local event to promote your campaign'
        ]
      },
      {
        'title': 'Managing Donations',
        'icon': Icons.monetization_on,
        'steps': [
          'Monitor incoming donations in real-time',
          'Send personalized thank you messages to donors',
          'Provide regular updates on how the funds are being used',
          'Maintain transparency about your progress towards the goal',
          'Withdraw funds when your campaign ends or reaches its goal'
        ]
      },
      {
        'title': 'Community Engagement',
        'icon': Icons.people,
        'steps': [
          'Follow other users to build your network',
          'Engage with campaigns by commenting and sharing',
          'Join discussions in the community forum',
          'Attend JamiiFund events to connect with other fundraisers',
          'Volunteer to help other campaigns succeed'
        ]
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Guide',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0FF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User Guide',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A2BE2),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(),
                  const SizedBox(height: 8),
                  Text(
                    'Learn how to use JamiiFund effectively',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                ],
              ),
            ),
            
            // Guide sections
            Padding(
              padding: const EdgeInsets.all(16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: guideItems.length,
                itemBuilder: (context, index) {
                  final item = guideItems[index];
                  final steps = item['steps'] as List<String>;
                  
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                color: const Color(0xFF8A2BE2),
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item['title'] as String,
                                style: GoogleFonts.nunito(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8A2BE2),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          ...List.generate(steps.length, (i) => 
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${i + 1}.',
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      steps[i],
                                      style: GoogleFonts.nunito(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms * index).slideY(begin: 0.1, end: 0);
                },
              ),
            ),

            // Back to home button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Back to Support',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
          ],
        ),
      ),
    );
  }
}

// Video Tutorials Page
class VideoTutorialsPage extends StatefulWidget {
  const VideoTutorialsPage({super.key});

  @override
  State<VideoTutorialsPage> createState() => _VideoTutorialsPageState();
}

class _VideoTutorialsPageState extends State<VideoTutorialsPage> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/fundraisingtips.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      })
      ..addListener(() {
        if (_controller.value.isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Video Tutorials',
          style: GoogleFonts.nunito(
            color: const Color(0xFF8A2BE2),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8A2BE2)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F0FF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Tutorials',
                    style: GoogleFonts.nunito(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8A2BE2),
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideX(),
                  const SizedBox(height: 8),
                  Text(
                    'Watch step-by-step tutorials to help you succeed on JamiiFund',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(),
                ],
              ),
            ),
            
            // Video Player
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Column(
                        children: [
                          // Video player
                          AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                VideoPlayer(_controller),
                                _buildVideoOverlay(),
                                _buildVideoControls(),
                              ],
                            ),
                          ),
                          
                          // Video info
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fundraising Tips for Success',
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Learn essential tips for running a successful fundraising campaign on JamiiFund.',
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
                    ),
                  ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                ],
              ),
            ),
            
            // More tutorials coming soon
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.video_library_outlined,
                        color: Color(0xFF8A2BE2),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'More Tutorials Coming Soon!',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re working on additional tutorials to help you make the most of JamiiFund. Check back soon!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms),
            ),

            // Back to home button
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A2BE2),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Back to Support',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.9, 0.9)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8A2BE2),
        ),
      );
    }
    
    return AnimatedOpacity(
      opacity: _isPlaying ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Semi-transparent background
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
          // Play button
          IconButton(
            onPressed: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 64,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedOpacity(
        opacity: _isPlaying ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black.withOpacity(0.5),
          child: Row(
            children: [
              // Play/pause button
              IconButton(
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              
              // Current position
              Text(
                _controller.value.isInitialized
                    ? _formatDuration(_controller.value.position)
                    : '00:00',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              
              // Progress bar
              Expanded(
                child: Slider(
                  value: _controller.value.isInitialized
                      ? _controller.value.position.inMilliseconds.toDouble()
                      : 0.0,
                  min: 0.0,
                  max: _controller.value.isInitialized
                      ? _controller.value.duration.inMilliseconds.toDouble()
                      : 100.0,
                  activeColor: const Color(0xFF8A2BE2),
                  inactiveColor: Colors.white.withOpacity(0.3),
                  onChanged: (value) {
                    setState(() {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                    });
                  },
                ),
              ),
              
              // Total duration
              Text(
                _controller.value.isInitialized
                    ? _formatDuration(_controller.value.duration)
                    : '00:00',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

