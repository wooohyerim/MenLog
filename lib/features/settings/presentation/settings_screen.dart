import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/auth_provider.dart';
import 'package:menlog/features/settings/presentation/nickname_edit_screen.dart';
import 'package:menlog/features/settings/presentation/notification_settings_screen.dart';

const double _kWordmarkFontSize = 19;
const double _kWordmarkLetterSpacing = 2;
const double _kNicknameFontSize = 28;
const double _kListRowFontSize = 16;
const double _kListRowHorizontalPadding = 24;
const double _kListRowVerticalPadding = 16;
const double _kActionsFontSize = 15;
const double _kActionsGap = 12;
const Color _kActionsDividerColor = Color(0xFFC9B696);
const Color _kWithdrawalColor = Color(0xFFF0997B);
const String _kWithdrawalConfirmText = '안내사항을 확인했습니다';
const double _kDialogBorderRadius = 20;
const double _kDialogPadding = 24;
const double _kDialogTitleFontSize = 18;
const double _kDialogButtonHeight = 44;
const double _kDialogButtonRadius = 12;
const double _kDialogButtonGap = 12;

/// 설정 탭 화면. 닉네임 표시, 닉네임 수정/알림 설정 진입, 로그아웃/회원탈퇴를 제공합니다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return ColoredBox(
      color: MenlogColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SettingsHeader(),
            const SizedBox(height: 48),
            _NicknameText(profileAsync: profileAsync),
            const SizedBox(height: 24),
            _SettingsListRow(
              label: '닉네임 수정',
              onTap: () => _openScreen(context, const NicknameEditScreen()),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              indent: _kListRowHorizontalPadding,
              endIndent: _kListRowHorizontalPadding,
              color: MenlogColors.borderPrimaryFaint,
            ),
            _SettingsListRow(
              label: '알림 설정',
              onTap: () =>
                  _openScreen(context, const NotificationSettingsScreen()),
            ),
            const Spacer(),
            _AccountActionsRow(
              onLogoutTap: () => _handleLogout(context),
              onWithdrawalTap: () => _handleWithdrawal(context, ref),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await _showConfirmDialog(
      context,
      title: '로그아웃',
      message: '로그아웃 하시겠어요?',
      confirmLabel: '확인',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    try {
      await authRepository.signOut();
    } catch (e, stackTrace) {
      debugPrint('로그아웃 실패: $e\n$stackTrace');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그아웃 중 오류가 발생했어요')));
    }
  }

  Future<void> _handleWithdrawal(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showWithdrawalConfirmDialog(context);
    if (!confirmed) return;
    if (!context.mounted) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await authRepository.deleteAccount(user.id);
    } catch (e, stackTrace) {
      debugPrint('회원탈퇴 실패: $e\n$stackTrace');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('회원탈퇴 중 오류가 발생했어요')));
      return;
    }

    if (!context.mounted) return;
    await _showCompletionDialog(context);

    await authRepository.signOut();
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return _MenlogDialogShell(
          title: title,
          content: Text(
            message,
            style: const TextStyle(color: MenlogColors.text),
          ),
          secondaryAction: _DialogOutlineButton(
            label: '취소',
            onTap: () => Navigator.of(dialogContext).pop(false),
          ),
          primaryAction: _DialogFilledButton(
            label: confirmLabel,
            color: MenlogColors.primary,
            onTap: () => Navigator.of(dialogContext).pop(true),
          ),
        );
      },
    );

    if (result == null) return false;
    return result;
  }

  Future<bool> _showWithdrawalConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => const _WithdrawalConfirmDialog(),
    );

    if (result == null) return false;
    return result;
  }

  Future<void> _showCompletionDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return _MenlogDialogShell(
          title: '회원탈퇴 완료',
          content: const Text(
            '회원탈퇴가 완료되었습니다. 그동안 이용해주셔서 감사합니다.',
            style: TextStyle(color: MenlogColors.text),
          ),
          primaryAction: _DialogFilledButton(
            label: '확인',
            color: MenlogColors.primary,
            onTap: () => Navigator.of(dialogContext).pop(),
          ),
        );
      },
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'MENLOG',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: _kWordmarkFontSize,
            letterSpacing: _kWordmarkLetterSpacing,
            color: MenlogColors.dark,
          ),
        ),
      ),
    );
  }
}

class _NicknameText extends StatelessWidget {
  const _NicknameText({required this.profileAsync});

  final AsyncValue<Map<String, dynamic>?> profileAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _kListRowHorizontalPadding,
      ),
      child: profileAsync.when(
        loading: () => const _NicknameLabel(text: '불러오는 중'),
        error: (_, _) => const _NicknameLabel(text: '닉네임을 불러오지 못했어요'),
        data: (profile) {
          final nickname = profile?['nickname'] as String?;
          return _NicknameLabel(text: nickname ?? '닉네임 없음');
        },
      ),
    );
  }
}

class _NicknameLabel extends StatelessWidget {
  const _NicknameLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: _kNicknameFontSize,
        fontWeight: FontWeight.w600,
        color: MenlogColors.dark,
      ),
    );
  }
}

class _SettingsListRow extends StatelessWidget {
  const _SettingsListRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _kListRowHorizontalPadding,
          vertical: _kListRowVerticalPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: _kListRowFontSize,
                color: MenlogColors.text,
              ),
            ),
            const Icon(Icons.chevron_right, color: MenlogColors.text),
          ],
        ),
      ),
    );
  }
}

class _AccountActionsRow extends StatelessWidget {
  const _AccountActionsRow({
    required this.onLogoutTap,
    required this.onWithdrawalTap,
  });

  final VoidCallback onLogoutTap;
  final VoidCallback onWithdrawalTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onLogoutTap,
          child: const Text(
            '로그아웃',
            style: TextStyle(
              fontSize: _kActionsFontSize,
              color: MenlogColors.text,
            ),
          ),
        ),
        const SizedBox(width: _kActionsGap),
        const Text(
          '/',
          style: TextStyle(
            fontSize: _kActionsFontSize,
            color: _kActionsDividerColor,
          ),
        ),
        const SizedBox(width: _kActionsGap),
        GestureDetector(
          onTap: onWithdrawalTap,
          child: const Text(
            '회원탈퇴',
            style: TextStyle(
              fontSize: _kActionsFontSize,
              color: _kWithdrawalColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _WithdrawalConfirmDialog extends StatefulWidget {
  const _WithdrawalConfirmDialog();

  @override
  State<_WithdrawalConfirmDialog> createState() =>
      _WithdrawalConfirmDialogState();
}

class _WithdrawalConfirmDialogState extends State<_WithdrawalConfirmDialog> {
  final _controller = TextEditingController();
  bool _isMatched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    setState(() => _isMatched = value.trim() == _kWithdrawalConfirmText);
  }

  VoidCallback? get _onConfirmPressed {
    if (!_isMatched) return null;
    return () => Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _MenlogDialogShell(
      title: '회원탈퇴',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '탈퇴하면 작성한 방문 기록, 좋아요, 댓글이 모두 삭제되고 복구할 수 없어요.',
            style: TextStyle(color: MenlogColors.text),
          ),
          const SizedBox(height: 16),
          const Text(
            '계속하려면 "$_kWithdrawalConfirmText"을(를) 입력해주세요',
            style: TextStyle(color: MenlogColors.text),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            onChanged: _handleChanged,
            style: const TextStyle(color: MenlogColors.dark),
            decoration: const InputDecoration(
              hintText: _kWithdrawalConfirmText,
              hintStyle: TextStyle(color: MenlogColors.borderPrimarySoft),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MenlogColors.borderPrimarySoft),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MenlogColors.primary),
              ),
            ),
          ),
        ],
      ),
      secondaryAction: _DialogOutlineButton(
        label: '취소',
        onTap: () => Navigator.of(context).pop(false),
      ),
      primaryAction: _DialogFilledButton(
        label: '탈퇴하기',
        color: _kWithdrawalColor,
        onTap: _onConfirmPressed,
      ),
    );
  }
}

/// 크래프트지 톤에 맞춘 공용 다이얼로그 셸. 제목 + 본문 + 버튼 1~2개로 구성됩니다.
class _MenlogDialogShell extends StatelessWidget {
  const _MenlogDialogShell({
    required this.title,
    required this.content,
    required this.primaryAction,
    this.secondaryAction,
  });

  final String title;
  final Widget content;
  final Widget primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_kDialogBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_kDialogPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: _kDialogTitleFontSize,
                fontWeight: FontWeight.w700,
                color: MenlogColors.dark,
              ),
            ),
            const SizedBox(height: 12),
            content,
            const SizedBox(height: 20),
            _buildActionsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsRow() {
    final secondary = secondaryAction;
    if (secondary == null) {
      return Row(children: [Expanded(child: primaryAction)]);
    }

    return Row(
      children: [
        Expanded(child: secondary),
        const SizedBox(width: _kDialogButtonGap),
        Expanded(child: primaryAction),
      ],
    );
  }
}

class _DialogOutlineButton extends StatelessWidget {
  const _DialogOutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kDialogButtonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: MenlogColors.text,
          side: const BorderSide(color: MenlogColors.borderPrimarySoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kDialogButtonRadius),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _DialogFilledButton extends StatelessWidget {
  const _DialogFilledButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kDialogButtonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_kDialogButtonRadius),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
