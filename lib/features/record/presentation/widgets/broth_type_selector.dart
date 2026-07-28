import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/visit.dart';

const double _kChipSpacing = 8;

/// 국물 종류(선택) 칩 목록. `visits.broth_type`은 nullable이라 아무것도
/// 고르지 않은 상태([selected] == null)도 유효하다.
class BrothTypeSelector extends StatelessWidget {
  const BrothTypeSelector({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final BrothType? selected;
  final ValueChanged<BrothType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: _kChipSpacing,
      runSpacing: _kChipSpacing,
      children: BrothType.values.map(_buildChip).toList(),
    );
  }

  Widget _buildChip(BrothType brothType) {
    final isSelected = brothType == selected;

    return ChoiceChip(
      label: Text(_labelOf(brothType)),
      selected: isSelected,
      onSelected: (_) => _handleSelected(brothType, isSelected),
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

  void _handleSelected(BrothType brothType, bool isSelected) {
    if (isSelected) {
      onSelected(null);
      return;
    }
    onSelected(brothType);
  }

  Color _labelColor(bool isSelected) {
    if (isSelected) return Colors.white;
    return MenlogColors.text;
  }

  String _labelOf(BrothType brothType) {
    if (brothType == BrothType.tonkotsu) return '돈코츠';
    if (brothType == BrothType.shoyu) return '쇼유';
    if (brothType == BrothType.miso) return '미소';
    if (brothType == BrothType.shio) return '시오';
    return '츠케멘';
  }
}
