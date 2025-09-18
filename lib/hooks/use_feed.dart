import 'package:flutter/foundation.dart';
import '../models/feed_models.dart';
import 'use_posts.dart';

// Legacy useFeed hook - delegates to usePosts (exact replica of React Native)
class UseFeed {
  final List<FeedPost> posts;
  final List<Story> stories;
  final bool isLoading;
  final String? error;

  const UseFeed({
    required this.posts,
    required this.stories,
    required this.isLoading,
    this.error,
  });
}

class FeedNotifier extends ChangeNotifier {
  final PostsNotifier _postsNotifier;
  
  FeedNotifier(this._postsNotifier) {
    _postsNotifier.addListener(_onPostsChanged);
  }

  void _onPostsChanged() {
    notifyListeners();
  }

  UseFeed get state => UseFeed(
    posts: _postsNotifier.posts,
    stories: _postsNotifier.stories,
    isLoading: _postsNotifier.isLoading,
    error: _postsNotifier.error,
  );

  @override
  void dispose() {
    _postsNotifier.removeListener(_onPostsChanged);
    super.dispose();
  }
}
