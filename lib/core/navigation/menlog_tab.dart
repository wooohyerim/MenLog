import 'package:flutter/material.dart';

/// 하단 탭 4개 정의 (지도/피드/추천/설정).
///
/// 기록하기는 더 이상 탭이 아니라 지도 화면의 플로팅 버튼으로 옮겨졌습니다.
enum MenlogTab {
  map(label: '지도', icon: Icons.map_outlined),
  feed(label: '피드', icon: Icons.dynamic_feed_outlined),
  recommend(label: '추천', icon: Icons.auto_awesome_outlined),
  settings(label: '설정', icon: Icons.settings_outlined);

  const MenlogTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
