import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/router/auth_guard.dart';
import 'package:menlog/features/home/dummy_visits.dart';

const int _mapAreaFlex = 62;
const int _listAreaFlex = 38;
const bool _forceEmptyState = false;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleRecordTap(BuildContext context, WidgetRef ref) {
    requireAuth(context: context, ref: ref, targetPath: '/record');
  }

  void _handleProfileTap() {
    debugPrint('프로필 아이콘 탭됨');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('멘로그'),
        actions: [
          IconButton(
            onPressed: _handleProfileTap,
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      body: const Column(
        children: [
          Expanded(flex: _mapAreaFlex, child: _MapPlaceholder()),
          Expanded(flex: _listAreaFlex, child: _VisitListPreview()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _handleRecordTap(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('기록하기'),
      ),
    );
  }
}

// TODO: 추후 그릇 모양 클립으로 교체 예정
class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade300,
      child: const Center(child: Text('지도 영역 (추후 연동 예정)')),
    );
  }
}

class _VisitListPreview extends StatelessWidget {
  const _VisitListPreview();

  List<DummyVisit> get _visits {
    if (_forceEmptyState) return [];
    return dummyVisits;
  }

  @override
  Widget build(BuildContext context) {
    if (_visits.isEmpty) {
      return const Center(child: Text('아직 기록한 라멘집이 없어요'));
    }

    return ListView(
      children: _visits
          .map(
            (visit) => ListTile(
              title: Text(visit.shopName),
              subtitle: Text(visit.visitedDate),
            ),
          )
          .toList(),
    );
  }
}
