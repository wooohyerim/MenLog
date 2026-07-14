import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

const double _kIconButtonSize = 32;
const double _kBadgeSize = 14;
const double _kBadgeFontSize = 9;
const double _kWordmarkFontSize = 19;
const double _kWordmarkLetterSpacing = 2;

/// MENLOG 워드마크 + 친구/그룹 관리 진입 아이콘이 있는 공용 탭 상단 헤더.
///
/// 지도/피드/추천 탭 화면에서 공통으로 사용합니다.
/// 3.1 기능 4(친구/그룹 관리 진입) 참고 — 아이콘 탭 시 그룹 리스트 →
/// 그룹 상세(멤버/초대) 서브 화면으로 진입합니다. 실제 라우팅은
/// [onFriendsTap]으로 상위에서 주입받습니다.
class MenlogHeader extends StatelessWidget {
  const MenlogHeader({
    required this.friendGroupMemberCount,
    this.onFriendsTap,
    super.key,
  });

  /// 현재 선택된 그룹(기본값: 개인 그룹)의 멤버 수. 1 이하면 뱃지를 숨깁니다.
  final int friendGroupMemberCount;
  final VoidCallback? onFriendsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildWordmark(),
          _buildFriendsButton(),
        ],
      ),
    );
  }

  Widget _buildWordmark() {
    return const Text(
      'MENLOG',
      style: TextStyle(
        fontFamily: 'Georgia',
        fontSize: _kWordmarkFontSize,
        letterSpacing: _kWordmarkLetterSpacing,
        color: MenlogColors.dark,
      ),
    );
  }

  Widget _buildFriendsButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(_kIconButtonSize / 2),
      onTap: () => onFriendsTap?.call(),
      child: SizedBox(
        width: _kIconButtonSize,
        height: _kIconButtonSize,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildIconCircle(),
            _buildBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconCircle() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: MenlogColors.surface,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: MenlogColors.borderPrimarySoft, width: 0.5),
        ),
      ),
      child: Center(
        child: Icon(Icons.people_outline, size: 16, color: MenlogColors.primary),
      ),
    );
  }

  Widget _buildBadge() {
    if (friendGroupMemberCount <= 1) return const SizedBox.shrink();

    return Positioned(
      top: -3,
      right: -3,
      child: Container(
        width: _kBadgeSize,
        height: _kBadgeSize,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: MenlogColors.badge,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$friendGroupMemberCount',
          style: const TextStyle(fontSize: _kBadgeFontSize, color: Colors.white),
        ),
      ),
    );
  }
}
