import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/constants/tagline_style.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/widgets/google_login_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String _logoIconAsset = 'assets/icons/ramen_icon.png';
const double _logoIconSize = 180;
const double _logoIconGap = 0;
const double _taglineGap = 10;
const double _taglineWidth = 180;
const double _taglineTextPadding = 12;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.redirectPath = '/home'});

  final String redirectPath;

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
            const Align(alignment: Alignment(0, -0.6), child: _Wordmark()),
            Positioned(
              left: 24,
              right: 24,
              bottom: 160,
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
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoIcon(),
        SizedBox(height: _logoIconGap),
        Text(
          'MENLOG',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 6,
            color: Color(0xFF4A3222),
          ),
        ),
        SizedBox(height: _taglineGap),
        _Tagline(),
      ],
    );
  }
}

class _Tagline extends StatelessWidget {
  const _Tagline();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: _taglineWidth,
      child: Row(
        children: [
          Expanded(
            child: Divider(color: TaglineStyle.dividerColor, thickness: 1),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _taglineTextPadding),
            child: Text(
              '라멘 기록 서비스',
              style: TextStyle(
                fontSize: TaglineStyle.fontSize,
                color: TaglineStyle.textColor,
                letterSpacing: 1,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: TaglineStyle.dividerColor, thickness: 1),
          ),
        ],
      ),
    );
  }
}

class _LogoIcon extends StatelessWidget {
  const _LogoIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _logoIconAsset,
      width: _logoIconSize,
      height: _logoIconSize,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('로고 아이콘을 찾을 수 없어요: $_logoIconAsset, $error');
        return const SizedBox(width: _logoIconSize, height: _logoIconSize);
      },
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
