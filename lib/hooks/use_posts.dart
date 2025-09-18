import 'package:flutter/foundation.dart';
import '../models/feed_models.dart';

// Enhanced usePosts hook with Supabase integration - exact replica of React Native
class PostsNotifier extends ChangeNotifier {
  List<FeedPost> _posts = [];
  List<Story> _stories = [];
  bool _isLoading = true;
  String? _error;

  List<FeedPost> get posts => _posts;
  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  PostsNotifier() {
    _loadPosts();
    _loadStories();
  }

  // Load feed posts - exact replica of React Native logic
  Future<void> _loadPosts() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement real Supabase integration
      // For now, use mock data that matches React Native exactly
      await Future.delayed(const Duration(milliseconds: 500));

      final mockPosts = [
        FeedPost(
          id: '1',
          user: const FeedUser(
            username: 'john_doe',
            avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
          ),
          image: 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=400&fit=crop',
          caption: 'Beautiful sunset at the beach 🌅',
          likes: 142,
          comments: 23,
          timestamp: '2 hours ago',
          isLiked: false,
          isSaved: false,
        ),
        FeedPost(
          id: '2',
          user: const FeedUser(
            username: 'jane_smith',
            avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
          ),
          image: 'https://images.unsplash.com/photo-1551963831-b3b1ca40c98e?w=400&h=400&fit=crop',
          caption: 'Coffee and code ☕️💻',
          likes: 89,
          comments: 12,
          timestamp: '4 hours ago',
          isLiked: false,
          isSaved: false,
        ),
        FeedPost(
          id: '3',
          user: const FeedUser(
            username: 'travel_lover',
            avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
          ),
          image: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=400&h=400&fit=crop',
          caption: 'Mountain adventures 🏔️',
          likes: 256,
          comments: 45,
          timestamp: '6 hours ago',
          isLiked: false,
          isSaved: false,
        ),
      ];

      _posts = mockPosts;
      _isLoading = false;
      notifyListeners();
    } catch (err) {
      _error = err.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load stories - exact replica of React Native logic
  Future<void> _loadStories() async {
    // TODO: Implement real stories from Supabase when stories table is ready
    final mockStories = [
      const Story(
        id: '1',
        user: FeedUser(
          username: 'john_doe',
          avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
        ),
        hasViewed: false,
      ),
      const Story(
        id: '2',
        user: FeedUser(
          username: 'jane_smith',
          avatar: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
        ),
        hasViewed: true,
      ),
      const Story(
        id: '3',
        user: FeedUser(
          username: 'travel_lover',
          avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
        ),
        hasViewed: false,
      ),
    ];
    _stories = mockStories;
    notifyListeners();
  }

  // Like/unlike a post - exact replica of React Native logic
  Future<void> likePost(String postId) async {
    try {
      // Optimistically update UI
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final newIsLiked = !(post.isLiked ?? false);
        final newLikes = newIsLiked ? post.likes + 1 : post.likes - 1;
        
        _posts[postIndex] = post.copyWith(
          isLiked: newIsLiked,
          likes: newLikes,
        );
        notifyListeners();
      }

      // TODO: Make API call to Supabase
      // For now, just simulate API call
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (err) {
      // Revert optimistic update on failure
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final revertIsLiked = !(post.isLiked ?? false);
        final revertLikes = revertIsLiked ? post.likes - 1 : post.likes + 1;
        
        _posts[postIndex] = post.copyWith(
          isLiked: revertIsLiked,
          likes: revertLikes,
        );
        notifyListeners();
      }
    }
  }

  // Save/unsave a post - exact replica of React Native logic
  Future<void> savePost(String postId) async {
    try {
      // Optimistically update UI
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = post.copyWith(
          isSaved: !(post.isSaved ?? false),
        );
        notifyListeners();
      }

      // TODO: Implement save/unsave API calls when ready
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (err) {
      debugPrint('Error saving post: $err');
    }
  }

  // Refresh all data
  Future<void> refresh() async {
    await Future.wait([
      _loadPosts(),
      _loadStories(),
    ]);
  }
}
