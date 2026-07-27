import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/models/sig_boundary.dart';
import 'package:menlog/data/repositories/sig_boundary_repository.dart';

/// 전국 시/군/구 경계 목록. 앱 실행 중 바뀌지 않으므로 저장소가 자체
/// 캐시하고, 여기서는 그 결과를 Riverpod에 노출만 한다.
final sigBoundariesProvider = FutureProvider.autoDispose<List<SigBoundary>>((
  ref,
) {
  return sigBoundaryRepository.loadAll();
});
