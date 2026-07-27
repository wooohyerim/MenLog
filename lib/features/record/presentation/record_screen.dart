import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

/// 기록하기 화면 임시 placeholder. 3.3절 기능 명세 구현 전까지의 스텁입니다.
///
/// 하단 탭바에서 push로 진입하므로 자체 AppBar(뒤로가기)를 가집니다.
/// 지도 탭의 미정복 지역 CTA/매장 검색 결과에서 매장 정보를 미리 채워
/// 넘겨줄 수 있도록 선택적 prefill 파라미터를 받는다.
class RecordScreen extends StatelessWidget {
  const RecordScreen({this.prefilledShopName, super.key});

  final String? prefilledShopName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenlogColors.background,
      appBar: AppBar(
        backgroundColor: MenlogColors.background,
        elevation: 0,
        title: const Text(
          '기록하기',
          style: TextStyle(color: MenlogColors.dark),
        ),
        iconTheme: const IconThemeData(color: MenlogColors.dark),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '기록하기 폼 (추후 연동 예정)',
              style: TextStyle(color: MenlogColors.text),
            ),
            _buildPrefilledShop(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefilledShop() {
    final shopName = prefilledShopName;
    if (shopName == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        '선택한 매장: $shopName',
        style: const TextStyle(color: MenlogColors.dark),
      ),
    );
  }
}
