import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/navigation/menlog_tab.dart';
import 'package:menlog/core/navigation/providers/current_tab_provider.dart';
import 'package:menlog/core/navigation/widgets/menlog_bottom_nav_bar.dart';
import 'package:menlog/features/auth/auth_provider.dart';
import 'package:menlog/features/auth/login_screen.dart';
import 'package:menlog/features/feed/presentation/feed_placeholder_screen.dart';
import 'package:menlog/features/map/presentation/home_map_screen.dart';
import 'package:menlog/features/recommend/presentation/recommend_placeholder_screen.dart';
import 'package:menlog/features/record/presentation/record_screen.dart';
import 'package:menlog/features/settings/presentation/settings_screen.dart';

/// 하단 탭 4개(지도/피드/추천/설정)를 감싸는 최상위 셸.
///
/// 지도 탭을 제외한 나머지 탭은 로그인이 필요합니다. 로그인하지 않은 채로
/// 접근하면 [LoginScreen]을, 로그인한 상태면 각 탭의 화면을 보여줍니다.
/// 기록하기는 탭이 아니라 [MenlogBottomNavBar] 중앙에 끼워진 동그란
/// 버튼으로 제공합니다.
class MainTabShell extends ConsumerWidget {
  const MainTabShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final isLoggedIn = ref.watch(currentUserProvider) != null;

    return Scaffold(
      body: IndexedStack(
        index: _resolveStackIndex(currentTab),
        children: [
          const HomeMapScreen(),
          _buildGatedTab(isLoggedIn, const FeedPlaceholderScreen()),
          _buildGatedTab(isLoggedIn, const RecommendPlaceholderScreen()),
          _buildGatedTab(isLoggedIn, const SettingsScreen()),
        ],
      ),
      bottomNavigationBar: MenlogBottomNavBar(
        currentTab: currentTab,
        onTabSelected: (tab) => _handleTabSelected(ref, tab),
        onRecordTap: () => _handleRecordTap(context, ref),
      ),
    );
  }

  Widget _buildGatedTab(bool isLoggedIn, Widget screen) {
    if (isLoggedIn) return screen;
    return const LoginScreen();
  }

  int _resolveStackIndex(MenlogTab tab) {
    if (tab == MenlogTab.feed) return 1;
    if (tab == MenlogTab.recommend) return 2;
    if (tab == MenlogTab.settings) return 3;
    return 0;
  }

  void _handleTabSelected(WidgetRef ref, MenlogTab tab) {
    ref.read(currentTabProvider.notifier).state = tab;
  }

  void _handleRecordTap(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.read(currentUserProvider) != null;

    if (!isLoggedIn) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const LoginScreen()));
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RecordScreen()));
  }
}
