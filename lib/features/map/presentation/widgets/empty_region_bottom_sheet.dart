import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

/// 미정복 지역을 탭했을 때 뜨는 바텀시트 — 기록 유도 CTA
/// (기획서 3.1 기능3).
class EmptyRegionBottomSheet extends StatelessWidget {
  const EmptyRegionBottomSheet({
    required this.regionName,
    required this.onRecordTap,
    super.key,
  });

  final String regionName;
  final VoidCallback onRecordTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              regionName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: MenlogColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '아직 기록이 없어요, 기록하러 가볼까요?',
              style: TextStyle(color: MenlogColors.text),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRecordTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MenlogColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('기록하러 가기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
