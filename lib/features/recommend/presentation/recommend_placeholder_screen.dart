import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/shared/widgets/menlog_header.dart';

/// 추천 탭 임시 화면. 3.5절 기능 명세 구현 전까지의 placeholder입니다.
class RecommendPlaceholderScreen extends StatelessWidget {
  const RecommendPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: MenlogColors.background,
      child: SafeArea(
        child: Column(
          children: [
            MenlogHeader(friendGroupMemberCount: 3),
            Expanded(
              child: Center(
                child: Text(
                  '추천 영역 (추후 연동 예정)',
                  style: TextStyle(color: MenlogColors.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
