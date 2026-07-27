import 'package:flutter/material.dart';

/// 멘로그 앱의 크래프트지 감성 컬러 토큰.
/// CLAUDE.md 4번 "디자인 시스템" 섹션 기준으로 고정된 값입니다.
class MenlogColors {
  const MenlogColors._();

  static const Color primary = Color(0xFFC8600A);
  static const Color surface = Color(0xFFF5D9B8);
  static const Color background = Color(0xFFEDE0CC);
  static const Color text = Color(0xFF6B3E26);
  static const Color dark = Color(0xFF2C1A0E);

  static const Color mapPlaceholder = Color(0xFFE3E3E3);

  /// 정복맵의 미정복 지역 폴리곤 전용 색상. [surface]는 검색창/헤더
  /// 아이콘 배경 등 다른 UI 크롬에도 쓰여서, [background]와 명도차가
  /// 커야 하는 지도 폴리곤에는 그대로 쓰면 구분이 잘 안 된다(사용자 피드백
  /// 반영) — 지도 전용 톤으로 분리했다.
  static const Color mapUnconquered = Color(0xFFC9B896);
  static const Color badge = Color(0xFFD85A30);
  static const Color borderPrimarySoft = Color(0x55C8600A);
  static const Color borderPrimaryFaint = Color(0x33C8600A);
}
