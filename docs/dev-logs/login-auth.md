# 로그인 화면 + OAuth 연동 구현

CLAUDE.md의 코드 스타일 규칙(early return, 삼항연산자 금지, else if 금지, type/const 우선)을 반드시 지켜서 작성해줘.

---

## 구현 범위

1. 로그인 화면 UI (`lib/features/auth/`)
2. 카카오/구글 signInWithOAuth 연동
3. 로그인 성공 후 신규/기존 유저 분기 처리
4. 닉네임 확인 화면 (신규 유저 전용)
5. 세션 감지 후 라우팅 (go_router)

---

## Step 1. Riverpod Auth Provider 작성

### lib/features/auth/auth_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_client.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.session?.user,
    loading: () => supabase.auth.currentUser,
    error: (_, __) => null,
  );
});
```

---

## Step 2. Auth Repository 작성

### lib/data/repositories/auth_repository.dart

역할: OAuth 로그인 호출, 신규 유저 여부 확인, users 테이블 upsert

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_client.dart';

class AuthRepository {
  Future<void> signInWithKakao() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.kakao,
      redirectTo: 'io.supabase.menlog://login-callback',
    );
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.menlog://login-callback',
    );
  }

  Future<bool> isNewUser(String userId) async {
    final result = await supabase
        .from('users')
        .select('id')
        .eq('id', userId)
        .maybeSingle();

    if (result == null) return true;
    return false;
  }

  Future<void> upsertUser({
    required String userId,
    required String nickname,
    String? avatarUrl,
  }) async {
    await supabase.from('users').upsert({
      'id': userId,
      'nickname': nickname,
      'avatar_url': avatarUrl,
    });
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final result = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return result;
  }
}

final authRepository = AuthRepository();
```

> 주의: `redirectTo`의 URL scheme(`io.supabase.menlog`)은 예시값이야. 실제로는 iOS/Android 네이티브 설정에 등록한 커스텀 scheme과 일치해야 하니, Info.plist / AndroidManifest.xml 설정 시 동일한 값을 쓸 수 있게 `core/constants`에 상수로 분리해줘.

---

## Step 3. 로그인 화면 UI

### lib/features/auth/login_screen.dart

요구사항:
- 배경색 `#EDE0CC`
- 중앙에 멘로그 워드마크 (Georgia, 대문자, letter-spacing)
- 하단에 카카오 로그인 버튼, 구글 로그인 버튼 (세로 배치)
- 버튼 탭 시 로딩 인디케이터 표시
- 에러 발생 시 스낵바로 안내 + 재시도 가능하게 (에러 상태에서 버튼 재활성화)
- OAuth 팝업을 사용자가 취소한 경우 별도 에러 처리 없이 조용히 로딩 상태만 해제

ConsumerStatefulWidget으로 작성 (로딩 상태는 지역 UI 상태라 setState 사용 가능).

버튼 클릭 핸들러는 `handleKakaoLogin`, `handleGoogleLogin` 네이밍으로.

---

## Step 4. 닉네임 확인 화면

### lib/features/auth/nickname_setup_screen.dart

요구사항:
- 안내 문구: "그룹원들에게 보여질 이름이에요"
- TextField 기본값: OAuth에서 받은 이름 (`user.userMetadata?['full_name']` 또는 `user.userMetadata?['name']`)
- 최대 12자 제한
- 공백 제출 시 인라인 에러 텍스트 표시 ("닉네임을 입력해주세요")
- 확인 버튼 탭 시 `authRepository.upsertUser` 호출 후 홈 화면으로 이동
- 저장 중 네트워크 에러 시 스낵바 안내 + 재시도 가능하게

---

## Step 5. 라우팅 처리 (go_router)

### lib/core/router/app_router.dart

요구사항:
- 앱 시작 시 `currentUserProvider` 확인
- 세션 없으면 `/login`
- 세션 있으면 `isNewUser` 체크:
  - 신규 유저 → `/nickname-setup`
  - 기존 유저 → `/home`
- redirect 로직은 early return 패턴으로 작성 (else if 금지)

```dart
// 예시 구조 (Claude Code가 세부 구현 채울 것)
GoRouter(
  redirect: (context, state) async {
    final user = ref.read(currentUserProvider);

    if (user == null) return '/login';

    final isNew = await authRepository.isNewUser(user.id);
    if (isNew) return '/nickname-setup';

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/nickname-setup', builder: (context, state) => const NicknameSetupScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()), // HomeScreen 없으면 Placeholder로 대체
  ],
)
```

---

## Step 6. main.dart 라우터 연결

`MaterialApp`을 `MaterialApp.router`로 변경하고 `routerConfig`에 위 라우터 연결.

---

## 완료 후 확인사항

- [ ] `flutter run` 으로 로그인 화면 정상 노출
- [ ] 카카오 버튼 탭 시 OAuth 팝업 정상 실행 (네이티브 설정 전이면 에러 발생 가능, 이 경우 다음 단계에서 iOS/Android 세팅 진행)
- [ ] 로그인 성공 시 닉네임 확인 화면 또는 홈 화면으로 정상 라우팅
- [ ] `lib/features/auth/` 폴더 구조가 CLAUDE.md 파일명 규칙(snake_case) 준수하는지 확인

작업 완료 후 `/commit-push` 명령어로 커밋 및 푸시 진행해줘.
