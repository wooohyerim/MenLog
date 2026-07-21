import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/shared/widgets/menlog_header.dart';

const double _kLogoutButtonWidth = 160;
const double _kLogoutButtonHeight = 44;
const double _kLogoutButtonRadius = 12;

/// 설정 탭 화면. 프로필/알림 등 정식 설정 항목이 생기기 전까지는
/// 로그아웃 버튼만 임시로 제공합니다.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MenlogColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const MenlogHeader(friendGroupMemberCount: 3),
            Expanded(
              child: Center(
                child: _LogoutButton(onTap: () => _handleLogout(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await authRepository.signOut();
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그아웃 중 오류가 발생했어요')));
    }
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kLogoutButtonWidth,
      height: _kLogoutButtonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: MenlogColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kLogoutButtonRadius),
          ),
        ),
        child: const Text('로그아웃 (임시)'),
      ),
    );
  }
}
