import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/constants/supabase_client.dart';
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
