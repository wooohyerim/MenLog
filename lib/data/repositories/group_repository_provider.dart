import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/data/models/group.dart';
import 'package:menlog/data/repositories/group_repository.dart';
import 'package:menlog/features/auth/auth_provider.dart';

/// 로그인한 유저가 속한 그룹 목록(개인 그룹 포함).
final myGroupsProvider = FutureProvider.autoDispose<List<Group>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  return groupRepository.fetchMyGroups(user.id);
});

/// 내가 속한 그룹 중 가장 멤버가 많은 그룹의 멤버 수. 개인 그룹뿐이면 1이라
/// [MenlogHeader]의 친구 아이콘이 자동으로 숨겨진다.
final maxGroupMemberCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final groups = await ref.watch(myGroupsProvider.future);
  if (groups.isEmpty) return 1;

  final counts = await groupRepository.fetchMemberCounts(
    groups.map((group) => group.id).toList(),
  );
  return counts.values.fold<int>(1, (a, b) => math.max(a, b));
});
