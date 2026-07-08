import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/auth_provider.dart';
import 'package:menlog/features/auth/login_screen.dart';
import 'package:menlog/features/auth/nickname_setup_screen.dart';
import 'package:menlog/features/home/home_screen.dart';

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
      if (isDeepLinkCallback) {
        return '/login?redirect=$_lastKnownRedirectPath';
      }

      final isLoggingIn = state.matchedLocation == '/login';
      final isSettingNickname = state.matchedLocation == '/nickname-setup';
      final redirectPath =
          state.uri.queryParameters['redirect'] ?? _defaultRedirectPath;
      _lastKnownRedirectPath = redirectPath;

      final user = ref.read(currentUserProvider);
      if (user == null) return null;

      final isNew = await authRepository.isNewUser(user.id);

      if (isNew) {
        if (isSettingNickname) return null;
        return '/nickname-setup?redirect=$redirectPath';
      }

      if (isLoggingIn) return redirectPath;
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
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
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
