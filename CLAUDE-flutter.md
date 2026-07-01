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

dev_dependencies:
  riverpod_generator: ^2.6.3
  build_runner: ^2.4.13
  custom_lint: ^0.7.0
  riverpod_lint: ^2.6.3
```

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
mkdir -p lib/features/record
mkdir -p lib/features/group
mkdir -p lib/shared/widgets
mkdir -p assets/images
mkdir -p assets/icons
```

설명:
- `core` — 라우터, 테마, 상수 등 앱 전역 설정
- `data/models` — Supabase 테이블 대응 데이터 모델 (Dart class, freezed 없이 순수 class + fromJson/toJson)
- `data/repositories` — Supabase 쿼리 로직
- `features/*` — 화면별 폴더 (view + provider + widgets 하위 구조)
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
  static String get supabaseAnonKey => dotenv.get('SUPABASE_KEY');
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
    anonKey: Env.supabaseAnonKey,
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
