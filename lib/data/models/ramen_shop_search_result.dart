/// [RamenShopSearchRepository]가 반환하는 정규화된 검색 결과 한 건.
///
/// Google Places 원본 응답과 우리 `ramen_shops`/`visits` 테이블 조회 결과를
/// 합쳐서 만들어진다. [isRegistered]/[visitCount]는 저장소가 조회 후
/// [copyWith]로 채워 넣는다.
class RamenShopSearchResult {
  const RamenShopSearchResult({
    required this.googlePlaceId,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    this.regionCode,
    this.isRegistered = false,
    this.visitCount = 0,
  });

  final String googlePlaceId;
  final String name;
  final String? address;
  final double lat;
  final double lng;
  final String? regionCode;
  final bool isRegistered;
  final int visitCount;

  factory RamenShopSearchResult.fromGooglePlaceJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final addressComponents =
        json['addressComponents'] as List<dynamic>? ?? const [];

    return RamenShopSearchResult(
      googlePlaceId: json['id'] as String,
      name: displayName?['text'] as String? ?? '',
      address: json['formattedAddress'] as String?,
      lat: (location?['latitude'] as num?)?.toDouble() ?? 0,
      lng: (location?['longitude'] as num?)?.toDouble() ?? 0,
      regionCode: _extractRegionCode(addressComponents),
    );
  }

  RamenShopSearchResult copyWith({bool? isRegistered, int? visitCount}) {
    return RamenShopSearchResult(
      googlePlaceId: googlePlaceId,
      name: name,
      address: address,
      lat: lat,
      lng: lng,
      regionCode: regionCode,
      isRegistered: isRegistered ?? this.isRegistered,
      visitCount: visitCount ?? this.visitCount,
    );
  }

  /// 구 > 군 > 시 순으로 주소 구성요소를 탐색해 시/군/구 명칭을 뽑는다.
  /// Google이 행정구역 유형을 태깅하는 방식이 지역마다 달라서(예: '구'는
  /// sublocality_level_1, '군'은 administrative_area_level_2로 옴) 우선순위
  /// 탐색이 필요하다. 매칭되는 구성요소가 없으면(해외 주소 등) null.
  static String? _extractRegionCode(List<dynamic> components) {
    final typed = components.whereType<Map<String, dynamic>>();

    final gu = typed.firstWhere(
      (component) => _hasType(component, 'sublocality_level_1'),
      orElse: () => const <String, dynamic>{},
    );
    if (gu.isNotEmpty) return gu['longText'] as String?;

    final gun = typed.firstWhere(
      (component) => _hasType(component, 'administrative_area_level_2'),
      orElse: () => const <String, dynamic>{},
    );
    if (gun.isNotEmpty) return gun['longText'] as String?;

    final si = typed.firstWhere(
      (component) => _hasType(component, 'locality'),
      orElse: () => const <String, dynamic>{},
    );
    if (si.isNotEmpty) return si['longText'] as String?;

    return null;
  }

  static bool _hasType(Map<String, dynamic> component, String type) {
    final types = component['types'] as List<dynamic>? ?? const [];
    return types.contains(type);
  }
}

/// [RamenShopSearchRepository.search]의 반환 타입.
///
/// Google API 실패 시 throw 대신 이 타입으로 에러 상태를 표현한다.
/// - 정상: [results]에 최신 데이터, [hasError]=false, [isFromCache]=false
/// - API 실패 + 캐시 있음: 캐시된 [results] 반환, [isFromCache]=true
/// - API 실패 + 캐시 없음: [results]는 빈 리스트, [hasError]=true
class RamenShopSearchOutcome {
  const RamenShopSearchOutcome({
    required this.results,
    this.hasError = false,
    this.isFromCache = false,
  });

  final List<RamenShopSearchResult> results;
  final bool hasError;
  final bool isFromCache;
}
