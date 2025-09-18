import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/feed_models.dart';
import '../../widgets/linear_gradient.dart';
import '../../services/auth_service.dart';

// Exact replica of React Native ProfileScreen (app/(tabs)/profile.tsx)
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final bool _isLoading = false;
  final bool _isOwnProfile = true;
  bool _isFollowing = false;

  late ProfileUser _user;
  List<GridPost> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    // Mock profile data - exact replica of React Native
    _user = const ProfileUser(
      username: 'john_doe',
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      displayName: 'John Doe',
      bio: 'Flutter Developer 📱\nBuilding amazing apps ✨\nLove coffee and code ☕️💻',
      website: 'https://johndoe.dev',
      postsCount: 42,
      followersCount: 1234,
      followingCount: 567,
      isPrivate: false,
    );

    _posts = [
      const GridPost(
        id: '1',
        image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      ),
      const GridPost(
        id: '2',
        image: 'https://images.unsplash.com/photo-1551963831-b3b1ca40c98e?w=400&h=400&fit=crop',
      ),
      const GridPost(
        id: '3',
        image: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=400&fit=crop',
      ),
      const GridPost(
        id: '4',
        image: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&h=400&fit=crop',
      ),
      const GridPost(
        id: '5',
        image: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
      ),
      const GridPost(
        id: '6',
        image: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
      ),
    ];
    setState(() {});
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                final authService = ref.read(authServiceProvider);
                await authService.signOut();
                // Navigation will be handled automatically by the auth state listener in main.dart
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Failed to sign out: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageSize = (screenWidth - 6) / 3;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF007AFF)),
              SizedBox(height: 16),
              Text(
                'Loading profile...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8E8E8E),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header - exact replica of React Native
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE1E1E1), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _user.username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  if (_isOwnProfile)
                    GestureDetector(
                      onTap: _handleLogout,
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.logout,
                          color: Color(0xFF000000),
                          size: 24,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.settings,
                      color: Color(0xFF000000),
                      size: 24,
                    ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Profile Section - exact replica of React Native
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Profile Header
                          Row(
                            children: [
                              // Avatar with gradient border
                              Container(
                                margin: const EdgeInsets.only(right: 24),
                                child: LinearGradientWidget(
                                  colors: const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  borderRadius: BorderRadius.circular(45),
                                  child: Container(
                                    width: 90,
                                    height: 90,
                                    padding: const EdgeInsets.all(3),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(42),
                                        border: Border.all(color: Colors.white, width: 3),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(39),
                                        child: CachedNetworkImage(
                                          imageUrl: _user.avatar,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            color: Colors.grey[300],
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.person, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Stats
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStat(_user.postsCount.toString(), 'Posts'),
                                    _buildStat(_user.followersCount.toString(), 'Followers'),
                                    _buildStat(_user.followingCount.toString(), 'Following'),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Profile Info
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _user.bio,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF000000),
                                    height: 1.3,
                                  ),
                                ),
                                if (_user.website != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    _user.website!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF0095F6),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              if (_isOwnProfile) ...[
                                Expanded(
                                  child: _buildButton(
                                    'Edit Profile',
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    textColor: const Color(0xFF000000),
                                    onTap: () {
                                      // TODO: Navigate to edit profile
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildButton(
                                  'Share Profile',
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  textColor: const Color(0xFF000000),
                                  onTap: () {
                                    // TODO: Implement share profile
                                  },
                                ),
                              ] else ...[
                                Expanded(
                                  child: LinearGradientWidget(
                                    colors: _isFollowing
                                        ? [const Color(0xFFF5F5F5), const Color(0xFFF5F5F5)]
                                        : [const Color(0xFF833AB4), const Color(0xFFFD1D1D), const Color(0xFFFCB045)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    borderRadius: BorderRadius.circular(6),
                                    child: _buildButton(
                                      _isFollowing ? 'Following' : 'Follow',
                                      backgroundColor: Colors.transparent,
                                      textColor: _isFollowing ? const Color(0xFF000000) : Colors.white,
                                      onTap: _toggleFollow,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildButton(
                                  'Message',
                                  backgroundColor: const Color(0xFFF5F5F5),
                                  textColor: const Color(0xFF000000),
                                  onTap: () {
                                    // TODO: Navigate to messages
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tab Bar
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Color(0xFFE1E1E1), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFF000000), width: 2),
                                ),
                              ),
                              child: const Icon(
                                Icons.grid_on,
                                color: Color(0xFF000000),
                                size: 24,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: const Icon(
                                Icons.person_pin_outlined,
                                color: Color(0xFF8E8E8E),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Posts Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(2),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return GestureDetector(
                          onTap: () {
                            // TODO: Navigate to post detail
                          },
                          child: SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: CachedNetworkImage(
                              imageUrl: post.image,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[300],
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error, color: Colors.grey),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8E8E8E),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(
    String text, {
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: backgroundColor == Colors.transparent
              ? null
              : Border.all(color: const Color(0xFFE1E1E1)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
