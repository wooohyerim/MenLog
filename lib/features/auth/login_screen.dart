import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/widgets/google_login_button.dart';
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

const double _buttonWidth = 240;
const double _buttonGap = 12;
const double _kakaoButtonAspectRatio = 366 / 90;

class _LoginButtons extends StatelessWidget {
  const _LoginButtons({
    required this.isLoading,
    required this.onKakaoTap,
    required this.onGoogleTap,
  });

  final bool isLoading;
  final VoidCallback onKakaoTap;
  final VoidCallback onGoogleTap;

  VoidCallback? get _onGoogleTap {
    if (isLoading) return null;
    return onGoogleTap;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _OAuthImageButton(
          assetName: 'assets/icons/kakao_login_button.png',
          aspectRatio: _kakaoButtonAspectRatio,
          isLoading: isLoading,
          onTap: onKakaoTap,
        ),
        const SizedBox(height: _buttonGap),
        GoogleLoginButton(onPressed: _onGoogleTap),
      ],
    );
  }
}

class _OAuthImageButton extends StatelessWidget {
  const _OAuthImageButton({
    required this.assetName,
    required this.aspectRatio,
    required this.isLoading,
    required this.onTap,
  });

  final String assetName;
  final double aspectRatio;
  final bool isLoading;
  final VoidCallback onTap;

  VoidCallback? get _onTap {
    if (isLoading) return null;
    return onTap;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: SizedBox(
        width: _buttonWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.asset(
            assetName,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('이미지 로드 실패: $assetName, $error');
              return const _ImagePlaceholder();
            },
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.grey.shade300);
  }
}
