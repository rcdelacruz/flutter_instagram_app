import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Exact replica of React Native ActivityScreen (app/(tabs)/activity.tsx)
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<ActivityItem> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  void _loadActivities() {
    // Mock activity data - exact replica of React Native structure
    _activities = [
      ActivityItem(
        id: '1',
        type: ActivityType.like,
        user: const ActivityUser(
          username: 'jane_smith',
          avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        ),
        message: 'liked your photo.',
        timestamp: '2h',
        postImage: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
      ),
      ActivityItem(
        id: '2',
        type: ActivityType.follow,
        user: const ActivityUser(
          username: 'travel_lover',
          avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        ),
        message: 'started following you.',
        timestamp: '4h',
      ),
      ActivityItem(
        id: '3',
        type: ActivityType.comment,
        user: const ActivityUser(
          username: 'photo_enthusiast',
          avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face',
        ),
        message: 'commented: "Amazing shot! 📸"',
        timestamp: '6h',
        postImage: 'https://images.unsplash.com/photo-1551963831-b3b1ca40c98e?w=400&h=400&fit=crop',
      ),
      ActivityItem(
        id: '4',
        type: ActivityType.like,
        user: const ActivityUser(
          username: 'nature_lover',
          avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
        ),
        message: 'liked your photo.',
        timestamp: '1d',
        postImage: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=400&fit=crop',
      ),
    ];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE1E1E1), width: 1),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),

            // Activity List
            Expanded(
              child: _activities.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Color(0xFF8E8E8E),
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Activity On Your Posts',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF000000),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'When someone likes or comments on one of your posts, you\'ll see it here.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF8E8E8E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _activities.length,
                      itemBuilder: (context, index) {
                        final activity = _activities[index];
                        return _buildActivityItem(activity);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ActivityItem activity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // User Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl: activity.user.avatar,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[300],
              ),
              errorWidget: (context, url, error) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Activity Text
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: activity.user.username,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                  TextSpan(
                    text: ' ${activity.message}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF000000),
                    ),
                  ),
                  TextSpan(
                    text: ' ${activity.timestamp}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Post Image or Follow Button
          if (activity.postImage != null)
            Container(
              margin: const EdgeInsets.only(left: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: activity.postImage!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
            )
          else if (activity.type == ActivityType.follow)
            Container(
              margin: const EdgeInsets.only(left: 12),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle follow back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0095F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Activity Models
enum ActivityType { like, comment, follow }

class ActivityItem {
  final String id;
  final ActivityType type;
  final ActivityUser user;
  final String message;
  final String timestamp;
  final String? postImage;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.user,
    required this.message,
    required this.timestamp,
    this.postImage,
  });
}

class ActivityUser {
  final String username;
  final String avatar;

  const ActivityUser({
    required this.username,
    required this.avatar,
  });
}
