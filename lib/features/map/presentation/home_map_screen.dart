import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/shared/widgets/menlog_header.dart';

const double _kSearchBarHeight = 34;
const double _kSearchBarRadius = 17;
const double _kSpacingSmall = 8;

/// 지도 탭 홈 화면 마크업.
///
/// 행정구역(시/군/구) 정복맵 방식으로 전환 예정이라 지도 영역은
/// placeholder 문구를 임시로 유지합니다.
class HomeMapScreen extends StatelessWidget {
  const HomeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MenlogColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const MenlogHeader(friendGroupMemberCount: 3),
            const SizedBox(height: _kSpacingSmall),
            _buildSearchField(),
            const SizedBox(height: _kSpacingSmall),
            Expanded(child: _buildMapPlaceholder()),
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
          decoration: InputDecoration(
            hintText: '가게 이름으로 검색',
            filled: true,
            fillColor: MenlogColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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

  Widget _buildMapPlaceholder() {
    return const ColoredBox(
      color: MenlogColors.mapPlaceholder,
      child: Center(
        child: Text(
          '지도 영역 (추후 연동 예정)',
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
