# 멘로그 (Flutter) 프로젝트 초기 세팅

아래 작업을 순서대로 진행해줘. 각 단계 성공 확인 후 다음 단계로 넘어가.

---

## 환경 전제
- 작업 경로: ~/Desktop/woo-project/menlog (flutter create 이미 완료됨)
- GitHub 레포: wooohyerim/MenLog (git init 완료, remote 연결 필요)
- Supabase Project ID: jpaycddoijmpqxocigti
- Supabase Project URL / anon key: .env 파일로 관리 예정
- 상태관리: Riverpod
- 지도: google_maps_flutter
- 로그인: 카카오 + 구글

---

## Step 1. pubspec.yaml에 패키지 추가

아래 패키지들을 pubspec.yaml에 추가하고 `flutter pub get` 실행해줘.

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  supabase_flutter: ^2.8.0
  google_maps_flutter: ^2.10.0
  kakao_flutter_sdk_user: ^1.9.6
  google_sign_in: ^6.2.2
  flutter_dotenv: ^5.2.1
  go_router: ^14.6.2
  image_picker: ^1.1.2
  cached_network_image: ^3.4.1
  http: ^1.2.0

dev_dependencies:
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.13
  custom_lint: ^0.7.0
  riverpod_lint: ^2.6.3
```

> `http`는 지도/추천/기록하기 탭이 공유하는 라멘집 검색 저장소(`RamenShopSearchRepository`)에서 Google Places API를 직접 호출하기 위해 추가 (기획서 6장 공통 모듈 설계 참고).

---

## Step 2. 폴더 구조 생성

```bash
mkdir -p lib/core/router
mkdir -p lib/core/theme
mkdir -p lib/core/constants
mkdir -p lib/data/models
mkdir -p lib/data/repositories
mkdir -p lib/features/auth
mkdir -p lib/features/home
mkdir -p lib/features/feed
mkdir -p lib/features/record
mkdir -p lib/features/recommend
mkdir -p lib/features/group
mkdir -p lib/shared/widgets
mkdir -p assets/images
mkdir -p assets/icons
```

설명:
- `core` — 라우터, 테마, 상수 등 앱 전역 설정
- `data/models` — Supabase 테이블 대응 데이터 모델 (Dart class, freezed 없이 순수 class + fromJson/toJson)
- `data/repositories` — Supabase 쿼리 로직 + 공통 검색 모듈(`RamenShopSearchRepository`)
- `features/*` — 화면별 폴더 (view + provider + widgets 하위 구조)
  - `home` — 지도 탭 (기획서 IA 기준 하단 탭 4개는 `home`/`feed`/`record`/`recommend`로 대응)
  - `feed` — 피드 탭 (신규, 좋아요/댓글 포함)
  - `record` — 기록하기(+) 탭
  - `recommend` — 추천 탭 (신규, 규칙 기반 스코어링 + Claude API)
  - `group` — 별도 탭이 아니라 **지도 탭 화면 상단 아이콘에서 진입하는 서브 화면** (그룹원 목록 + 초대 코드 공유). 폴더명은 기존 `groups`/`group_members` 라벨을 유지하되, 라우팅상 하단 탭이 아님에 유의
- `shared/widgets` — 공통 컴포넌트

---

## Step 3. 환경변수 파일 생성

`.env` 파일을 프로젝트 루트에 생성:

```
SUPABASE_URL=
SUPABASE_KEY=
KAKAO_NATIVE_APP_KEY=
GOOGLE_MAPS_API_KEY=
```

`.env.example`도 동일하게 값만 비운 버전으로 생성.

`.gitignore`에 `.env` 추가 (없으면).

`pubspec.yaml`의 assets에 `.env` 등록:
```yaml
flutter:
  assets:
    - .env
```

---

## Step 4. 데이터 모델 생성

기존 Supabase 스키마 기준으로 Dart 모델 작성. `lib/data/models/` 에 각각 파일 생성.

### lib/data/models/ramen_shop.dart
```dart
class RamenShop {
  final String id;
  final String googlePlaceId;
  final String name;
  final String? address;
  final double lat;
  final double lng;
  final DateTime createdAt;

  RamenShop({
    required this.id,
    required this.googlePlaceId,
    required this.name,
    this.address,
    required this.lat,
    required this.lng,
    required this.createdAt,
  });

  factory RamenShop.fromJson(Map<String, dynamic> json) {
    return RamenShop(
      id: json['id'] as String,
      googlePlaceId: json['google_place_id'] as String,
      name: json['name'] as String,
      address: json['address'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_place_id': googlePlaceId,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### lib/data/models/visit.dart
```dart
enum MediaType { photo, video }

enum BrothType { tonkotsu, shoyu, miso, shio, tsukemen }

class Visit {
  final String id;
  final String shopId;
  final String groupId;
  final String userId;
  final String mediaUrl;
  final MediaType mediaType;
  final String thumbnailUrl;
  final BrothType? brothType;
  final int rating;
  final String? memo;
  final DateTime visitedAt;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.shopId,
    required this.groupId,
    required this.userId,
    required this.mediaUrl,
    required this.mediaType,
    required this.thumbnailUrl,
    this.brothType,
    required this.rating,
    this.memo,
    required this.visitedAt,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      mediaUrl: json['media_url'] as String,
      mediaType: MediaType.values.byName(json['media_type'] as String),
      thumbnailUrl: json['thumbnail_url'] as String,
      brothType: json['broth_type'] != null
          ? BrothType.values.byName(json['broth_type'] as String)
          : null,
      rating: json['rating'] as int,
      memo: json['memo'] as String?,
      visitedAt: DateTime.parse(json['visited_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

### lib/data/models/visit_like.dart
```dart
class VisitLike {
  final String id;
  final String visitId;
  final String userId;
  final DateTime createdAt;

  VisitLike({
    required this.id,
    required this.visitId,
    required this.userId,
    required this.createdAt,
  });

  factory VisitLike.fromJson(Map<String, dynamic> json) {
    return VisitLike(
      id: json['id'] as String,
      visitId: json['visit_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

### lib/data/models/visit_comment.dart
```dart
class VisitComment {
  final String id;
  final String visitId;
  final String userId;
  final String content;
  final DateTime createdAt;

  VisitComment({
    required this.id,
    required this.visitId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory VisitComment.fromJson(Map<String, dynamic> json) {
    return VisitComment(
      id: json['id'] as String,
      visitId: json['visit_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

> `visit_likes`/`visit_comments` 테이블은 기획서 4~5장(피드 좋아요/댓글) 기준 신규 테이블이며, `supabase/migrations`에 마이그레이션이 먼저 추가되어야 한다.

### lib/data/models/group.dart
```dart
class Group {
  final String id;
  final String name;
  final String inviteCode;
  final String? createdBy;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    this.createdBy,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      inviteCode: json['invite_code'] as String,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

---

## Step 5. Supabase 초기화

### lib/core/constants/env.dart
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseKey => dotenv.get('SUPABASE_KEY');
  static String get kakaoNativeAppKey => dotenv.get('KAKAO_NATIVE_APP_KEY');
  static String get googleMapsApiKey => dotenv.get('GOOGLE_MAPS_API_KEY');
}
```

### lib/main.dart 수정
```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: Env.supabaseUrl,
    Key: Env.supabaseKey,
  );

  runApp(const ProviderScope(child: MenlogApp()));
}

class MenlogApp extends StatelessWidget {
  const MenlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '멘로그',
      debugShowCheckedModeBanner: false,
      home: const Placeholder(),
    );
  }
}
```

`lib/core/constants/supabase_client.dart` 에 전역 접근용 getter 추가:
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
```

---

## Step 6. GitHub 연결 및 첫 커밋

```bash
git remote add origin https://github.com/wooohyerim/MenLog.git
git add .
git commit -m "feat: Flutter로 전환, 프로젝트 초기화"
git branch -M main
git push -u origin main --force
```

---

## 완료 후 확인사항

- [ ] `flutter pub get` 에러 없이 완료
- [ ] `.env` 파일에 Supabase URL / anon key 채우기 필요
- [ ] `flutter run` 으로 빈 화면 실행 확인
- [ ] GitHub 레포에 Flutter 코드 push 확인
- [ ] 카카오/구글 로그인 키는 다음 단계에서 채움

---

## 참고. 공통 라멘집 검색 모듈 (RamenShopSearchRepository)

기획서 6장에서 확정된 내용으로, 초기 세팅 이후 지도/추천/기록하기 탭을 구현할 때 아래 저장소를 먼저 만들고 세 곳에서 공유해야 한다 (각자 따로 구현 금지).

### lib/data/repositories/ramen_shop_search_repository.dart (설계 초안)
- 입력: 검색어(선택), 위치 좌표(위치 편향), 검색 반경(선택)
- 출력: 정규화된 결과 리스트 — 각 항목에 `isRegistered`(우리 `ramen_shops`에 이미 있는지), `visitCount`(그룹 방문 횟수, 0이면 미방문) 플래그 포함
- Google Places API 호출은 `http` 패키지로 직접 REST 호출
- 사용처별 분기
  - 지도 탭: `isRegistered && visitCount > 0` → 폴라로이드 핀 / 그 외 → 심플 핀
  - 추천 탭: `visitCount > 0`인 곳은 후보에서 제외
  - 기록하기(+) 탭: `isRegistered = false`인 곳 선택 시 저장 단계에서 `ramen_shops`에 신규 upsert (`google_place_id` 기준)
- 캐싱/디바운스: 검색어+위치 버킷 단위로 클라이언트 메모리에 짧은 TTL 캐싱, 중복 호출 방지용 디바운스(약 300ms) 적용

### ⚠️ 사전 확인 필요
`ramen_shops.google_place_id`에 UNIQUE 제약이 걸려 있는지 먼저 확인할 것. 없으면 upsert 로직에서 같은 매장이 중복 row로 쌓일 수 있으므로, 아래 마이그레이션을 `supabase/migrations`에 추가한다.

```sql
alter table public.ramen_shops
  add constraint ramen_shops_google_place_id_key unique (google_place_id);
```
