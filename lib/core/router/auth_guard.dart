import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:menlog/features/auth/auth_provider.dart';

void requireAuth({
  required BuildContext context,
  required WidgetRef ref,
  required String targetPath,
}) {
  final user = ref.read(currentUserProvider);

  if (user == null) {
    context.push('/login?redirect=$targetPath');
    return;
  }

  context.push(targetPath);
}
