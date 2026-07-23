/// 위경도 좌표 한 점. GeoJSON은 `[lng, lat]` 순서라 헷갈리기 쉬워서
/// 필드명으로 명시했다.
class GeoPoint {
  const GeoPoint({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

/// 시/군/구 하나의 행정구역 경계.
///
/// [polygons]는 다각형 파트 목록이다 — 섬이 많은 지역(예: 옹진군)은 여러
/// 개의 분리된 파트를 가진다(GeoJSON의 MultiPolygon). 각 파트는 외곽선
/// 좌표만 담는다 — assets/data/sig_boundaries.geojson에는 구멍(내부 링)이
/// 있는 폴리곤이 없음을 확인했다.
class SigBoundary {
  const SigBoundary({
    required this.sggCode,
    required this.sggName,
    required this.sidoCode,
    required this.sidoName,
    required this.polygons,
  });

  final String sggCode;
  final String sggName;
  final String sidoCode;
  final String sidoName;
  final List<List<GeoPoint>> polygons;

  factory SigBoundary.fromGeoJsonFeature(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>;
    final geometry = feature['geometry'] as Map<String, dynamic>;

    return SigBoundary(
      sggCode: properties['sggcd'] as String,
      sggName: properties['sggnm'] as String,
      sidoCode: properties['sidocd'] as String,
      sidoName: properties['sidonm'] as String,
      polygons: _parsePolygons(geometry),
    );
  }

  static List<List<GeoPoint>> _parsePolygons(Map<String, dynamic> geometry) {
    final type = geometry['type'] as String;
    final coordinates = geometry['coordinates'] as List<dynamic>;

    if (type == 'Polygon') {
      return [_parseRing(coordinates.first as List<dynamic>)];
    }

    // MultiPolygon: [[ring0, ring1, ...], [ring0, ...], ...] — 파트마다
    // 외곽선(첫 번째 링)만 취한다.
    return coordinates.map((part) {
      final rings = part as List<dynamic>;
      return _parseRing(rings.first as List<dynamic>);
    }).toList();
  }

  static List<GeoPoint> _parseRing(List<dynamic> ring) {
    return ring.map((point) {
      final coord = point as List<dynamic>;
      return GeoPoint(
        lng: (coord[0] as num).toDouble(),
        lat: (coord[1] as num).toDouble(),
      );
    }).toList();
  }
}
