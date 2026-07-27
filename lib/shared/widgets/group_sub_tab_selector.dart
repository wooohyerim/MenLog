import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/group.dart';

const double _kTabHeight = 36;
const double _kTabSpacing = 8;
const double _kTabRadius = 18;

/// 그룹(개인 포함) 서브탭. 지도 탭 기능2, 피드 탭 기능1이 공유하는 패턴.
///
/// 그룹이 1개뿐이면(개인 그룹만 있는 경우) 불필요한 UI라 통째로 숨긴다.
class GroupSubTabSelector extends StatelessWidget {
  const GroupSubTabSelector({
    required this.groups,
    required this.selectedGroupId,
    required this.onSelect,
    super.key,
  });

  final List<Group> groups;
  final String? selectedGroupId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (groups.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: _kTabHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: groups.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: _kTabSpacing),
        itemBuilder: (context, index) => _buildTab(groups[index]),
      ),
    );
  }

  Widget _buildTab(Group group) {
    final isSelected = group.id == selectedGroupId;

    return ChoiceChip(
      label: Text(group.name),
      selected: isSelected,
      onSelected: (_) => onSelect(group.id),
      selectedColor: MenlogColors.primary,
      backgroundColor: MenlogColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kTabRadius),
        side: const BorderSide(
          color: MenlogColors.borderPrimarySoft,
          width: 0.5,
        ),
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : MenlogColors.text,
      ),
    );
  }
}
