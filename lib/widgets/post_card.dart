import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/feed_models.dart';

class PostCard extends StatefulWidget {
  final FeedPost post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late bool _isLiked;
  late bool _isSaved;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked ?? false;
    _isSaved = widget.post.isSaved ?? false;
    
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _likeAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    
    if (_isLiked) {
      _likeAnimationController.forward().then((_) {
        _likeAnimationController.reverse();
      });
    }
    
    widget.onLike?.call();
  }

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Exact replica of React Native PostCard header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // User Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.post.user.avatar,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 32,
                      height: 32,
                      color: Colors.grey[300],
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 32,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Icon(Icons.person, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Username
                Text(
                  widget.post.user.username,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                const Spacer(),
                // More options
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.more_horiz,
                    color: Color(0xFF000000),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          // Post Image - Full width like React Native
          CachedNetworkImage(
            imageUrl: widget.post.image,
            width: screenWidth,
            height: screenWidth,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: screenWidth,
              height: screenWidth,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: screenWidth,
              height: screenWidth,
              color: Colors.grey[300],
              child: const Icon(Icons.error, color: Colors.grey),
            ),
          ),
          
          // Actions - Exact replica of React Native actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: _handleLike,
                  child: AnimatedBuilder(
                    animation: _likeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _likeAnimation.value,
                        child: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? const Color(0xFFED4956) : const Color(0xFF000000),
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Comment button
                GestureDetector(
                  onTap: widget.onComment,
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Color(0xFF000000),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                // Share button
                GestureDetector(
                  onTap: widget.onShare,
                  child: const Icon(
                    Icons.send_outlined,
                    color: Color(0xFF000000),
                    size: 24,
                  ),
                ),
                const Spacer(),
                // Save button
                GestureDetector(
                  onTap: _handleSave,
                  child: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: const Color(0xFF000000),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          
          // Content - Exact replica of React Native content section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Likes count
                Text(
                  '${widget.post.likes + (_isLiked ? 1 : 0)} likes',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                
                // Caption
                if (widget.post.caption.isNotEmpty) ...[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.post.user.username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                        TextSpan(
                          text: ' ${widget.post.caption}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF000000),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                
                // Comments
                if (widget.post.comments > 0) ...[
                  GestureDetector(
                    onTap: widget.onComment,
                    child: Text(
                      'View all ${widget.post.comments} comments',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8E8E8E),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                
                // Timestamp
                Text(
                  widget.post.timestamp.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8E8E8E),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
