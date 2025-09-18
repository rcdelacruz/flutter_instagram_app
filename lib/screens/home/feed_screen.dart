import 'package:flutter/material.dart';
import '../../widgets/post_card.dart';
import '../../widgets/stories_section.dart';
import '../../widgets/linear_gradient.dart';
import '../../hooks/use_posts.dart';

// Exact replica of React Native FeedScreen (app/(tabs)/index.tsx)
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late PostsNotifier _postsNotifier;

  @override
  void initState() {
    super.initState();
    _postsNotifier = PostsNotifier();
  }

  @override
  void dispose() {
    _postsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _postsNotifier,
          builder: (context, child) {
            // Show loading state - exact replica of React Native
            if (_postsNotifier.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF007AFF)),
                    SizedBox(height: 16),
                    Text(
                      'Loading feed...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show error state - exact replica of React Native
            if (_postsNotifier.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _postsNotifier.error!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFF3B30),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _postsNotifier.refresh(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Header - exact replica of React Native header
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
                      // Instagram logo with gradient
                      LinearGradientWidget(
                        colors: const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        borderRadius: BorderRadius.circular(8),
                        child: const Text(
                          'Instagram',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Header icons
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Icon(
                                Icons.favorite_border,
                                color: Color(0xFF000000),
                                size: 24,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: Color(0xFF000000),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Stories section
                      SliverToBoxAdapter(
                        child: StoriesSection(stories: _postsNotifier.stories),
                      ),

                      // Posts
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = _postsNotifier.posts[index];
                            return PostCard(
                              post: post,
                              onLike: () => _postsNotifier.likePost(post.id),
                              onSave: () => _postsNotifier.savePost(post.id),
                              onComment: () {
                                // TODO: Navigate to comments screen
                              },
                              onShare: () {
                                // TODO: Implement share functionality
                              },
                            );
                          },
                          childCount: _postsNotifier.posts.length,
                        ),
                      ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 20),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
