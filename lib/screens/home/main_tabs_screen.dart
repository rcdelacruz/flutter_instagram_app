import 'package:flutter/material.dart';
import 'feed_screen.dart';
import 'search_screen.dart';
import 'camera_screen.dart';
import 'activity_screen.dart';
import 'profile_screen.dart';

// Exact replica of React Native TabLayout (app/(tabs)/_layout.tsx)
class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({super.key});

  @override
  State<MainTabsScreen> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FeedScreen(),      // index: Home feed
    const SearchScreen(),    // search: Search and discover  
    const CameraScreen(),    // camera: Create new post
    const ActivityScreen(),  // activity: Notifications and activity
    const ProfileScreen(),   // profile: User profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFFFFF),
          border: Border(
            top: BorderSide(color: Color(0xFFE1E1E1), width: 1),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 90,
            padding: const EdgeInsets.only(bottom: 25, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTabItem(
                  icon: Icons.home,
                  index: 0,
                  label: 'Home',
                ),
                _buildTabItem(
                  icon: Icons.search,
                  index: 1,
                  label: 'Search',
                ),
                _buildTabItem(
                  icon: Icons.add_box_outlined,
                  index: 2,
                  label: 'Create',
                ),
                _buildTabItem(
                  icon: Icons.favorite_border,
                  index: 3,
                  label: 'Activity',
                ),
                _buildTabItem(
                  icon: Icons.person_outline,
                  index: 4,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required int index,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? const Color(0xFF000000) : const Color(0xFF8E8E8E),
        ),
      ),
    );
  }
}
