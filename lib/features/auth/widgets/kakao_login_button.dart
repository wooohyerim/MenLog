import 'package:flutter/material.dart';
import 'package:menlog/core/constants/button_size.dart';
import 'package:menlog/features/auth/widgets/cropped_kakao_symbol.dart';

class KakaoLoginButton extends StatelessWidget {
  const KakaoLoginButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  static const Color _kakaoYellow = Color(0xFFFEE500);
  static const Color _kakaoTextColor = Color(0xFF191919);
  static const double _symbolTextGap = 0;
  static const double _borderRadius = 12;
  static const double _textFontSize = 18;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ButtonSize.loginButtonWidth,
      height: ButtonSize.loginButtonHeight,
      child: Material(
        color: _kakaoYellow,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: onPressed,
          child: const Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CroppedKakaoSymbol(),
                  SizedBox(width: _symbolTextGap),
                  Text(
                    '카카오톡으로 시작하기',
                    style: TextStyle(
                      color: _kakaoTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: _textFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
