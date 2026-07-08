import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/auth_provider.dart';

const int _nicknameMaxLength = 12;

class NicknameSetupScreen extends ConsumerStatefulWidget {
  const NicknameSetupScreen({super.key});

  @override
  ConsumerState<NicknameSetupScreen> createState() =>
      _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends ConsumerState<NicknameSetupScreen> {
  late final TextEditingController _controller;
  String? _errorText;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = ref.read(currentUserProvider);
    final metadata = user?.userMetadata;
    final defaultName =
        metadata?['full_name'] as String? ?? metadata?['name'] as String?;

    _controller = TextEditingController(text: defaultName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> handleConfirm() async {
    final nickname = _controller.text.trim();

    if (nickname.isEmpty) {
      setState(() => _errorText = '닉네임을 입력해주세요');
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _errorText = null;
      _isSaving = true;
    });

    try {
      await authRepository.upsertUser(
        userId: user.id,
        nickname: nickname,
        email: user.email,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      debugPrint('닉네임 저장 에러: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('저장에 실패했어요. 다시 시도해주세요')));
    }
  }

  VoidCallback? get _onConfirmPressed {
    if (_isSaving) return null;
    return handleConfirm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('닉네임 설정')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '친구에게 보여질 이름이에요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLength: _nicknameMaxLength,
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요',
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onConfirmPressed,
                child: _ConfirmButtonContent(isSaving: _isSaving),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButtonContent extends StatelessWidget {
  const _ConfirmButtonContent({required this.isSaving});

  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    if (isSaving) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return const Text('확인');
  }
}
