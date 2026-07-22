import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// `public.users` 테이블의 본인 프로필 행(닉네임 등). 로그인 상태가 아니면 null.
final userProfileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((
  ref,
) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  return authRepository.getUser(user.id);
});
