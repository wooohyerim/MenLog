import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menlog/core/constants/app_colors.dart';
import 'package:menlog/core/constants/tagline_style.dart';
import 'package:menlog/core/router/auth_guard.dart';
import 'package:menlog/features/home/dummy_visits.dart';

const int _mapAreaFlex = 62;
const int _listAreaFlex = 38;
const bool _forceEmptyState = false;

const String _logoIconAsset = 'assets/icons/ramen_icon.png';
const double _headerIconSize = 28;
const double _headerIconTextGap = 8;
const double _headerHorizontalPadding = 16;
const double _headerVerticalPadding = 12;

const double _actionAreaPadding = 16;
const double _actionButtonGap = 12;
const double _actionButtonHeight = 48;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _handleRecordTap(BuildContext context, WidgetRef ref) {
    requireAuth(context: context, ref: ref, targetPath: '/record');
  }

  void _handleInviteTap() {
    debugPrint('초대하기 탭됨');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const _HomeHeader(),
            const Expanded(flex: _mapAreaFlex, child: _MapPlaceholder()),
            Expanded(
              flex: _listAreaFlex,
              child: _HomeActionArea(
                onRecordTap: () => _handleRecordTap(context, ref),
                onInviteTap: _handleInviteTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _headerHorizontalPadding,
        vertical: _headerVerticalPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: TaglineStyle.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            _logoIconAsset,
            width: _headerIconSize,
            height: _headerIconSize,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('로고 아이콘을 찾을 수 없어요: $_logoIconAsset, $error');
              return const SizedBox(
                width: _headerIconSize,
                height: _headerIconSize,
              );
            },
          ),
          const SizedBox(width: _headerIconTextGap),
          const Text(
            'MENLOG',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: AppColors.wordmark,
            ),
          ),
        ],
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

class _HomeActionArea extends StatelessWidget {
  const _HomeActionArea({required this.onRecordTap, required this.onInviteTap});

  final VoidCallback onRecordTap;
  final VoidCallback onInviteTap;

  List<DummyVisit> get _visits {
    if (_forceEmptyState) return [];
    return dummyVisits;
  }

  @override
  Widget build(BuildContext context) {
    final visits = _visits;

    if (visits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(_actionAreaPadding),
        child: _EmptyStateActions(
          onRecordTap: onRecordTap,
          onInviteTap: onInviteTap,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(_actionAreaPadding),
      child: _HasVisitsActions(onRecordTap: onRecordTap),
    );
  }
}

class _EmptyStateActions extends StatelessWidget {
  const _EmptyStateActions({
    required this.onRecordTap,
    required this.onInviteTap,
  });

  final VoidCallback onRecordTap;
  final VoidCallback onInviteTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FilledActionButton(label: '기록하기', onTap: onRecordTap)),
        const SizedBox(width: _actionButtonGap),
        Expanded(
          child: _OutlinedActionButton(label: '초대하기', onTap: onInviteTap),
        ),
      ],
    );
  }
}

class _HasVisitsActions extends StatelessWidget {
  const _HasVisitsActions({required this.onRecordTap});

  final VoidCallback onRecordTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // TODO: 지도 마커/범례는 지도 연동 단계에서 추가 예정
        SizedBox(
          width: double.infinity,
          child: _FilledActionButton(label: '기록하기', onTap: onRecordTap),
        ),
      ],
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  const _FilledActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _actionButtonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: TaglineStyle.textColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  const _OutlinedActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _actionButtonHeight,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: TaglineStyle.textColor,
          side: const BorderSide(color: TaglineStyle.textColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}
