import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:menlog/features/auth/auth_provider.dart';
import 'package:menlog/features/auth/login_screen.dart';
import 'package:menlog/features/auth/nickname_setup_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(supabase.auth.onAuthStateChange),
    redirect: (context, state) async {
      final isLoggingIn = state.matchedLocation == '/login';
      final isSettingNickname = state.matchedLocation == '/nickname-setup';

      final user = ref.read(currentUserProvider);

      if (user == null) {
        if (isLoggingIn) return null;
        return '/login';
      }

      final isNew = await authRepository.isNewUser(user.id);

      if (isNew) {
        if (isSettingNickname) return null;
        return '/nickname-setup';
      }

      if (isLoggingIn) return '/home';
      if (isSettingNickname) return '/home';

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/nickname-setup',
        builder: (context, state) => const NicknameSetupScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Placeholder()),
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
