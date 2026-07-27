import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/region_conquest.dart';
import 'package:menlog/data/models/sig_boundary.dart';

const double _kBadgeFontSize = 9;
const double _kBadgeRadius = 8;

/// 전국 시/군/구 정복맵. 각 지역을 [ClipPath]로 잘라낸 타일 하나로 그린다.
///
/// 컬링/CustomPainter 기반 렌더링은 사진 로드 성능 이슈가 실제로 생기면
/// 그때 검토하기로 하고, 지금은 검증된 가장 단순한 방식(지역마다 위젯
/// 하나 + ClipPath)만 쓴다. 드릴다운(시/도 확대)은 이번 범위 밖이라 전국
/// 256개 시/군/구를 한 번에 그린다.
class ConquestMapView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bounds = _LatLngBounds.of(boundaries);

    return ColoredBox(
      color: MenlogColors.background,
      child: Center(
        child: AspectRatio(
          aspectRatio: bounds.aspectRatio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasSize = Size(
                constraints.maxWidth,
                constraints.maxHeight,
              );

              return Stack(
                children: boundaries
                    .map(
                      (boundary) => _RegionTile(
                        key: ValueKey(boundary.sggCode),
                        boundary: boundary,
                        summary: conquestBySggCode[boundary.sggCode],
                        bounds: bounds,
                        canvasSize: canvasSize,
                        onTap: () => onRegionTap(
                          boundary,
                          conquestBySggCode[boundary.sggCode],
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
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
    required this.onTap,
    super.key,
  });

  final SigBoundary boundary;
  final RegionConquestSummary? summary;
  final _LatLngBounds bounds;
  final Size canvasSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // 신안군·옹진군처럼 부속 도서가 많은 지역은 모든 섬을 다 그리면
    // 바운딩 박스가 흩어진 섬 전체를 감싸 탭 영역이 비정상적으로
    // 커지고, 화면에는 뜬금없는 점들이 흩어져 보인다. 지도는 본토/본섬
    // 하나만 대표로 그린다 — 정복 집계는 주소 문자열 매칭이라 폴리곤
    // 렌더링과 무관하게 정확하다.
    final largestRing = _largestRing(boundary.polygons);
    final projectedRings = [
      largestRing.map((point) => bounds.project(point, canvasSize)).toList(),
    ];

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
              painter: _RegionBorderPainter(localRings),
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

List<GeoPoint> _largestRing(List<List<GeoPoint>> polygons) {
  return polygons.reduce(
    (a, b) => _ringArea(a) >= _ringArea(b) ? a : b,
  );
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
  const _RegionBorderPainter(this.rings);

  final List<List<Offset>> rings;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MenlogColors.text.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

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
      oldDelegate.rings != rings;
}
