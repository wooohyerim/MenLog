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
