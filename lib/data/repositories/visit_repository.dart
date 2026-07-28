import 'package:image_picker/image_picker.dart';
import 'package:menlog/core/constants/supabase_client.dart';
import 'package:menlog/data/models/ramen_shop.dart';
import 'package:menlog/data/models/visit.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FileOptions;
import 'package:video_thumbnail/video_thumbnail.dart' as video_thumbnail;

const String _kVisitMediaBucket = 'visit-media';
const int _kThumbnailMaxWidth = 512;
const int _kThumbnailQuality = 70;

/// 기록하기(+) 화면의 저장 로직을 담당하는 저장소.
///
/// 매장 upsert → 미디어 업로드 → `visits` row 생성 순서로 이뤄지며, 각
/// 단계를 개별 메서드로 분리해 화면에서 실패한 단계만 재시도할 수 있게
/// 한다.
class VisitRepository {
  /// `google_place_id` 기준 upsert. 검색 결과를 그대로 저장하는 경우와
  /// 수동 등록(신규 `google_place_id`를 합성해 넘김) 모두 이 메서드 하나로
  /// 처리한다. `address`는 지도 탭 정복맵의 `RegionMatcher`가 조회 시점마다
  /// 지역을 판정하는 유일한 근거이므로 정확히 저장해야 한다(regionCode 같은
  /// 파생값은 저장하지 않는다 — 3.1 기능1 기술 메모 참고).
  Future<RamenShop> upsertShop({
    required String googlePlaceId,
    required String name,
    required String? address,
    required double lat,
    required double lng,
  }) async {
    final row = await supabase
        .from('ramen_shops')
        .upsert({
          'google_place_id': googlePlaceId,
          'name': name,
          'address': address,
          'lat': lat,
          'lng': lng,
        }, onConflict: 'google_place_id')
        .select()
        .single();

    return RamenShop.fromJson(row);
  }

  /// 사진/영상 파일을 스토리지에 올리고 공개 URL을 반환한다. 영상은
  /// 첫 프레임을 JPEG 썸네일로 별도 생성해서 함께 올린다(사진은 원본
  /// 자체가 썸네일 역할을 하므로 재업로드하지 않고 같은 URL을 재사용).
  Future<MediaUploadResult> uploadMedia({
    required String userId,
    required XFile file,
    required MediaType mediaType,
  }) async {
    final mediaBytes = await file.readAsBytes();
    final mediaExtension = _extensionOf(file.path, mediaType);
    final mediaPath =
        '$userId/${_uniqueFileName()}_media.$mediaExtension';

    await supabase.storage
        .from(_kVisitMediaBucket)
        .uploadBinary(
          mediaPath,
          mediaBytes,
          fileOptions: FileOptions(contentType: _contentTypeOf(mediaType)),
        );
    final mediaUrl = supabase.storage
        .from(_kVisitMediaBucket)
        .getPublicUrl(mediaPath);

    if (mediaType == MediaType.photo) {
      return MediaUploadResult(mediaUrl: mediaUrl, thumbnailUrl: mediaUrl);
    }

    final thumbnailUrl = await _uploadVideoThumbnail(
      userId: userId,
      videoPath: file.path,
    );
    return MediaUploadResult(
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl ?? mediaUrl,
    );
  }

  Future<void> createVisit({
    required String shopId,
    required String groupId,
    required String userId,
    required String mediaUrl,
    required MediaType mediaType,
    required String thumbnailUrl,
    required int rating,
    BrothType? brothType,
    String? memo,
  }) async {
    await supabase.from('visits').insert({
      'shop_id': shopId,
      'group_id': groupId,
      'user_id': userId,
      'media_url': mediaUrl,
      'media_type': mediaType.name,
      'thumbnail_url': thumbnailUrl,
      'broth_type': brothType?.name,
      'rating': rating,
      'memo': memo,
    });
  }

  /// 실패해도(영상 썸네일 생성 실패 등) 저장 흐름 자체는 막지 않고
  /// null을 반환한다 — 호출부는 원본 영상 URL을 썸네일 대신 쓴다.
  Future<String?> _uploadVideoThumbnail({
    required String userId,
    required String videoPath,
  }) async {
    final thumbnailBytes = await video_thumbnail.VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: video_thumbnail.ImageFormat.JPEG,
      maxWidth: _kThumbnailMaxWidth,
      quality: _kThumbnailQuality,
    );
    if (thumbnailBytes == null) return null;

    final thumbnailPath = '$userId/${_uniqueFileName()}_thumb.jpg';
    await supabase.storage
        .from(_kVisitMediaBucket)
        .uploadBinary(
          thumbnailPath,
          thumbnailBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return supabase.storage
        .from(_kVisitMediaBucket)
        .getPublicUrl(thumbnailPath);
  }

  String _uniqueFileName() => DateTime.now().microsecondsSinceEpoch.toString();

  String _extensionOf(String path, MediaType mediaType) {
    final segments = path.split('.');
    if (segments.length > 1 && segments.last.length <= 5) {
      return segments.last.toLowerCase();
    }
    if (mediaType == MediaType.photo) return 'jpg';
    return 'mp4';
  }

  String _contentTypeOf(MediaType mediaType) {
    if (mediaType == MediaType.photo) return 'image/jpeg';
    return 'video/mp4';
  }
}

class MediaUploadResult {
  const MediaUploadResult({required this.mediaUrl, required this.thumbnailUrl});

  final String mediaUrl;
  final String thumbnailUrl;
}

final visitRepository = VisitRepository();
