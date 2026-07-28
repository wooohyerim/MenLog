import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/group.dart';
import 'package:menlog/data/models/ramen_shop_search_result.dart';
import 'package:menlog/data/models/visit.dart';
import 'package:menlog/data/repositories/group_repository_provider.dart';
import 'package:menlog/data/repositories/ramen_shop_search_repository_provider.dart';
import 'package:menlog/data/repositories/visit_repository_provider.dart';
import 'package:menlog/features/auth/auth_provider.dart';
import 'package:menlog/features/record/presentation/selected_shop.dart';
import 'package:menlog/features/record/presentation/widgets/broth_type_selector.dart';
import 'package:menlog/features/record/presentation/widgets/group_share_selector.dart';
import 'package:menlog/features/record/presentation/widgets/manual_shop_form.dart';
import 'package:menlog/features/record/presentation/widgets/media_picker_field.dart';
import 'package:menlog/features/record/presentation/widgets/selected_shop_card.dart';
import 'package:menlog/features/record/presentation/widgets/shop_search_section.dart';
import 'package:menlog/features/record/presentation/widgets/star_rating_input.dart';

const double _kSectionGap = 24;
const double _kFieldGap = 12;
const double _kBottomBarHeight = 64;

/// 기록하기(+) 화면 — 기획서 3.3절.
///
/// 매장 검색(또는 수동 등록) → 사진/영상 첨부 → 국물 종류/평점/메모 →
/// 공유 대상 그룹 선택 → 저장 순서로 진행한다. [prefilledShop]이 주어지면
/// (지도 탭 검색 결과 탭 등에서 진입) 매장 검색 단계를 건너뛴다.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({this.prefilledShop, super.key});

  final RamenShopSearchResult? prefilledShop;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  List<RamenShopSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _hasSearchError = false;
  bool _showManualEntry = false;

  SelectedShop? _selectedShop;
  PickedMedia? _pickedMedia;
  BrothType? _brothType;
  int _rating = 0;
  String? _selectedGroupId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final prefilled = widget.prefilledShop;
    if (prefilled != null) {
      _selectedShop = SelectedShop.fromSearchResult(prefilled);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      backgroundColor: MenlogColors.background,
      appBar: AppBar(
        backgroundColor: MenlogColors.background,
        elevation: 0,
        title: const Text('기록하기', style: TextStyle(color: MenlogColors.dark)),
        iconTheme: const IconThemeData(color: MenlogColors.dark),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionLabel('매장', isRequired: true),
              const SizedBox(height: _kFieldGap),
              _buildShopSection(),
              const SizedBox(height: _kSectionGap),
              _buildSectionLabel('사진/영상', isRequired: true),
              const SizedBox(height: _kFieldGap),
              MediaPickerField(
                picked: _pickedMedia,
                onChanged: (media) => setState(() => _pickedMedia = media),
              ),
              const SizedBox(height: _kSectionGap),
              _buildSectionLabel('국물 종류'),
              const SizedBox(height: _kFieldGap),
              BrothTypeSelector(
                selected: _brothType,
                onSelected: (brothType) =>
                    setState(() => _brothType = brothType),
              ),
              const SizedBox(height: _kSectionGap),
              _buildSectionLabel('평점', isRequired: true),
              const SizedBox(height: _kFieldGap),
              StarRatingInput(
                rating: _rating,
                onChanged: (rating) => setState(() => _rating = rating),
              ),
              const SizedBox(height: _kSectionGap),
              _buildSectionLabel('메모'),
              const SizedBox(height: _kFieldGap),
              TextField(
                controller: _memoController,
                maxLines: 4,
                style: const TextStyle(color: MenlogColors.dark),
                decoration: const InputDecoration(hintText: '메모를 남겨보세요'),
              ),
              const SizedBox(height: _kSectionGap),
              _buildSectionLabel('공유 대상'),
              const SizedBox(height: _kFieldGap),
              _buildGroupSection(groupsAsync),
              const SizedBox(height: _kSectionGap),
              _buildSaveButton(groupsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MenlogColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) _buildRequiredMark(),
      ],
    );
  }

  Widget _buildRequiredMark() {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        '*',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildShopSection() {
    final shop = _selectedShop;
    if (shop != null) {
      return SelectedShopCard(shop: shop, onChangeTap: _handleChangeShop);
    }

    if (_showManualEntry) {
      return ManualShopForm(
        onSubmit: _handleManualSubmit,
        onCancel: () => setState(() => _showManualEntry = false),
      );
    }

    return ShopSearchSection(
      controller: _searchController,
      isSearching: _isSearching,
      hasSearched: _hasSearched,
      hasError: _hasSearchError,
      results: _searchResults,
      onChanged: _handleSearchChanged,
      onResultTap: _handleResultTap,
      onManualEntryTap: () => setState(() => _showManualEntry = true),
    );
  }

  Widget _buildGroupSection(AsyncValue<List<Group>> groupsAsync) {
    return groupsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text(
        '그룹 정보를 불러오지 못했어요',
        style: TextStyle(color: MenlogColors.text),
      ),
      data: (groups) => _buildGroupChips(groups),
    );
  }

  Widget _buildGroupChips(List<Group> groups) {
    if (groups.isEmpty) {
      return const Text(
        '공유할 그룹이 없어요',
        style: TextStyle(color: MenlogColors.text),
      );
    }

    return GroupShareSelector(
      groups: groups,
      selectedGroupId: _selectedGroupId ?? groups.first.id,
      onSelect: (groupId) => setState(() => _selectedGroupId = groupId),
    );
  }

  Widget _buildSaveButton(AsyncValue<List<Group>> groupsAsync) {
    final effectiveGroupId = _resolveGroupId(groupsAsync);

    return SizedBox(
      height: _kBottomBarHeight,
      child: ElevatedButton(
        onPressed: _canSave(effectiveGroupId)
            ? () => _handleSave(effectiveGroupId!)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: MenlogColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildSaveButtonLabel(),
      ),
    );
  }

  Widget _buildSaveButtonLabel() {
    if (_isSaving) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    return const Text('저장');
  }

  String? _resolveGroupId(AsyncValue<List<Group>> groupsAsync) {
    final groups = groupsAsync.valueOrNull;
    if (groups == null || groups.isEmpty) return null;
    return _selectedGroupId ?? groups.first.id;
  }

  bool _canSave(String? effectiveGroupId) {
    if (_isSaving) return false;
    if (_selectedShop == null) return false;
    if (_pickedMedia == null) return false;
    if (_rating <= 0) return false;
    if (effectiveGroupId == null) return false;
    return true;
  }

  void _handleChangeShop() {
    setState(() => _selectedShop = null);
  }

  Future<void> _handleSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _hasSearchError = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final repository = ref.read(ramenShopSearchRepositoryProvider);
    final outcome = await repository.search(query: query);
    if (!mounted) return;

    setState(() {
      _isSearching = false;
      _hasSearched = true;
      _hasSearchError = outcome.hasError;
      _searchResults = outcome.results;
    });
  }

  void _handleResultTap(RamenShopSearchResult result) {
    _searchController.clear();
    setState(() {
      _selectedShop = SelectedShop.fromSearchResult(result);
      _searchResults = [];
      _hasSearched = false;
      _hasSearchError = false;
    });
  }

  void _handleManualSubmit(String name, String address) {
    setState(() {
      _selectedShop = SelectedShop.manual(
        name: name,
        address: address,
        syntheticPlaceId: 'manual_${DateTime.now().microsecondsSinceEpoch}',
      );
      _showManualEntry = false;
    });
  }

  Future<void> _handleSave(String groupId) async {
    final shop = _selectedShop;
    final media = _pickedMedia;
    if (shop == null || media == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final coordinates = await _resolveCoordinates(shop);
      final visitRepository = ref.read(visitRepositoryProvider);

      final ramenShop = await visitRepository.upsertShop(
        googlePlaceId: shop.googlePlaceId,
        name: shop.name,
        address: shop.address,
        lat: coordinates.$1,
        lng: coordinates.$2,
      );

      final uploadResult = await visitRepository.uploadMedia(
        userId: user.id,
        file: media.file,
        mediaType: media.mediaType,
      );

      final memo = _memoController.text.trim();

      await visitRepository.createVisit(
        shopId: ramenShop.id,
        groupId: groupId,
        userId: user.id,
        mediaUrl: uploadResult.mediaUrl,
        mediaType: media.mediaType,
        thumbnailUrl: uploadResult.thumbnailUrl,
        rating: _rating,
        brothType: _brothType,
        memo: _normalizeMemo(memo),
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e, stackTrace) {
      debugPrint('방문 기록 저장 실패: $e\n$stackTrace');
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장에 실패했어요. 다시 시도해주세요')));
    }
  }

  String? _normalizeMemo(String memo) {
    if (memo.isEmpty) return null;
    return memo;
  }

  Future<(double, double)> _resolveCoordinates(SelectedShop shop) async {
    final lat = shop.lat;
    final lng = shop.lng;
    if (lat != null && lng != null) return (lat, lng);

    final address = shop.address;
    if (address == null) return (0.0, 0.0);

    final geocodingRepository = ref.read(geocodingRepositoryProvider);
    final result = await geocodingRepository.geocode(address);
    if (result == null) return (0.0, 0.0);
    return (result.lat, result.lng);
  }
}
