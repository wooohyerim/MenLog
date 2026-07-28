import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menlog/core/constants/env.dart';

const Duration _kRequestTimeout = Duration(seconds: 10);

/// 주소 문자열 → 좌표 변환 결과.
class GeocodingResult {
  const GeocodingResult({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// 기록하기(+) 화면에서 매장을 수동 등록할 때, 사용자가 입력한 주소로
/// 좌표를 채우는 용도. `ramen_shops.lat/lng`는 구글맵 SDK 제거 이후 앱
/// 어디에서도 화면에 표시하지 않으므로(정복맵은 행정구역 경계 폴리곤을
/// 그리고 `RegionMatcher`가 주소 문자열로 매칭한다), 실패해도 저장 자체를
/// 막을 이유는 없다 — 호출부는 실패 시 0.0/0.0으로 대체한다.
class GeocodingRepository {
  final http.Client _httpClient = http.Client();

  Future<GeocodingResult?> geocode(String address) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'address': address,
      'language': 'ko',
      'region': 'kr',
      'key': Env.googlePlacesApiKey,
    });

    try {
      final response = await _httpClient.get(uri).timeout(_kRequestTimeout);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? const [];
      if (results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      if (location == null) return null;

      return GeocodingResult(
        lat: (location['lat'] as num).toDouble(),
        lng: (location['lng'] as num).toDouble(),
      );
    } on Exception {
      return null;
    }
  }

  void dispose() => _httpClient.close();
}
