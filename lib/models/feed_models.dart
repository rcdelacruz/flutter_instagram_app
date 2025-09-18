// Feed Models - Exact replica of React Native types
class FeedPost {
  final String id;
  final FeedUser user;
  final String image;
  final String caption;
  final int likes;
  final int comments;
  final String timestamp;
  final bool? isLiked;
  final bool? isSaved;

  const FeedPost({
    required this.id,
    required this.user,
    required this.image,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.timestamp,
    this.isLiked,
    this.isSaved,
  });

  FeedPost copyWith({
    String? id,
    FeedUser? user,
    String? image,
    String? caption,
    int? likes,
    int? comments,
    String? timestamp,
    bool? isLiked,
    bool? isSaved,
  }) {
    return FeedPost(
      id: id ?? this.id,
      user: user ?? this.user,
      image: image ?? this.image,
      caption: caption ?? this.caption,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      timestamp: timestamp ?? this.timestamp,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedPost && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class FeedUser {
  final String username;
  final String avatar;

  const FeedUser({
    required this.username,
    required this.avatar,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeedUser && other.username == username;
  }

  @override
  int get hashCode => username.hashCode;
}

class Story {
  final String id;
  final FeedUser user;
  final bool hasViewed;

  const Story({
    required this.id,
    required this.user,
    required this.hasViewed,
  });

  Story copyWith({
    String? id,
    FeedUser? user,
    bool? hasViewed,
  }) {
    return Story(
      id: id ?? this.id,
      user: user ?? this.user,
      hasViewed: hasViewed ?? this.hasViewed,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Story && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Profile Models
class ProfileUser {
  final String username;
  final String avatar;
  final String displayName;
  final String bio;
  final String? website;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isPrivate;

  const ProfileUser({
    required this.username,
    required this.avatar,
    required this.displayName,
    required this.bio,
    this.website,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.isPrivate = false,
  });

  ProfileUser copyWith({
    String? username,
    String? avatar,
    String? displayName,
    String? bio,
    String? website,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? isPrivate,
  }) {
    return ProfileUser(
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}

class GridPost {
  final String id;
  final String image;

  const GridPost({
    required this.id,
    required this.image,
  });
}

// Search Models
class SearchPost {
  final String id;
  final String image;

  const SearchPost({
    required this.id,
    required this.image,
  });
}
