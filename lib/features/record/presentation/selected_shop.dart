import 'package:menlog/data/models/ramen_shop_search_result.dart';

/// 기록하기 화면에서 사용자가 확정한 매장 한 곳. 검색 결과에서 고른
/// 경우와 수동 입력한 경우를 하나의 타입으로 통일해서 이후 저장 로직이
/// 분기 없이 다룰 수 있게 한다.
///
/// [lat]/[lng]는 수동 입력 시 null이며, 저장 시점에 [address]를 지오코딩해
/// 채운다 — 구글맵 SDK 제거 이후 좌표는 화면에 표시되는 곳이 없어(정복맵은
/// 주소 문자열 매칭만 쓴다) 검색 시점에 미리 구할 필요가 없다.
class SelectedShop {
  const SelectedShop({
    required this.name,
    required this.googlePlaceId,
    required this.address,
    required this.lat,
    required this.lng,
    required this.isManual,
  });

  factory SelectedShop.fromSearchResult(RamenShopSearchResult result) {
    return SelectedShop(
      name: result.name,
      googlePlaceId: result.googlePlaceId,
      address: result.address,
      lat: result.lat,
      lng: result.lng,
      isManual: false,
    );
  }

  factory SelectedShop.manual({
    required String name,
    required String address,
    required String syntheticPlaceId,
  }) {
    return SelectedShop(
      name: name,
      googlePlaceId: syntheticPlaceId,
      address: address,
      lat: null,
      lng: null,
      isManual: true,
    );
  }

  final String name;
  final String googlePlaceId;
  final String? address;
  final double? lat;
  final double? lng;
  final bool isManual;
}
