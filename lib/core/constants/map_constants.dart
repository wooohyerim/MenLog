import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConstants {
  const MapConstants._();

  static const LatLng defaultCenter = LatLng(37.5665, 126.9780);
  static const double defaultZoom = 10.5;

  /// 서울특별시 전역을 포함하는 경계.
  /// 지도 최초 진입 시 이 범위에 맞춰 카메라를 맞춘다.
  static LatLngBounds get seoulBounds => LatLngBounds(
    southwest: const LatLng(37.413, 126.734),
    northeast: const LatLng(37.715, 127.269),
  );

  /// 38선 이남(대한민국 영토)만 포함하는 경계.
  static LatLngBounds get southKoreaBounds => LatLngBounds(
    southwest: const LatLng(33.0, 124.5),
    northeast: const LatLng(38.0, 129.6),
  );
}
