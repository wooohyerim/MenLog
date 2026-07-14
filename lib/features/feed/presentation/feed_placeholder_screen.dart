import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/shared/widgets/menlog_header.dart';

/// 피드 탭 임시 화면. 3.2절 기능 명세 구현 전까지의 placeholder입니다.
class FeedPlaceholderScreen extends StatelessWidget {
  const FeedPlaceholderScreen({super.key});

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
                  '피드 영역 (추후 연동 예정)',
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
