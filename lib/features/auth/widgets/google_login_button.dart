import 'package:flutter/material.dart';
import 'package:menlog/core/constants/button_size.dart';
import 'package:menlog/features/auth/widgets/cropped_google_symbol.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  static const double _symbolLeftPadding = 14;
  static const double _borderRadius = 6;
  static const double _textFontSize = 19;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ButtonSize.loginButtonWidth,
      height: ButtonSize.loginButtonHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_borderRadius),
          onTap: onPressed,
          child: const Row(
            children: [
              SizedBox(width: _symbolLeftPadding),
              CroppedGoogleSymbol(),
              Expanded(
                child: Center(
                  child: Text(
                    'Google 로그인',
                    style: TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      fontSize: _textFontSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
