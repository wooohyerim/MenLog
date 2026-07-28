import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/group.dart';

const double _kChipSpacing = 8;

/// 방문 기록 공유 대상 그룹(개인 포함) 선택 칩. 기본값(어느 그룹을 먼저
/// 선택해두는지)은 지도 탭 그룹 서브탭과 동일하게 목록의 첫 번째 그룹을
/// 쓴다([RecordScreen] 참고) — 개인 그룹 여부를 구분하는 별도 플래그가
/// DB에 없기 때문이다.
class GroupShareSelector extends StatelessWidget {
  const GroupShareSelector({
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
    return Wrap(
      spacing: _kChipSpacing,
      runSpacing: _kChipSpacing,
      children: groups.map(_buildChip).toList(),
    );
  }

  Widget _buildChip(Group group) {
    final isSelected = group.id == selectedGroupId;

    return ChoiceChip(
      label: Text(group.name),
      selected: isSelected,
      onSelected: (_) => onSelect(group.id),
      selectedColor: MenlogColors.primary,
      backgroundColor: MenlogColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: MenlogColors.borderPrimarySoft,
          width: 0.5,
        ),
      ),
      labelStyle: TextStyle(color: _labelColor(isSelected)),
    );
  }

  Color _labelColor(bool isSelected) {
    if (isSelected) return Colors.white;
    return MenlogColors.text;
  }
}
