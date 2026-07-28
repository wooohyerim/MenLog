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

  /// 그룹별 멤버 수. 개인 그룹은 본인 1명뿐이라 항상 1이 나온다 — 헤더
  /// 친구 아이콘 노출 여부(멤버 2명 이상인 그룹이 있는지) 판단에 쓰인다.
  Future<Map<String, int>> fetchMemberCounts(List<String> groupIds) async {
    if (groupIds.isEmpty) return {};

    final rows = await supabase
        .from('group_members')
        .select('group_id')
        .inFilter('group_id', groupIds);

    return rows.fold<Map<String, int>>({}, (counts, row) {
      final groupId = row['group_id'] as String;
      return {...counts, groupId: (counts[groupId] ?? 0) + 1};
    });
  }
}

final groupRepository = GroupRepository();
