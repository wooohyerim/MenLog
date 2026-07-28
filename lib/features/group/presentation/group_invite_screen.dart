import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

/// 친구/그룹 관리 서브 화면(그룹 리스트 → 그룹 상세 → 초대 코드 공유,
/// 기획서 3.4절). 아직 구현 전이라 placeholder만 보여줍니다.
class GroupInviteScreen extends StatelessWidget {
  const GroupInviteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MenlogColors.background,
      appBar: AppBar(
        backgroundColor: MenlogColors.background,
        title: const Text('그룹 초대'),
      ),
      body: const Center(
        child: Text('준비 중이에요', style: TextStyle(color: MenlogColors.text)),
      ),
    );
  }
}
