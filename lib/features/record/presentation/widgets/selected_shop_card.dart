import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/features/record/presentation/selected_shop.dart';

const double _kCardRadius = 12;
const double _kCardPadding = 12;

/// 매장 선택을 마친 뒤, 검색창 대신 보여주는 요약 카드. "매장 변경"으로
/// 다시 검색 상태로 되돌아갈 수 있다.
class SelectedShopCard extends StatelessWidget {
  const SelectedShopCard({
    required this.shop,
    required this.onChangeTap,
    super.key,
  });

  final SelectedShop shop;
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_kCardPadding),
      decoration: BoxDecoration(
        color: MenlogColors.surface,
        borderRadius: BorderRadius.circular(_kCardRadius),
        border: Border.all(color: MenlogColors.borderPrimarySoft),
      ),
      child: Row(
        children: [
          Expanded(child: _buildInfo()),
          TextButton(onPressed: onChangeTap, child: const Text('매장 변경')),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.name,
          style: const TextStyle(
            color: MenlogColors.dark,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (shop.address != null) _buildAddress(shop.address!),
      ],
    );
  }

  Widget _buildAddress(String address) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(address, style: const TextStyle(color: MenlogColors.text)),
    );
  }
}
