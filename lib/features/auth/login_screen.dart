import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with WidgetsBindingObserver {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_isLoading) return;

    setState(() => _isLoading = false);
  }

  Future<void> handleKakaoLogin() async {
    setState(() => _isLoading = true);

    try {
      await authRepository.signInWithKakao();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('로그인 중 오류가 발생했어요');
    }
  }

  Future<void> handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      await authRepository.signInWithGoogle();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('로그인 중 오류가 발생했어요');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEDE0CC),
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: _Wordmark()),
            Positioned(
              left: 24,
              right: 24,
              bottom: 48,
              child: _LoginButtons(
                isLoading: _isLoading,
                onKakaoTap: handleKakaoLogin,
                onGoogleTap: handleGoogleLogin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'MENLOG',
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 40,
        fontWeight: FontWeight.bold,
        letterSpacing: 6,
        color: Color(0xFF4A3222),
      ),
    );
  }
}

class _LoginButtons extends StatelessWidget {
  const _LoginButtons({
    required this.isLoading,
    required this.onKakaoTap,
    required this.onGoogleTap,
  });

  final bool isLoading;
  final VoidCallback onKakaoTap;
  final VoidCallback onGoogleTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OAuthButton(
          label: '카카오로 시작하기',
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: const Color(0xFF191919),
          isLoading: isLoading,
          onTap: onKakaoTap,
        ),
        const SizedBox(height: 12),
        _OAuthButton(
          label: 'Google로 시작하기',
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF191919),
          borderColor: const Color(0xFFDADCE0),
          isLoading: isLoading,
          onTap: onGoogleTap,
        ),
      ],
    );
  }
}

class _OAuthButton extends StatelessWidget {
  const _OAuthButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isLoading,
    required this.onTap,
    this.borderColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isLoading;
  final VoidCallback onTap;

  VoidCallback? get _onPressed {
    if (isLoading) return null;
    return onTap;
  }

  BorderSide get _side {
    final color = borderColor;
    if (color == null) return BorderSide.none;
    return BorderSide(color: color);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: _side,
          ),
        ),
        child: _OAuthButtonContent(label: label, isLoading: isLoading),
      ),
    );
  }
}

class _OAuthButtonContent extends StatelessWidget {
  const _OAuthButtonContent({required this.label, required this.isLoading});

  final String label;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Text(label, style: const TextStyle(fontWeight: FontWeight.w600));
  }
}
