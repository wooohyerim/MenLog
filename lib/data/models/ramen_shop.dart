class RamenShop {
  final String id;
  final String googlePlaceId;
  final String name;
  final String? address;
  final double lat;
  final double lng;
  final DateTime createdAt;

  RamenShop({
    required this.id,
    required this.googlePlaceId,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  factory RamenShop.fromJson(Map<String, dynamic> json) {
    return RamenShop(
      id: json['id'] as String,
      googlePlaceId: json['google_place_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_place_id': googlePlaceId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
