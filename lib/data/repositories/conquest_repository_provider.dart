import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/models/region_conquest.dart';
import 'package:menlog/data/repositories/conquest_repository.dart';

/// 그룹 ID별 정복맵 집계 결과(시/군/구 코드 → [RegionConquestSummary]).
final conquestByGroupProvider = FutureProvider.autoDispose
    .family<Map<String, RegionConquestSummary>, String>((ref, groupId) {
      return conquestRepository.loadByGroup(groupId);
    });
