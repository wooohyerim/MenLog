import 'package:menlog/core/constants/auth_constants.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  Future<void> signInWithKakao() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.kakao,
      redirectTo: AuthConstants.oauthRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AuthConstants.oauthRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
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
    String? email,
  }) async {
    await supabase.from('users').upsert({
      'id': userId,
      'nickname': nickname,
      'avatar_url': avatarUrl,
      'email': email,
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

  /// 본인 프로필 행을 삭제한다. visits/visit_likes/visit_comments는
  /// DB의 ON DELETE CASCADE로 함께 삭제된다 (탈퇴 시 완전 삭제 정책).
  Future<void> deleteAccount(String userId) async {
    await supabase.from('users').delete().eq('id', userId);
  }
}

final authRepository = AuthRepository();
