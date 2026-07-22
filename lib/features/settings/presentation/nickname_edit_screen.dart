import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

/// 닉네임 수정 화면. 폼은 아직 준비되지 않아 placeholder만 보여줍니다.
class NicknameEditScreen extends StatelessWidget {
  const NicknameEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenlogColors.background,
      appBar: AppBar(
        backgroundColor: MenlogColors.background,
        title: const Text('닉네임 수정'),
      ),
      body: const Center(
        child: Text('준비 중이에요', style: TextStyle(color: MenlogColors.text)),
      ),
    );
  }
}
