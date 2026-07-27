import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/models/group.dart';

/// 그룹 관련 조회를 담당하는 저장소.
///
/// "개인 그룹"은 DB에 별도 플래그가 없다 — 가입 즉시 자동 생성되어
/// `group_members`에 본인만 속한 평범한 그룹이다. 화면에서는 그냥
/// [fetchMyGroups] 결과가 1개뿐인지로 판단한다.
class GroupRepository {
  Future<List<Group>> fetchMyGroups(String userId) async {
    final rows = await supabase
        .from('group_members')
        .select('groups(*)')
        .eq('user_id', userId);

    return rows
        .map((row) => Group.fromJson(row['groups'] as Map<String, dynamic>))
        .toList();
  }
}

final groupRepository = GroupRepository();
