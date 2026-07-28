import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/ramen_shop_search_result.dart';

const double _kSearchBarHeight = 44;
const double _kSearchBarRadius = 12;
const double _kResultsMaxHeight = 280;
const double _kBadgeRadius = 6;

/// 매장 이름 검색창 + 결과 리스트. 지도 탭 위치 UI는 쓰지 않고 Places
/// Autocomplete 텍스트 검색만 제공한다(기획서 3.3절).
class ShopSearchSection extends StatelessWidget {
  const ShopSearchSection({
    required this.controller,
    required this.isSearching,
    required this.hasSearched,
    required this.hasError,
    required this.results,
    required this.onChanged,
    required this.onResultTap,
    required this.onManualEntryTap,
    super.key,
  });

  final TextEditingController controller;
  final bool isSearching;
  final bool hasSearched;
  final bool hasError;
  final List<RamenShopSearchResult> results;
  final ValueChanged<String> onChanged;
  final ValueChanged<RamenShopSearchResult> onResultTap;
  final VoidCallback onManualEntryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_buildSearchField(), const SizedBox(height: 8), _buildBody()],
    );
  }

  Widget _buildSearchField() {
    return SizedBox(
      height: _kSearchBarHeight,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: MenlogColors.dark),
        decoration: InputDecoration(
          hintText: '매장 이름으로 검색',
          filled: true,
          fillColor: MenlogColors.surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_kSearchBarRadius),
            borderSide: const BorderSide(
              color: MenlogColors.borderPrimarySoft,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (!isSearching) return null;
    return _buildSpinner();
  }

  Widget _buildSpinner() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildBody() {
    if (results.isNotEmpty) return _buildResultsList();
    if (!hasSearched || isSearching) return const SizedBox.shrink();
    if (hasError) return _buildErrorState();
    return _buildEmptyState();
  }

  Widget _buildResultsList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: _kResultsMaxHeight),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: results.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => _buildResultTile(results[index]),
      ),
    );
  }

  Widget _buildResultTile(RamenShopSearchResult result) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Flexible(
            child: Text(
              result.name,
              style: const TextStyle(color: MenlogColors.dark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (result.isRegistered) _buildRegisteredBadge(),
        ],
      ),
      subtitle: _buildAddressSubtitle(result.address),
      onTap: () => onResultTap(result),
    );
  }

  Widget? _buildAddressSubtitle(String? address) {
    if (address == null) return null;
    return Text(address, style: const TextStyle(color: MenlogColors.text));
  }

  Widget _buildRegisteredBadge() {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: MenlogColors.badge,
          borderRadius: BorderRadius.circular(_kBadgeRadius),
        ),
        child: const Text(
          '등록됨',
          style: TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text('검색 결과가 없어요', style: TextStyle(color: MenlogColors.text)),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onManualEntryTap,
            child: const Text('직접 입력하기'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text(
            '검색에 실패했어요. 다시 시도해주세요',
            style: TextStyle(color: MenlogColors.text),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onManualEntryTap,
            child: const Text('직접 입력하기'),
          ),
        ],
      ),
    );
  }
}
