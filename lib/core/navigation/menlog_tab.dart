import 'package:flutter/material.dart';

/// 하단 탭 4개 정의 (지도/피드/기록하기/추천).
///
/// 기록하기(record)는 body를 바꾸는 일반 탭이 아니라, 별도 화면을 push하는
/// "액션 탭"입니다. [isAction]으로 이를 구분합니다.
enum MenlogTab {
  map(label: '지도', icon: Icons.map_outlined, isAction: false),
  feed(label: '피드', icon: Icons.dynamic_feed_outlined, isAction: false),
  record(label: '기록', icon: Icons.add_circle_outline, isAction: true),
  recommend(label: '추천', icon: Icons.auto_awesome_outlined, isAction: false);

  const MenlogTab({
    required this.label,
    required this.icon,
    required this.isAction,
  });

  final String label;
  final IconData icon;
  final bool isAction;
}
