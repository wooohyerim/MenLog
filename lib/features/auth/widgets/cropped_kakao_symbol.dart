import 'package:flutter/material.dart';

/// 카카오 로그인 버튼(assets/icons/kakao_login_button.png)에서 말풍선
/// 로고만 잘라 보여줍니다. 별도 심볼 이미지가 없어 기존 버튼 이미지의
/// 좌측 정사각형 영역만 노출하는 방식으로 크롭합니다.
class CroppedKakaoSymbol extends StatelessWidget {
  const CroppedKakaoSymbol({super.key});

  static const double _symbolSize = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _symbolSize,
      height: _symbolSize,
      child: Image.asset(
        'assets/icons/kakao_login_button.png',
        fit: BoxFit.fitHeight,
        alignment: Alignment.centerLeft,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('카카오 심볼 이미지 로드 실패: $error');
          return Container(color: Colors.grey.shade300);
        },
      ),
    );
  }
}
