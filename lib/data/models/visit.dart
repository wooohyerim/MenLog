enum MediaType { photo, video }

enum BrothType { tonkotsu, shoyu, miso, shio, tsukemen }

class Visit {
  final String id;
  final String shopId;
  final String groupId;
  final String userId;
  final String mediaUrl;
  final MediaType mediaType;
  final String thumbnailUrl;
  final BrothType? brothType;
  final int rating;
  final String? memo;
  final DateTime visitedAt;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.shopId,
    required this.groupId,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    required this.thumbnailUrl,
    this.brothType,
    required this.rating,
    this.memo,
    required this.visitedAt,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      mediaType: MediaType.values.byName(json['media_type'] as String),
      thumbnailUrl: json['thumbnail_url'] as String,
      brothType: json['broth_type'] != null
          ? BrothType.values.byName(json['broth_type'] as String)
          : null,
      rating: json['rating'] as int,
      memo: json['memo'] as String?,
      visitedAt: DateTime.parse(json['visited_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
