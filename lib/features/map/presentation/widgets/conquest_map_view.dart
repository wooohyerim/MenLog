import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/region_conquest.dart';
import 'package:menlog/data/models/sig_boundary.dart';

const double _kBadgeFontSize = 9;
const double _kBadgeRadius = 8;

/// 전국이 점처럼 보일 만큼 축소되는 것을 막는다 — 전국 지도가 화면에 꽉
/// 차는 배율(1.0) 밑으로는 못 내려가게 한다. 초기 화면도 이 배율로 시작해
/// 전국이 한 번에 보이게 한다.
const double _kMinScale = 1.0;

/// 폴리곤 하나가 화면을 다 채울 만큼 과도하게 확대되는 것을 막는다.
const double _kMaxScale = 20.0;

/// 전국 지도가 화면에 꽉 차는 배율(스케일 1)일 때의 경계선 굵기. 화면
/// 좌표계 기준으로 그려지는 게 아니라 InteractiveViewer가 확대할 콘텐츠
/// 좌표계 기준이라, 그대로 두면 확대할수록 선도 같이 굵어진다 — 실제
/// 화면에 보이는 굵기가 항상 이 값으로 고정되도록 현재 스케일만큼
/// 나눠서 그린다.
const double _kBaseBorderStrokeWidth = 0.6;

/// 전국 시/군/구 정복맵. 각 지역을 [ClipPath]로 잘라낸 타일 하나로 그린다.
///
/// 컬링/CustomPainter 기반 렌더링은 사진 로드 성능 이슈가 실제로 생기면
/// 그때 검토하기로 하고, 지금은 검증된 가장 단순한 방식(지역마다 위젯
/// 하나 + ClipPath)만 쓴다. 드릴다운(시/도 확대) 대신, 팬/핀치줌이 가능한
/// [InteractiveViewer]로 감싸 사용자가 직접 원하는 지역을 확대해서 본다.
///
/// 화면 전체를 채우는 배경 레이어로 쓰인다 — 자체 배경/사각 테두리 없이
/// 화면 크기 그대로 [InteractiveViewer]를 채우고, 헤더/검색창/하단 탭바는
/// 이 위에 반투명 그라디언트로 겹쳐 보이도록 [HomeMapScreen] 쪽에서
/// 처리한다. 뷰포트(화면 전체 크기)와 콘텐츠(대한민국 실제 비율을 유지한
/// 지도 자체 크기)가 서로 다를 수 있어 구분해서 계산한다.
class ConquestMapView extends StatefulWidget {
  const ConquestMapView({
    required this.boundaries,
    required this.conquestBySggCode,
    required this.onRegionTap,
    super.key,
  });

  final List<SigBoundary> boundaries;
  final Map<String, RegionConquestSummary> conquestBySggCode;
  final void Function(SigBoundary boundary, RegionConquestSummary? summary)
  onRegionTap;

  @override
  State<ConquestMapView> createState() => _ConquestMapViewState();
}

class _ConquestMapViewState extends State<ConquestMapView> {
  final TransformationController _transformationController =
      TransformationController();
  bool _initialFocusApplied = false;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bounds = _LatLngBounds.of(widget.boundaries);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = constraints.biggest;
        final canvasSize = _fitSize(viewportSize, bounds.aspectRatio);

        _scheduleInitialFocus(bounds, viewportSize, canvasSize);

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: _kMinScale,
          maxScale: _kMaxScale,
          child: SizedBox(
            width: canvasSize.width,
            height: canvasSize.height,
            child: AnimatedBuilder(
              animation: _transformationController,
              builder: (context, child) {
                final currentScale = _transformationController.value
                    .getMaxScaleOnAxis();

                return Stack(
                  children: widget.boundaries
                      .map(
                        (boundary) => _RegionTile(
                          key: ValueKey(boundary.sggCode),
                          boundary: boundary,
                          summary: widget.conquestBySggCode[boundary.sggCode],
                          bounds: bounds,
                          canvasSize: canvasSize,
                          currentScale: currentScale,
                          onTap: () => widget.onRegionTap(
                            boundary,
                            widget.conquestBySggCode[boundary.sggCode],
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// 뷰포트 안에 [aspectRatio]를 그대로 유지한 채 최대한 크게 들어가는
  /// 크기를 계산한다 — `AspectRatio` 위젯의 contain 동작과 동일. 뷰포트가
  /// 화면 전체(세로로 긴 휴대폰 비율)라 대한민국 지도 비율과 달라도, 지도
  /// 모양이 눌리거나 늘어나지 않게 이 크기로 콘텐츠를 그린다.
  Size _fitSize(Size viewport, double aspectRatio) {
    final viewportAspect = viewport.width / viewport.height;
    if (viewportAspect > aspectRatio) {
      final height = viewport.height;
      return Size(height * aspectRatio, height);
    }
    final width = viewport.width;
    return Size(width, width / aspectRatio);
  }

  /// 최초 레이아웃 직후 딱 한 번만 전국이 화면 정중앙에 오도록 초기 카메라
  /// 위치를 적용한다(배율은 [_kMinScale] — 전국이 화면에 꽉 차는 배율).
  /// 이후 리빌드(그룹 전환, 정복 데이터 갱신 등)에서는 사용자가 직접
  /// 조작한 팬/줌 상태를 건드리지 않는다. [viewportSize]는 이 위젯을
  /// 감싸는 [LayoutBuilder]가 전달한 실제 렌더 크기이므로(헤더/탭바를
  /// 제외한 지도 영역 그대로) 화면 크기를 하드코딩하지 않는다.
  void _scheduleInitialFocus(
    _LatLngBounds bounds,
    Size viewportSize,
    Size canvasSize,
  ) {
    if (_initialFocusApplied) return;
    _initialFocusApplied = true;

    const scale = _kMinScale;
    final contentCenter = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final viewportCenter = Offset(
      viewportSize.width / 2,
      viewportSize.height / 2,
    );
    final tx = viewportCenter.dx - scale * contentCenter.dx;
    final ty = viewportCenter.dy - scale * contentCenter.dy;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _transformationController.value = Matrix4.identity()
        ..translateByDouble(tx, ty, 0, 1)
        ..scaleByDouble(scale, scale, scale, 1);
    });
  }
}

class _LatLngBounds {
  const _LatLngBounds({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  factory _LatLngBounds.of(List<SigBoundary> boundaries) {
    final points = boundaries
        .expand((boundary) => boundary.polygons)
        .expand((ring) => ring)
        .toList(growable: false);

    final lats = points.map((point) => point.lat);
    final lngs = points.map((point) => point.lng);

    return _LatLngBounds(
      minLat: lats.reduce(math.min),
      maxLat: lats.reduce(math.max),
      minLng: lngs.reduce(math.min),
      maxLng: lngs.reduce(math.max),
    );
  }

  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  /// 위도 보정(cos)까지 반영한 가로/세로 비율 — 대략적인 실제 모양 유지용.
  double get aspectRatio {
    final meanLatRad = ((minLat + maxLat) / 2) * math.pi / 180;
    final width = (maxLng - minLng) * math.cos(meanLatRad);
    final height = maxLat - minLat;
    return width / height;
  }

  Offset project(GeoPoint point, Size canvasSize) {
    final dx = (point.lng - minLng) / (maxLng - minLng) * canvasSize.width;
    final dy = (maxLat - point.lat) / (maxLat - minLat) * canvasSize.height;
    return Offset(dx, dy);
  }
}

class _RegionTile extends StatelessWidget {
  const _RegionTile({
    required this.boundary,
    required this.summary,
    required this.bounds,
    required this.canvasSize,
    required this.currentScale,
    required this.onTap,
    super.key,
  });

  final SigBoundary boundary;
  final RegionConquestSummary? summary;
  final _LatLngBounds bounds;
  final Size canvasSize;
  final double currentScale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 신안군·옹진군처럼 부속 도서가 많은 지역은 모든 섬을 다 그리면
    // 바운딩 박스가 흩어진 섬 전체를 감싸 탭 영역이 비정상적으로
    // 커지고, 화면에는 뜬금없는 점들이 흩어져 보인다. 그렇다고 딱 1개만
    // 남기면 안산시단원구(본토 54km² + 대부도 46km²처럼 비슷한 크기 두
    // 덩어리로 이뤄진 지역)에서 큰 섬이 통째로 빠져 지도 한가운데 구멍이
    // 생긴다 — 가장 큰 2개까지만 그려서 두 문제를 함께 완화한다. 정복
    // 집계는 주소 문자열 매칭이라 폴리곤 렌더링과 무관하게 정확하다.
    final keptRings = _largestRings(boundary.polygons);
    final projectedRings = keptRings
        .map(
          (ring) => ring
              .map((point) => bounds.project(point, canvasSize))
              .toList(),
        )
        .toList();

    final allPoints = projectedRings.expand((ring) => ring);
    final minX = allPoints.map((point) => point.dx).reduce(math.min);
    final maxX = allPoints.map((point) => point.dx).reduce(math.max);
    final minY = allPoints.map((point) => point.dy).reduce(math.min);
    final maxY = allPoints.map((point) => point.dy).reduce(math.max);

    final localRings = projectedRings
        .map(
          (ring) => ring
              .map((point) => Offset(point.dx - minX, point.dy - minY))
              .toList(),
        )
        .toList();

    final tileSize = Size(
      math.max(maxX - minX, 1),
      math.max(maxY - minY, 1),
    );

    return Positioned(
      left: minX,
      top: minY,
      width: tileSize.width,
      height: tileSize.height,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Stack(
          children: [
            ClipPath(
              clipper: _RegionClipper(localRings),
              child: SizedBox.expand(child: _buildContent()),
            ),
            CustomPaint(
              size: tileSize,
              painter: _RegionBorderPainter(
                localRings,
                strokeWidth: _kBaseBorderStrokeWidth / currentScale,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final regionSummary = summary;
    if (regionSummary == null) {
      return const ColoredBox(color: MenlogColors.mapUnconquered);
    }

    final showBadge = regionSummary.shopCount >= 2;

    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: MenlogColors.primary),
        CachedNetworkImage(
          imageUrl: regionSummary.representativePhotoUrl,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => const SizedBox.shrink(),
        ),
        if (showBadge) _buildBadge(regionSummary.shopCount),
      ],
    );
  }

  Widget _buildBadge(int shopCount) {
    return Positioned(
      right: 2,
      bottom: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: MenlogColors.dark,
          borderRadius: BorderRadius.circular(_kBadgeRadius),
        ),
        child: Text(
          '+${shopCount - 1}',
          style: const TextStyle(
            fontSize: _kBadgeFontSize,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// 면적 기준 상위 [_kMaxPartsPerRegion]개 파트만 남긴다. 1개만 남기면
/// 안산시단원구처럼 비슷한 크기 두 덩어리로 이뤄진 지역에서 하나가
/// 통째로 사라져 구멍이 생기고, 전부 다 그리면 신안군처럼 부속 도서가
/// 많은 지역이 어수선해진다.
const int _kMaxPartsPerRegion = 2;

List<List<GeoPoint>> _largestRings(List<List<GeoPoint>> polygons) {
  final sorted = List<List<GeoPoint>>.of(polygons)
    ..sort((a, b) => _ringArea(b).compareTo(_ringArea(a)));
  return sorted.take(_kMaxPartsPerRegion).toList();
}

/// 신발끈 공식(shoelace formula). 위경도를 그대로 x/y로 써도 같은
/// 지역 내 파트끼리 면적 크기를 비교하는 용도로는 충분하다.
double _ringArea(List<GeoPoint> ring) {
  final n = ring.length;
  final terms = List<double>.generate(n, (i) {
    final p1 = ring[i];
    final p2 = ring[(i + 1) % n];
    return p1.lng * p2.lat - p2.lng * p1.lat;
  });
  return terms.fold<double>(0, (sum, term) => sum + term).abs() / 2;
}

class _RegionClipper extends CustomClipper<Path> {
  const _RegionClipper(this.rings);

  final List<List<Offset>> rings;

  @override
  Path getClip(Size size) {
    return rings.where((ring) => ring.isNotEmpty).fold<Path>(Path(), (
      path,
      ring,
    ) {
      path.addPolygon(ring, true);
      return path;
    });
  }

  @override
  bool shouldReclip(covariant _RegionClipper oldClipper) =>
      oldClipper.rings != rings;
}

/// 지역 경계선. 채색만으로는 서울 25개 구처럼 촘촘한 지역이 옆 지역과
/// 뭉쳐 보이므로, 각 폴리곤 테두리를 얇게 그어 구분한다.
class _RegionBorderPainter extends CustomPainter {
  const _RegionBorderPainter(this.rings, {required this.strokeWidth});

  final List<List<Offset>> rings;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MenlogColors.text.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = rings.where((ring) => ring.isNotEmpty).fold<Path>(Path(), (
      path,
      ring,
    ) {
      path.addPolygon(ring, true);
      return path;
    });

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RegionBorderPainter oldDelegate) =>
      oldDelegate.rings != rings ||
      oldDelegate.strokeWidth != strokeWidth;
}
