import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/group.dart';
import 'package:menlog/data/models/ramen_shop_search_result.dart';
import 'package:menlog/data/models/region_conquest.dart';
import 'package:menlog/data/models/sig_boundary.dart';
import 'package:menlog/data/repositories/conquest_repository_provider.dart';
import 'package:menlog/data/repositories/group_repository_provider.dart';
import 'package:menlog/data/repositories/ramen_shop_search_repository_provider.dart';
import 'package:menlog/data/repositories/sig_boundary_repository_provider.dart';
import 'package:menlog/features/map/presentation/widgets/conquest_map_view.dart';
import 'package:menlog/features/map/presentation/widgets/empty_region_bottom_sheet.dart';
import 'package:menlog/features/map/presentation/widgets/region_visit_bottom_sheet.dart';
import 'package:menlog/features/record/presentation/record_screen.dart';
import 'package:menlog/shared/widgets/group_sub_tab_selector.dart';
import 'package:menlog/shared/widgets/menlog_header.dart';

const double _kSearchBarHeight = 34;
const double _kSearchBarRadius = 17;
const double _kSpacingSmall = 8;
const double _kSearchResultsMaxHeight = 240;

/// 지도 영역 상/하단 여백 — 그라디언트 페이드 대신 좌우와 동일하게 배경색
/// 여백을 준다.
const double _kMapTopPadding = 16;
const double _kMapBottomPadding = 30;

/// 지도 좌우 여백 — 화면 끝까지 꽉 채우지 않고 배경색이 살짝 보이게 한다.
const double _kMapHorizontalPadding = 16;

/// 지도 탭 홈 화면 — 행정구역 정복맵(기획서 3.1).
///
/// 드릴다운(전국→시/도 확대)은 다음 단계로 미루고, 전국 시/군/구를 한 번에
/// 보여주는 버전부터 구현한다.
class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedGroupId;
  List<RamenShopSearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(myGroupsProvider);
    final maxMemberCount = ref.watch(maxGroupMemberCountProvider).valueOrNull;

    return ColoredBox(
      color: MenlogColors.background,
      child: SafeArea(
        child: Column(
          children: [
            MenlogHeader(friendGroupMemberCount: maxMemberCount ?? 1),
            const SizedBox(height: _kSpacingSmall),
            _buildSearchField(),
            _buildSearchResultsList(),
            const SizedBox(height: _kSpacingSmall),
            groupsAsync.when(
              data: _buildGroupSubTabs,
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            Expanded(child: _buildMapBody(groupsAsync)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: _kSearchBarHeight,
        child: TextField(
          controller: _searchController,
          onChanged: _handleSearchChanged,
          decoration: InputDecoration(
            hintText: '가게 이름으로 검색',
            filled: true,
            fillColor: MenlogColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kSearchBarRadius),
              borderSide: const BorderSide(
                color: MenlogColors.borderPrimarySoft,
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    if (_searchResults.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      constraints: const BoxConstraints(maxHeight: _kSearchResultsMaxHeight),
      decoration: BoxDecoration(
        color: MenlogColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MenlogColors.borderPrimaryFaint),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return ListTile(
            dense: true,
            title: Text(
              result.name,
              style: const TextStyle(color: MenlogColors.dark),
            ),
            subtitle: result.address == null
                ? null
                : Text(
                    result.address!,
                    style: const TextStyle(color: MenlogColors.text),
                  ),
            onTap: () => _handleSearchResultTap(result),
          );
        },
      ),
    );
  }

  Widget _buildGroupSubTabs(List<Group> groups) {
    if (groups.isEmpty) return const SizedBox.shrink();

    return GroupSubTabSelector(
      groups: groups,
      selectedGroupId: _selectedGroupId ?? groups.first.id,
      onSelect: (groupId) => setState(() => _selectedGroupId = groupId),
    );
  }

  Widget _buildMapBody(AsyncValue<List<Group>> groupsAsync) {
    return groupsAsync.when(
      data: (groups) => _buildMapForGroups(groups),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          _buildRetry(() => ref.invalidate(myGroupsProvider)),
    );
  }

  /// 지도 탭은 로그인 여부와 무관하게 접근 가능하므로(main_tab_shell 참고),
  /// 그룹이 하나도 없을 때도(비로그인 등) 전국 미정복 지도는 그대로 보여준다
  /// — 정복 데이터만 빈 상태(`{}`)로 취급한다. 새로고침이 실패해도 배너 +
  /// 지도를 함께 보여준다(경계 데이터 로드 실패 → 이전 캐시 표시 + 재시도
  /// 배너).
  Widget _buildMapForGroups(List<Group> groups) {
    final effectiveGroupId = groups.isEmpty
        ? null
        : (_selectedGroupId ?? groups.first.id);

    final boundariesAsync = ref.watch(sigBoundariesProvider);
    final conquestAsync = effectiveGroupId == null
        ? null
        : ref.watch(conquestByGroupProvider(effectiveGroupId));

    if (!boundariesAsync.hasValue) {
      if (boundariesAsync.hasError) {
        return _buildRetry(() => ref.invalidate(sigBoundariesProvider));
      }
      return const Center(child: CircularProgressIndicator());
    }

    final boundaries = boundariesAsync.value!;

    if (conquestAsync != null && !conquestAsync.hasValue) {
      if (conquestAsync.hasError) {
        return _buildRetry(
          () => ref.invalidate(conquestByGroupProvider(effectiveGroupId!)),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    final conquestMap = conquestAsync?.value ?? const {};

    return Column(
      children: [
        if (conquestAsync?.hasError ?? false)
          _buildRetryBanner(
            () => ref.invalidate(conquestByGroupProvider(effectiveGroupId!)),
          ),
        if (conquestMap.isEmpty) _buildEmptyGroupBanner(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              _kMapHorizontalPadding,
              _kMapTopPadding,
              _kMapHorizontalPadding,
              _kMapBottomPadding,
            ),
            child: ConquestMapView(
              boundaries: boundaries,
              conquestBySggCode: conquestMap,
              onRegionTap: (boundary, summary) =>
                  _handleRegionTap(boundary, summary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyGroupBanner() {
    return const Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Text('첫 기록을 남겨보세요', style: TextStyle(color: MenlogColors.text)),
    );
  }

  Widget _buildRetryBanner(VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      color: MenlogColors.borderPrimaryFaint,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '최신 정보를 불러오지 못했어요',
              style: TextStyle(color: MenlogColors.dark),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('재시도')),
        ],
      ),
    );
  }

  Widget _buildRetry(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '지도를 불러오지 못했어요',
            style: TextStyle(color: MenlogColors.text),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: onRetry, child: const Text('재시도')),
        ],
      ),
    );
  }

  Future<void> _handleSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);
    final repository = ref.read(ramenShopSearchRepositoryProvider);
    final outcome = await repository.search(query: query);
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _searchResults = outcome.results;
    });
  }

  void _handleSearchResultTap(RamenShopSearchResult result) {
    setState(() => _searchResults = []);
    _searchController.clear();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RecordScreen(prefilledShopName: result.name),
      ),
    );
  }

  void _handleRegionTap(SigBoundary boundary, RegionConquestSummary? summary) {
    if (summary == null) {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: MenlogColors.background,
        builder: (context) => EmptyRegionBottomSheet(
          regionName: '${boundary.sidoName} ${boundary.sggName}',
          onRecordTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RecordScreen()),
            );
          },
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: MenlogColors.background,
      isScrollControlled: true,
      builder: (context) => RegionVisitBottomSheet(summary: summary),
    );
  }
}
