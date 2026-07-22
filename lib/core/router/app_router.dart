import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/core/navigation/main_tab_shell.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/login_screen.dart';
import 'package:menlog/features/auth/nickname_setup_screen.dart';

const String _defaultRedirectPath = '/home';

// OAuth 딥링크 콜백(io.supabase.menlog://...)이 플랫폼에 의해 라우트 정보로
// 전달될 때, 원래 이동하려던 경로를 잃지 않도록 마지막으로 알려진 경로를 기억해둔다.
String _lastKnownRedirectPath = _defaultRedirectPath;

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: _defaultRedirectPath,
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (context, state) async {
      final isDeepLinkCallback = state.uri.scheme.isNotEmpty;
      final isLoggingIn = !isDeepLinkCallback && state.matchedLocation == '/login';
      final isSettingNickname =
          !isDeepLinkCallback && state.matchedLocation == '/nickname-setup';
      final redirectPath = isDeepLinkCallback
          ? _lastKnownRedirectPath
          : state.uri.queryParameters['redirect'] ?? _defaultRedirectPath;
      if (!isDeepLinkCallback) _lastKnownRedirectPath = redirectPath;

      // ref.read(currentUserProvider)는 이 콜백과는 별개로 같은
      // supabase.auth.onAuthStateChange 스트림을 구독하고 있어, 리스너
      // 등록 순서에 따라 로그아웃 직후에도 이전 로그인 상태를 그대로
      // 반환할 수 있다. 세션의 진짜 상태를 보려면 SDK 값을 직접 읽는다.
      final user = supabase.auth.currentUser;
      if (user == null) {
        // 딥링크 콜백 시점엔 supabase SDK가 아직 토큰 교환(getSessionFromUrl)
        // 중이라 세션이 없을 수 있다. 이 경우 /login으로 보내되,
        // onAuthStateChange가 세션 생성을 알리면 refreshListenable이
        // redirect를 재실행해 아래 로직으로 다시 평가된다.
        if (isDeepLinkCallback) return '/login?redirect=$redirectPath';
        return null;
      }

      final isNew = await authRepository.isNewUser(user.id);

      if (isNew) {
        if (isSettingNickname) return null;
        return '/nickname-setup?redirect=$redirectPath';
      }

      if (isLoggingIn || isDeepLinkCallback) return redirectPath;
      if (isSettingNickname) return redirectPath;

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final redirectPath =
              state.uri.queryParameters['redirect'] ?? _defaultRedirectPath;
          return LoginScreen(redirectPath: redirectPath);
        },
      ),
      GoRoute(
        path: '/nickname-setup',
        builder: (context, state) {
          final redirectPath =
              state.uri.queryParameters['redirect'] ?? _defaultRedirectPath;
          return NicknameSetupScreen(redirectPath: redirectPath);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainTabShell(),
      ),
      GoRoute(
        path: '/record',
        builder: (context, state) => const Placeholder(),
      ),
    ],
  );
});

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
