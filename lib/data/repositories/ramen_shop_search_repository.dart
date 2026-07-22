import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:menlog/core/constants/env.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/models/ramen_shop_search_result.dart';

const String _kSearchTextUrl =
    'https://places.googleapis.com/v1/places:searchText';
const String _kFieldMask =
    'places.id,places.displayName,places.formattedAddress,places.location,places.addressComponents';
const String _kSearchKeyword = '라멘';
const int _kDefaultRadiusMeters = 20000;
const Duration _kDebounceDuration = Duration(milliseconds: 300);
const Duration _kCacheTtl = Duration(minutes: 5);
const Duration _kRequestTimeout = Duration(seconds: 10);

/// 라멘집 검색 공통 저장소 (기획서 5장 공통 모듈 설계).
///
/// 지도/기록하기(+)/추천 탭이 각자 구현하면 API 호출·파싱·에러 처리가
/// 제각각이 되므로 이 저장소 하나로 통합한다. Google Places Text Search
/// (New)로 "라멘" 관련 매장을 찾고, 결과마다 우리 `ramen_shops`/`visits`
/// 테이블을 조회해 [RamenShopSearchResult.isRegistered]/[visitCount]를
/// 채워 반환한다.
class RamenShopSearchRepository {
  final http.Client _httpClient = http.Client();
  final Map<String, _CacheEntry> _cache = {};
  Timer? _debounceTimer;
  Completer<RamenShopSearchOutcome>? _pendingCompleter;

  /// [query]가 비어 있으면 위치 기반 주변 검색으로 폴백한다.
  /// 300ms 안에 연속으로 들어온 호출은 마지막 호출 하나로만 실제 요청하고,
  /// 그 결과를 대기 중이던 모든 호출자가 함께 받는다(디바운스).
  Future<RamenShopSearchOutcome> search({
    String? query,
    double? latitude,
    double? longitude,
    int? radiusMeters,
    String? groupId,
  }) {
    _pendingCompleter ??= Completer<RamenShopSearchOutcome>();
    final completer = _pendingCompleter!;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(_kDebounceDuration, () {
      _pendingCompleter = null;
      unawaited(
        _flush(
          completer: completer,
          query: query,
          latitude: latitude,
          longitude: longitude,
          radiusMeters: radiusMeters,
          groupId: groupId,
        ),
      );
    });

    return completer.future;
  }

  /// Provider dispose 시 타이머/HTTP 클라이언트를 정리한다.
  void dispose() {
    _debounceTimer?.cancel();
    _httpClient.close();
  }

  Future<void> _flush({
    required Completer<RamenShopSearchOutcome> completer,
    required String? query,
    required double? latitude,
    required double? longitude,
    required int? radiusMeters,
    required String? groupId,
  }) async {
    final outcome = await _resolve(
      query: query,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
      groupId: groupId,
    );
    completer.complete(outcome);
  }

  Future<RamenShopSearchOutcome> _resolve({
    required String? query,
    required double? latitude,
    required double? longitude,
    required int? radiusMeters,
    required String? groupId,
  }) async {
    final cacheKey = _buildCacheKey(query, latitude, longitude, radiusMeters);
    final cached = _cache[cacheKey];

    if (cached != null && !cached.isExpired) return cached.outcome;

    try {
      final candidates = await _fetchFromGooglePlaces(
        query: query,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      final results = await _enrichWithLocalData(candidates, groupId: groupId);
      final outcome = RamenShopSearchOutcome(results: results);

      _cache[cacheKey] = _CacheEntry(outcome: outcome, cachedAt: DateTime.now());
      return outcome;
    } on Exception catch (_) {
      if (cached != null) {
        return RamenShopSearchOutcome(
          results: cached.outcome.results,
          isFromCache: true,
        );
      }
      return const RamenShopSearchOutcome(results: [], hasError: true);
    }
  }

  String _buildCacheKey(
    String? query,
    double? latitude,
    double? longitude,
    int? radiusMeters,
  ) {
    final normalizedQuery = query?.trim().toLowerCase() ?? '';
    final latBucket = _bucket(latitude);
    final lngBucket = _bucket(longitude);
    return '$normalizedQuery|$latBucket|$lngBucket|${radiusMeters ?? _kDefaultRadiusMeters}';
  }

  /// 위치를 소수점 둘째 자리(약 1km) 단위로 묶어 캐시 버킷을 만든다.
  double? _bucket(double? value) {
    if (value == null) return null;
    return (value * 100).roundToDouble() / 100;
  }

  Future<List<RamenShopSearchResult>> _fetchFromGooglePlaces({
    required String? query,
    required double? latitude,
    required double? longitude,
    required int? radiusMeters,
  }) async {
    final hasQuery = query?.trim().isNotEmpty ?? false;
    final body = _buildSearchTextBody(
      textQuery: _buildTextQuery(query),
      hasQuery: hasQuery,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );

    final response = await _httpClient
        .post(
          Uri.parse(_kSearchTextUrl),
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': Env.googlePlacesApiKey,
            'X-Goog-FieldMask': _kFieldMask,
          },
          body: jsonEncode(body),
        )
        .timeout(_kRequestTimeout);

    if (response.statusCode != 200) {
      throw _RamenShopSearchApiException(
        'Google Places 응답 오류: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final places = decoded['places'] as List<dynamic>? ?? const [];

    return places
        .whereType<Map<String, dynamic>>()
        .map(RamenShopSearchResult.fromGooglePlaceJson)
        .toList();
  }

  String _buildTextQuery(String? rawQuery) {
    final trimmed = rawQuery?.trim() ?? '';
    if (trimmed.isEmpty) return _kSearchKeyword;
    if (trimmed.contains(_kSearchKeyword)) return trimmed;
    return '$trimmed $_kSearchKeyword';
  }

  Map<String, dynamic> _buildSearchTextBody({
    required String textQuery,
    required bool hasQuery,
    required double? latitude,
    required double? longitude,
    required int? radiusMeters,
  }) {
    final body = <String, dynamic>{
      'textQuery': textQuery,
      'languageCode': 'ko',
      'regionCode': 'KR',
    };

    final locationFilter = _buildLocationFilter(
      hasQuery: hasQuery,
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );
    if (locationFilter == null) return body;

    return {...body, ...locationFilter};
  }

  /// 검색어가 있으면 위치는 참고용(locationBias), 검색어가 없는 위치 기반
  /// 폴백 검색이면 위치를 강제 조건(locationRestriction)으로 건다.
  Map<String, dynamic>? _buildLocationFilter({
    required bool hasQuery,
    required double? latitude,
    required double? longitude,
    required int? radiusMeters,
  }) {
    if (latitude == null || longitude == null) return null;

    final circle = {
      'circle': {
        'center': {'latitude': latitude, 'longitude': longitude},
        'radius': (radiusMeters ?? _kDefaultRadiusMeters).toDouble(),
      },
    };

    if (hasQuery) return {'locationBias': circle};
    return {'locationRestriction': circle};
  }

  Future<List<RamenShopSearchResult>> _enrichWithLocalData(
    List<RamenShopSearchResult> candidates, {
    required String? groupId,
  }) async {
    if (candidates.isEmpty) return candidates;

    final placeIds = candidates
        .map((candidate) => candidate.googlePlaceId)
        .toList();
    final registeredRows = await supabase
        .from('ramen_shops')
        .select('id, google_place_id')
        .inFilter('google_place_id', placeIds);

    final shopIdByPlaceId = Map<String, String>.fromEntries(
      registeredRows.map(
        (row) => MapEntry(
          row['google_place_id'] as String,
          row['id'] as String,
        ),
      ),
    );

    final userId = supabase.auth.currentUser?.id;
    final visitCountByShopId = await _fetchVisitCounts(
      shopIds: shopIdByPlaceId.values.toList(),
      userId: userId,
      groupId: groupId,
    );

    return candidates.map((candidate) {
      final shopId = shopIdByPlaceId[candidate.googlePlaceId];
      if (shopId == null) return candidate;
      return candidate.copyWith(
        isRegistered: true,
        visitCount: visitCountByShopId[shopId] ?? 0,
      );
    }).toList();
  }

  /// 그룹 방문 횟수. [groupId]가 없으면 현재 유저 기준 전체 그룹 합산으로
  /// 우선 구현했다 — 그룹별로 분리해서 세고 싶은 화면(지도 등)은 이후
  /// [groupId]를 넘겨 좁혀 쓸 수 있다.
  Future<Map<String, int>> _fetchVisitCounts({
    required List<String> shopIds,
    required String? userId,
    required String? groupId,
  }) async {
    if (shopIds.isEmpty || userId == null) return {};

    var query = supabase
        .from('visits')
        .select('shop_id')
        .eq('user_id', userId)
        .inFilter('shop_id', shopIds);

    if (groupId != null) {
      query = query.eq('group_id', groupId);
    }

    final rows = await query;
    final shopIdColumn = rows.map((row) => row['shop_id'] as String);

    return shopIdColumn.fold<Map<String, int>>({}, (counts, shopId) {
      counts[shopId] = (counts[shopId] ?? 0) + 1;
      return counts;
    });
  }
}

class _RamenShopSearchApiException implements Exception {
  const _RamenShopSearchApiException(this.message);

  final String message;

  @override
  String toString() => 'RamenShopSearchApiException: $message';
}

class _CacheEntry {
  _CacheEntry({required this.outcome, required DateTime cachedAt})
    : _cachedAt = cachedAt;

  final RamenShopSearchOutcome outcome;
  final DateTime _cachedAt;

  bool get isExpired => DateTime.now().difference(_cachedAt) > _kCacheTtl;
}
