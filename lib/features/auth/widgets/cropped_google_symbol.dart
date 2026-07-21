import 'package:flutter/material.dart';

class CroppedGoogleSymbol extends StatelessWidget {
  const CroppedGoogleSymbol({super.key});

  static const double _symbolSize = 30;
  static const double _symbolScaleFactor = 1.55;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: _symbolSize,
        height: _symbolSize,
        child: Transform.scale(
          scale: _symbolScaleFactor,
          child: Image.asset(
            'assets/icons/google_symbol.png',
            errorBuilder: (context, error, stackTrace) {
              debugPrint('구글 심볼 이미지 로드 실패: $error');
              return Container(color: Colors.grey.shade300);
            },
          ),
        ),
      ),
    );
  }
}
