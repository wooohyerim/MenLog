# 구글 커스텀 로그인 버튼 제작 (심볼 테두리 제거 + 카카오 버튼 높이 통일)

CLAUDE.md의 코드 스타일 규칙(early return, 삼항연산자 금지, else if 금지, const 상수 분리)을 반드시 지켜서 작성해줘.

---

## 배경

- 카카오 로그인 버튼: `assets/icons/` 안의 기존 완성형 이미지 파일을 그대로 사용 (수정 없음)
- 구글 로그인 버튼: 완성형 이미지 대신, 심볼(아이콘) 이미지 `assets/icons/google_symbol.png`를 사용해서 코드로 직접 커스텀 버튼을 제작
- 심볼 이미지 자체에 얇은 테두리가 포함되어 있어, 이를 code-level 크롭으로 제거해야 함
- 구글 커스텀 버튼의 전체 크기(너비·높이)는 카카오 버튼 이미지의 실제 렌더링 크기와 동일해야 함

---

## Step 1. 카카오 이미지 실제 크기 확인

`assets/icons/` 폴더에서 카카오 로그인 버튼 이미지 파일을 찾아서, 실제 픽셀 크기(가로 x 세로)를 확인해줘. (터미널에서 `file` 명령어나 이미지 메타데이터 확인 도구 사용 가능)

확인한 원본 비율을 바탕으로, 너비 240px일 때의 렌더링 높이를 계산해줘.

```
renderedHeight = 240 * (원본 세로 / 원본 가로)
```

이 계산된 값을 `lib/core/constants/button_size.dart` 파일에 상수로 저장해줘.

```dart
class ButtonSize {
  static const double loginButtonWidth = 240;
  static const double loginButtonHeight = /* 계산된 값 */;
}
```

---

## Step 2. 구글 심볼 테두리 제거 위젯 작성

### lib/features/auth/widgets/cropped_google_symbol.dart

요구사항:
- `assets/icons/google_symbol.png`를 표시하되, 이미지 자체에 포함된 테두리를 시각적으로 제거
- `Transform.scale`로 이미지를 확대(배율은 `const double _symbolScaleFactor = 1.25`로 상수 분리)한 뒤, `ClipRRect`로 지정된 크기만큼만 잘라내서 테두리 부분이 보이지 않게 처리
- 심볼 표시 크기는 24x24 (정사각형)로 고정
- `StatelessWidget`으로 작성

```dart
// 참고 구조 (Claude Code가 세부 구현 채울 것)
class CroppedGoogleSymbol extends StatelessWidget {
  const CroppedGoogleSymbol({super.key});

  static const double _symbolSize = 24;
  static const double _symbolScaleFactor = 1.25;

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
```

> 확대 배율(1.25)은 예시값이야. 실제로 실행해보고 테두리가 완전히 안 보일 때까지 1.1~1.4 범위에서 조정해줘.

---

## Step 3. 구글 커스텀 버튼 위젯 작성

### lib/features/auth/widgets/google_login_button.dart

요구사항:
- 전체 크기: `ButtonSize.loginButtonWidth` x `ButtonSize.loginButtonHeight` (Step 1에서 계산한 값 사용)
- 배경색: 흰색 (`#FFFFFF`)
- 테두리: 없음
- 모서리 radius: 12
- 내부 구성: 좌측 여백 16px → `CroppedGoogleSymbol` → 간격 12px → "Google로 시작하기" 텍스트 (가운데 정렬, Roboto 계열 폰트, 다크그레이 텍스트 `#1F1F1F`)
- 탭 이벤트를 받는 콜백(`onPressed`)을 매개변수로 받는 구조
- `StatelessWidget`으로 작성, early return 패턴 유지 (조건문 필요 시)

```dart
// 참고 구조
class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ButtonSize.loginButtonWidth,
      height: ButtonSize.loginButtonHeight,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(width: 16),
              CroppedGoogleSymbol(),
              SizedBox(width: 12),
              Text(
                'Google로 시작하기',
                style: TextStyle(color: Color(0xFF1F1F1F), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Step 4. 기존 LoginButtons 위젯에서 교체

`lib/features/auth/` 안의 로그인 버튼들을 감싸는 상위 위젯(`LoginButtons` 관련 파일)에서:
- 카카오 버튼은 기존 이미지 위젯 그대로 유지
- 구글 버튼만 새로 만든 `GoogleLoginButton`으로 교체

---

## Step 5. 검증 요청

작업 완료 후 아래 사항을 확인해서 알려줘.

- [ ] 카카오 버튼과 구글 버튼의 너비·높이가 픽셀 단위로 동일한지
- [ ] 구글 심볼 이미지의 테두리가 시각적으로 보이지 않는지 (디버그 모드 확인 필요함을 안내)
- [ ] `flutter analyze` 결과 에러/경고 없는지
- [ ] `Transform.scale` 배율이 과해서 심볼 자체가 잘리거나 왜곡되지 않았는지

작업 완료 후 `/commit-push` 명령어로 커밋 및 푸시 진행해줘.
