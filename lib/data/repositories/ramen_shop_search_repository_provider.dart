import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/repositories/ramen_shop_search_repository.dart';

/// 지도/기록하기(+)/추천 탭이 공통으로 주입받아 쓰는 라멘집 검색 저장소.
final ramenShopSearchRepositoryProvider =
    Provider<RamenShopSearchRepository>((ref) {
      final repository = RamenShopSearchRepository();
      ref.onDispose(repository.dispose);
      return repository;
    });
