import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jamiifund/models/campaign.dart';
import 'package:jamiifund/models/user_profile.dart';
import 'package:jamiifund/screens/about_us_page.dart';
import 'package:jamiifund/screens/auth_page.dart';
import 'package:jamiifund/screens/blog_page.dart';
import 'package:jamiifund/screens/campaign_details_page.dart';
import 'package:jamiifund/screens/chat_detail_screen.dart';
import 'package:jamiifund/screens/community_guidelines_page.dart';
import 'package:jamiifund/screens/create_campaign_screen.dart';
import 'package:jamiifund/screens/discover_screen.dart';
import 'package:jamiifund/screens/donations_screen.dart';
import 'package:jamiifund/screens/fundraising_tips_page.dart';
import 'package:jamiifund/screens/home_screen_new.dart' as home;
import 'package:jamiifund/screens/how_it_works_page.dart';
import 'package:jamiifund/screens/onboarding_screen.dart';
import 'package:jamiifund/screens/user_detail_screen.dart';
import 'package:jamiifund/screens/users_screen.dart';
import 'package:jamiifund/screens/profile_screen.dart';
import 'package:jamiifund/screens/splash_screen.dart';
import 'package:jamiifund/screens/success_stories_page.dart';
import 'package:jamiifund/screens/support_page.dart';
import 'package:jamiifund/screens/terms_of_service_page.dart';
import 'package:jamiifund/theme/app_theme.dart';
import 'package:jamiifund/theme/colors.dart';
import 'package:jamiifund/services/supabase_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.primary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Initialize Supabase with error handling
  try {
    await SupabaseService.initialize();
    print('Supabase initialized successfully');
  } catch (e) {
    print('Failed to initialize Supabase: $e');
    // Continue with app launch anyway, services will handle reconnection attempts
  }
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JamiiFund',
      theme: AppTheme.getTheme(),
      home: const SplashScreen(
        nextScreen: OnboardingScreen(),
      ),
      routes: {
        '/home': (context) => const home.HomeScreen(),
        '/auth': (context) => const AuthPage(),
        '/discover': (context) => const DiscoverScreen(),
        '/create': (context) => const CreateCampaignScreen(),
        '/donations': (context) => const DonationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/users': (context) => const UsersScreen(),
        // Drawer pages
        '/about_us': (context) => const AboutUsPage(),
        '/how_it_works': (context) => const HowItWorksPage(),
        '/blog': (context) => const BlogPage(),
        '/success_stories': (context) => const SuccessStoriesPage(),
        '/fundraising_tips': (context) => const FundraisingTipsPage(),
        '/terms_of_service': (context) => const TermsOfServicePage(),
        '/community_guidelines': (context) => const CommunityGuidelinesPage(),
        '/support': (context) => const SupportPage(),
        // We won't add CampaignDetailsPage in routes since it requires a campaign parameter
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/campaign_details') {
          final Campaign campaign = settings.arguments as Campaign;
          return MaterialPageRoute(
            builder: (context) => CampaignDetailsPage(
              campaign: campaign,
            ),
          );
        } else if (settings.name == '/user_detail') {
          final UserProfile user = settings.arguments as UserProfile;
          return MaterialPageRoute(
            builder: (context) => UserDetailScreen(
              user: user,
            ),
          );
        } else if (settings.name == '/chat_detail') {
          final UserProfile recipient = settings.arguments as UserProfile;
          return MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              recipient: recipient,
            ),
          );
        }
        return null;
      },
    );
  }
}
