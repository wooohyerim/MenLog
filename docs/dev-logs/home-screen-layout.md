# 홈 화면 레이아웃 마크업 (지도 Placeholder)

CLAUDE.md의 코드 스타일 규칙(early return, 삼항연산자 금지, else if 금지, const 상수 분리)을 반드시 지켜서 작성해줘.

---

## 배경

기존 `lib/features/home/home_screen.dart`에는 "기록하기" 버튼 하나만 있는 임시 화면이 있어. 이걸 실제 목업 구조에 맞는 레이아웃으로 확장할 거야. 지도는 아직 실제 연동 없이 회색 placeholder 박스로만 두고, 레이아웃/버튼 구조부터 잡아줘.

---

## Step 1. 홈 화면 데이터 모델 (임시 더미 데이터)

### lib/features/home/dummy_visits.dart

마크업 확인용 더미 데이터를 만들어줘. 실제 Supabase 연동은 다음 단계에서 진행할 거야.

```dart
class DummyVisit {
  const DummyVisit({required this.shopName, required this.visitedDate});

  final String shopName;
  final String visitedDate;
}

const List<DummyVisit> dummyVisits = [
  DummyVisit(shopName: '멘야 무사시', visitedDate: '2026.07.01'),
  DummyVisit(shopName: '이치란 라멘', visitedDate: '2026.06.28'),
];
```

---

## Step 2. 홈 화면 레이아웃 구성

### lib/features/home/home_screen.dart 전체 재작성

요구사항:

**상단 (AppBar)**
- 좌측: 앱 타이틀 텍스트 "멘로그" (또는 그룹명, 지금은 고정 텍스트로)
- 우측: 프로필 아이콘 (`Icons.person_outline`), 탭 시 아직 기능 없으니 `debugPrint`만
- 배경색은 기존 디자인 시스템의 크래프트지 톤(`#EDE0CC`)과 어울리게 흰색 또는 투명 처리

**중앙 (지도 Placeholder)**
- `Container`로 화면의 약 60~65% 높이를 차지하는 영역
- 배경색: `Colors.grey.shade300`
- 중앙에 안내 텍스트: "지도 영역 (추후 연동 예정)"
- 모서리 radius 없이 꽉 채운 사각형으로 (나중에 그릇 모양 클립 추가 예정이라는 주석 남겨줘)

**하단 (기록 목록 미리보기)**
- `dummyVisits` 리스트가 비어있는지 여부에 따라 두 가지 상태를 보여주는 위젯을 만들어줘 (마크업 검증용으로, 리스트를 비운 상태/채운 상태 둘 다 쉽게 테스트할 수 있게 상수 플래그로 전환 가능하게 해줘)
  - 빈 상태: 중앙 정렬 텍스트 "아직 기록한 라멘집이 없어요"
  - 있음 상태: `dummyVisits`를 `ListView`로 렌더링, 각 항목은 가게 이름 + 방문 날짜를 담은 간단한 카드(`ListTile` 또는 커스텀 위젯)
- 이 영역은 화면 하단 약 35~40% 정도 차지

**플로팅 버튼**
- 우측 하단 `FloatingActionButton.extended`
- 라벨: "기록하기", 아이콘: `Icons.add`
- 탭 시 기존에 만든 `requireAuth(context: context, ref: ref, targetPath: '/record')` 호출 (이미 `lib/core/router/auth_guard.dart`에 있음)

### 코드 스타일
- `ConsumerWidget`으로 작성 (Riverpod 사용)
- 매직 넘버(퍼센트 높이, radius 등)는 위젯 상단에 `const` 상수로 분리
- 위젯을 너무 크게 만들지 말고, 지도 영역/하단 리스트 영역을 각각 별도의 private 위젯(`_MapPlaceholder`, `_VisitListPreview`)으로 분리해줘

---

## Step 3. 검증 요청

작업 완료 후 아래 사항을 확인해서 알려줘.

- [ ] `flutter run`으로 홈 화면이 상단바/지도 placeholder/하단 리스트/플로팅 버튼 구조로 정상 렌더링되는지
- [ ] `dummyVisits`를 빈 리스트로 바꿨을 때 "아직 기록한 라멘집이 없어요" 문구가 정상 표시되는지
- [ ] "기록하기" 버튼 탭 시 기존 인증 가드(로그인 여부에 따른 분기)가 정상 동작하는지
- [ ] `flutter analyze` 결과 에러/경고 없는지

작업 완료 후 `/commit-push` 명령어로 커밋 및 푸시 진행해줘.
