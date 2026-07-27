import 'package:menlog/data/models/sig_boundary.dart';

const List<String> _kSidoSuffixes = [
  '특별자치도',
  '특별자치시',
  '광역시',
  '특별시',
  '자치도',
  '도',
];

/// 매장 주소 문자열을 시/군/구 경계에 매칭한다.
///
/// 기획서 3.1 기능1 기술 메모: point-in-polygon 대신 Google Places가 이미
/// 반환한 주소 문자열을 그대로 매칭하는 방식을 쓴다. "중구"처럼 여러
/// 시/도에 같은 이름이 존재하는 경우 시/도 축약형(예: "서울특별시" →
/// "서울")까지 주소에 포함되는지로 한 번 더 좁힌다. 그래도 특정할 수 없으면
/// null — 호출부는 해당 매장을 지도에서 제외하고 로그만 남긴다(예외 처리).
class RegionMatcher {
  RegionMatcher(this._boundaries);

  final List<SigBoundary> _boundaries;

  SigBoundary? match(String address) {
    final candidates = _boundaries
        .where((boundary) => address.contains(boundary.sggName))
        .toList();

    if (candidates.isEmpty) return null;
    if (candidates.length == 1) return candidates.first;

    final bySido = candidates
        .where(
          (boundary) => address.contains(_shortSidoName(boundary.sidoName)),
        )
        .toList();
    if (bySido.length == 1) return bySido.first;

    return null;
  }

  String _shortSidoName(String sidoName) {
    final suffix = _kSidoSuffixes.firstWhere(
      (candidate) => sidoName.endsWith(candidate),
      orElse: () => '',
    );
    if (suffix.isEmpty) return sidoName;
    return sidoName.substring(0, sidoName.length - suffix.length);
  }
}
