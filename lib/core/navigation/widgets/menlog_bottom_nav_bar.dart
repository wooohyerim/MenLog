import 'package:flutter/material.dart';

import 'package:menlog/core/navigation/menlog_tab.dart';
import 'package:menlog/core/theme/menlog_colors.dart';

const double _kNavBarHeight = 64;
const double _kIconSize = 22;
const double _kLabelFontSize = 11;
const double _kLabelSpacing = 2;
const double _kRecordButtonDiameter = 40;

/// 하단 탭바 마크업 (지도/피드/기록/추천/설정).
///
/// 기록하기는 [MenlogTab]에 속하지 않는 별도 액션이라 탭 목록 중앙에
/// 동그란 버튼으로 끼워 넣습니다.
class MenlogBottomNavBar extends StatelessWidget {
  const MenlogBottomNavBar({
    required this.currentTab,
    required this.onTabSelected,
    required this.onRecordTap,
    super.key,
  });

  final MenlogTab currentTab;
  final ValueChanged<MenlogTab> onTabSelected;
  final VoidCallback onRecordTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: MenlogColors.surface,
        border: Border(
          top: BorderSide(color: MenlogColors.borderPrimaryFaint, width: 0.5),
        ),
      ),
      child: SizedBox(
        height: _kNavBarHeight,
        child: Row(
          children: [
            _buildTabItem(MenlogTab.map),
            _buildTabItem(MenlogTab.feed),
            _buildRecordItem(),
            _buildTabItem(MenlogTab.recommend),
            _buildTabItem(MenlogTab.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(MenlogTab tab) {
    return Expanded(
      child: _MenlogNavItem(
        tab: tab,
        isSelected: tab == currentTab,
        onTap: () => onTabSelected(tab),
      ),
    );
  }

  Widget _buildRecordItem() {
    return Expanded(
      child: Center(child: _RecordButton(onTap: onRecordTap)),
    );
  }
}

/// 하단 탭바 중앙에 끼워지는 동그란 "기록하기" 버튼.
class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MenlogColors.primary,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: _kRecordButtonDiameter,
          height: _kRecordButtonDiameter,
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _MenlogNavItem extends StatelessWidget {
  const _MenlogNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final MenlogTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(tab.icon, size: _kIconSize, color: _resolveColor()),
          const SizedBox(height: _kLabelSpacing),
          Text(
            tab.label,
            style: TextStyle(fontSize: _kLabelFontSize, color: _resolveColor()),
          ),
        ],
      ),
    );
  }

  Color _resolveColor() {
    if (isSelected) return MenlogColors.primary;
    return MenlogColors.text;
  }
}
