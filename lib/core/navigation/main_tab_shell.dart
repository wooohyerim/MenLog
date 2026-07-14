import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/navigation/menlog_tab.dart';
import 'package:menlog/core/navigation/providers/current_tab_provider.dart';
import 'package:menlog/core/navigation/widgets/menlog_bottom_nav_bar.dart';
import 'package:menlog/features/feed/presentation/feed_placeholder_screen.dart';
import 'package:menlog/features/map/presentation/home_map_screen.dart';
import 'package:menlog/features/recommend/presentation/recommend_placeholder_screen.dart';
import 'package:menlog/features/record/presentation/record_screen.dart';

/// 하단 탭 4개(지도/피드/기록/추천)를 감싸는 최상위 셸.
///
/// 기록 탭은 [MenlogTab.isAction]이 true라서 IndexedStack을 바꾸는 대신
/// [RecordScreen]을 push합니다.
class MainTabShell extends ConsumerWidget {
  const MainTabShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: _resolveStackIndex(currentTab),
        children: const [
          HomeMapScreen(),
          FeedPlaceholderScreen(),
          RecommendPlaceholderScreen(),
        ],
      ),
      bottomNavigationBar: MenlogBottomNavBar(
        currentTab: currentTab,
        onTabSelected: (tab) => _handleTabSelected(ref, tab),
        onRecordTap: () => _handleRecordTap(context),
      ),
    );
  }

  int _resolveStackIndex(MenlogTab tab) {
    if (tab == MenlogTab.feed) return 1;
    if (tab == MenlogTab.recommend) return 2;
    return 0;
  }

  void _handleTabSelected(WidgetRef ref, MenlogTab tab) {
    ref.read(currentTabProvider.notifier).state = tab;
  }

  void _handleRecordTap(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const RecordScreen()),
    );
  }
}
