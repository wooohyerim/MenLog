import 'package:flutter/material.dart';

import 'package:menlog/core/navigation/menlog_tab.dart';
import 'package:menlog/core/theme/menlog_colors.dart';

const double _kNavBarHeight = 64;
const double _kIconSize = 22;
const double _kLabelFontSize = 11;
const double _kLabelSpacing = 2;

/// 하단 탭바 마크업 (지도/피드/기록/추천).
///
/// [onRecordTap]은 기록 탭 전용 콜백이고, 나머지 3개 탭은 [onTabSelected]로
/// 처리됩니다.
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
          children: MenlogTab.values.map(_buildTabItem).toList(),
        ),
      ),
    );
  }

  Widget _buildTabItem(MenlogTab tab) {
    return Expanded(
      child: _MenlogNavItem(
        tab: tab,
        isSelected: tab == currentTab,
        onTap: () => _handleTap(tab),
      ),
    );
  }

  void _handleTap(MenlogTab tab) {
    if (tab.isAction) {
      onRecordTap();
      return;
    }
    onTabSelected(tab);
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
