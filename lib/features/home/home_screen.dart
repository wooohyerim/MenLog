import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/router/auth_guard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleRecordTap(BuildContext context, WidgetRef ref) {
    requireAuth(context: context, ref: ref, targetPath: '/record');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleRecordTap(context, ref),
          child: const Text('기록하기'),
        ),
      ),
    );
  }
}
