import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:menlog/data/models/sig_boundary.dart';

const String _kSigBoundariesAsset = 'assets/data/sig_boundaries.geojson';

/// assets/data/sig_boundaries.geojson(전국 시/군/구 경계, 출처와 라이선스는
/// assets/data/SIG_BOUNDARIES_SOURCE.md 참고)를 읽어 [SigBoundary] 목록으로
/// 파싱한다. 파싱 결과는 메모리에 캐시한다 — 앱 실행 중 바뀔 데이터가
/// 아니다.
class SigBoundaryRepository {
  List<SigBoundary>? _cache;

  Future<List<SigBoundary>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(_kSigBoundariesAsset);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final features = decoded['features'] as List<dynamic>;

    final boundaries = features
        .map(
          (feature) =>
              SigBoundary.fromGeoJsonFeature(feature as Map<String, dynamic>),
        )
        .toList();

    _cache = boundaries;
    return boundaries;
  }
}

final sigBoundaryRepository = SigBoundaryRepository();
