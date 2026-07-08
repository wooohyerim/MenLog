# 게스트 홈 접근 + 인증 필요 액션 게이팅 구현

CLAUDE.md의 코드 스타일 규칙(early return, 삼항연산자 금지, else if 금지)을 반드시 지켜서 작성해줘.

---

## 배경

기존에는 세션이 없으면 앱 시작 시 무조건 로그인 화면으로 보냈지만, 이제는 로그인 없이도 홈 화면(지도)을 자유롭게 볼 수 있어야 해. 로그인은 "기록하기"처럼 개인 데이터가 필요한 액션을 실행할 때만 요구하도록 바꿔야 해.

---

## Step 1. 라우터 redirect 로직 수정

### lib/core/router/app_router.dart

기존에 세션 없으면 무조건 `/login`으로 보내던 redirect 로직을 제거하고, `/home` 경로는 로그인 여부와 무관하게 항상 접근 가능하도록 수정해줘.

단, 아래 두 가지는 유지해줘.
- 세션이 있고 신규 유저(닉네임 미설정)인 상태로 `/home`에 접근하려 하면, `/nickname-setup`으로 보내는 로직은 유지 (로그인은 했는데 닉네임 설정을 안 끝낸 애매한 상태를 방지하기 위함)
- `/login`, `/nickname-setup` 경로 자체는 그대로 유지

라우트에 쿼리 파라미터로 "로그인 성공 후 돌아갈 경로"를 받을 수 있게 해줘. 예: `/login?redirect=/record`

```dart
// 참고 구조 (Claude Code가 세부 구현 채울 것)
GoRoute(
  path: '/login',
  builder: (context, state) {
    final redirectPath = state.uri.queryParameters['redirect'] ?? '/home';
    return LoginScreen(redirectPath: redirectPath);
  },
),
```

---

## Step 2. 인증 필요 액션 가드 함수 작성

### lib/core/router/auth_guard.dart

여러 화면에서 재사용할 수 있는 공통 함수를 만들어줘. 이 함수는 "인증이 필요한 액션을 실행하기 전에 로그인 여부를 확인하고, 없으면 로그인 화면으로 보내는" 역할을 해.

```dart
// 참고 구조 (Claude Code가 세부 구현 채울 것)
void requireAuth({
  required BuildContext context,
  required WidgetRef ref,
  required String targetPath,
}) {
  final user = ref.read(currentUserProvider);

  if (user == null) {
    context.push('/login?redirect=$targetPath');
    return;
  }

  context.push(targetPath);
}
```

- early return 패턴 유지
- 함수명은 동사로 시작 (`requireAuth`)

---

## Step 3. 로그인 화면에 redirectPath 파라미터 추가

### lib/features/auth/login_screen.dart

`LoginScreen` 위젯이 `redirectPath` 파라미터(String, 기본값 `/home`)를 받도록 수정해줘.

로그인/닉네임 설정이 모두 끝난 후, 기존처럼 무조건 `/home`으로 가지 말고 **이 `redirectPath`로 이동**하도록 수정해줘.

- 신규 유저면: 로그인 성공 → `/nickname-setup`으로 이동하면서 `redirectPath`를 함께 전달 → 닉네임 저장 완료 후 `redirectPath`로 이동
- 기존 유저면: 로그인 성공 → 바로 `redirectPath`로 이동

`nickname_setup_screen.dart`도 동일하게 `redirectPath` 파라미터를 받아서 저장 완료 후 그 경로로 이동하도록 수정해줘.

---

## Step 4. 홈 화면에 임시 "기록하기" 버튼 추가 (테스트용)

현재 홈 화면이 `Placeholder`인 상태니, 이 게이팅 로직을 테스트할 수 있도록 임시로 버튼 하나만 추가해줘.

### lib/features/home/home_screen.dart (없으면 새로 생성, Placeholder 대체)

- 화면 중앙에 "기록하기" 버튼 하나만 있는 간단한 `ConsumerWidget`
- 버튼 탭 시 `requireAuth(context: context, ref: ref, targetPath: '/record')` 호출
- `/record` 경로는 아직 실제 화면이 없으니 임시로 `Placeholder`를 보여주는 라우트로 등록

라우터에 `/home` 경로가 이제 `Placeholder` 대신 이 `HomeScreen`을 사용하도록 수정해줘.

---

## Step 5. 검증 요청

작업 완료 후 아래 시나리오를 디버그 모드에서 직접 테스트해줘야 해서, 결과를 알려줘.

- [ ] 로그아웃 상태로 앱 실행 시 로그인 화면 없이 바로 홈 화면(기록하기 버튼 보이는 화면)이 뜨는지
- [ ] 로그아웃 상태에서 "기록하기" 버튼 탭 시 로그인 화면으로 이동하는지
- [ ] 로그인 완료(신규 유저) 후 닉네임 설정을 거쳐 `/record` 화면(Placeholder)으로 자동 이동하는지
- [ ] 이미 로그인된 상태에서 앱을 재실행하면 홈 화면으로 바로 진입하고, "기록하기" 버튼 탭 시 로그인 절차 없이 바로 `/record`로 이동하는지

작업 완료 후 `/commit-push` 명령어로 커밋 및 푸시 진행해줘.
