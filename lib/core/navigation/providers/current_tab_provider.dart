import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menlog/core/navigation/menlog_tab.dart';

/// 현재 선택된 탭 상태.
///
/// 기록하기 탭은 [MenlogTab.isAction]이 true라서 이 상태를 갱신하지 않고
/// 별도 화면을 push하는 방식으로 처리합니다 (MainTabShell 참고).
///
/// 지금은 가벼운 StateProvider로 시작했습니다. 프로젝트 전반이
/// riverpod_annotation 코드젠을 쓰고 있으니, 이후 상태 로직이 복잡해지면
/// @riverpod 클래스로 전환하는 걸 고려하세요.
final currentTabProvider = StateProvider<MenlogTab>((ref) => MenlogTab.map);
