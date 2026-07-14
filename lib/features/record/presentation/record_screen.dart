import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

/// 기록하기 화면 임시 placeholder. 3.3절 기능 명세 구현 전까지의 스텁입니다.
///
/// 하단 탭바에서 push로 진입하므로 자체 AppBar(뒤로가기)를 가집니다.
class RecordScreen extends StatelessWidget {
  const RecordScreen({super.key});

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
      body: const Center(
        child: Text(
          '기록하기 폼 (추후 연동 예정)',
          style: TextStyle(color: MenlogColors.text),
        ),
      ),
    );
  }
}
