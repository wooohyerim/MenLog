/// 지역 내 한 매장의 대표 방문 정보(그 매장의 가장 최근 방문).
class ShopVisitSummary {
  const ShopVisitSummary({
    required this.shopId,
    required this.shopName,
    required this.thumbnailUrl,
    required this.rating,
    this.memo,
    required this.visitedAt,
  });

  final String shopId;
  final String shopName;
  final String thumbnailUrl;
  final int rating;
  final String? memo;
  final DateTime visitedAt;
}

/// 시/군/구 하나에 대한 정복 집계 결과.
///
/// [shops]는 서로 다른 매장 기준으로 1개씩만 담는다(같은 매장을 여러 번
/// 방문해도 매장 수 집계에는 1개로만 카운트 — 기획서 3.1 기능1 예외 처리).
/// 방문일 최신순으로 정렬되어 있어 [representativePhotoUrl]이 지역
/// 전체에서 가장 최근 방문 사진이 된다.
class RegionConquestSummary {
  const RegionConquestSummary({
    required this.sggCode,
    required this.sggName,
    required this.sidoName,
    required this.shops,
  });

  final String sggCode;
  final String sggName;
  final String sidoName;
  final List<ShopVisitSummary> shops;

  int get shopCount => shops.length;

  String get representativePhotoUrl => shops.first.thumbnailUrl;
}
