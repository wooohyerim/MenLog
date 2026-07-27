import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/models/region_conquest.dart';
import 'package:menlog/data/models/sig_boundary.dart';
import 'package:menlog/data/repositories/region_matcher.dart';
import 'package:menlog/data/repositories/sig_boundary_repository.dart';

/// 그룹의 방문 기록을 시/군/구 단위로 집계해 정복맵 데이터를 만든다
/// (기획서 3.1 기능1).
class ConquestRepository {
  Future<Map<String, RegionConquestSummary>> loadByGroup(
    String groupId,
  ) async {
    final boundaries = await sigBoundaryRepository.loadAll();
    final matcher = RegionMatcher(boundaries);
    final boundaryBySggCode = Map<String, SigBoundary>.fromEntries(
      boundaries.map((boundary) => MapEntry(boundary.sggCode, boundary)),
    );

    final rows = await supabase
        .from('visits')
        .select(
          'shop_id, thumbnail_url, rating, memo, visited_at, '
          'ramen_shops(name, address)',
        )
        .eq('group_id', groupId)
        .order('visited_at', ascending: false);

    return _aggregate(rows, matcher, boundaryBySggCode);
  }

  Map<String, RegionConquestSummary> _aggregate(
    List<Map<String, dynamic>> rows,
    RegionMatcher matcher,
    Map<String, SigBoundary> boundaryBySggCode,
  ) {
    final shopsByRegion = rows.fold<Map<String, Map<String, ShopVisitSummary>>>(
      {},
      (acc, row) {
        final shop = row['ramen_shops'] as Map<String, dynamic>?;
        final address = shop?['address'] as String?;
        if (shop == null || address == null) return acc;

        final boundary = matcher.match(address);
        if (boundary == null) return acc;

        final shopId = row['shop_id'] as String;
        final existingRegionShops = acc[boundary.sggCode] ?? const {};
        if (existingRegionShops.containsKey(shopId)) return acc;

        final summary = ShopVisitSummary(
          shopId: shopId,
          shopName: shop['name'] as String? ?? '',
          thumbnailUrl: row['thumbnail_url'] as String,
          rating: row['rating'] as int,
          memo: row['memo'] as String?,
          visitedAt: DateTime.parse(row['visited_at'] as String),
        );

        return {
          ...acc,
          boundary.sggCode: {...existingRegionShops, shopId: summary},
        };
      },
    );

    return shopsByRegion.map((sggCode, shops) {
      final boundary = boundaryBySggCode[sggCode]!;
      final sortedShops = List<ShopVisitSummary>.of(shops.values)
        ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

      return MapEntry(
        sggCode,
        RegionConquestSummary(
          sggCode: sggCode,
          sggName: boundary.sggName,
          sidoName: boundary.sidoName,
          shops: sortedShops,
        ),
      );
    });
  }
}

final conquestRepository = ConquestRepository();
