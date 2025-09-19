import 'package:flutter/material.dart';
import 'package:jamiifund/screens/create_campaign_screen.dart';
import 'package:jamiifund/screens/discover_screen.dart';
import 'package:jamiifund/screens/donations_screen.dart';
import 'package:jamiifund/screens/home_screen_new.dart';
import 'package:jamiifund/screens/profile_screen.dart';
import 'package:jamiifund/screens/users_screen.dart';

class AppBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const AppBottomNavBar({
    super.key,
    this.currentIndex = 0,
  });

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  void _onItemTapped(int index) {
    if (index == widget.currentIndex) return;

    // Navigate to the appropriate screen
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DiscoverScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UsersScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateCampaignScreen()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DonationsScreen()),
        );
        break;
      case 5:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xFF8A2BE2),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Discover',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Create',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_border),
          label: 'Donations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}
