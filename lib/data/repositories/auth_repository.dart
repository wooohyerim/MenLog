import 'package:menlog/core/constants/auth_constants.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  Future<void> signInWithKakao() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.kakao,
      redirectTo: AuthConstants.oauthRedirectUrl,
    );
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AuthConstants.oauthRedirectUrl,
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
