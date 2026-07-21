import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:menlog/core/constants/env.dart';
import 'package:menlog/core/constants/map_constants.dart';
import 'package:menlog/core/theme/map_style.dart';
import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/shared/widgets/menlog_header.dart';

const double _kSearchBarHeight = 34;
const double _kSearchBarRadius = 17;
const double _kSpacingSmall = 8;
const double _kZoomControlMargin = 16;
const double _kZoomControlWidth = 36;
const double _kZoomControlButtonHeight = 40;
const double _kZoomControlRadius = 12;

/// 지도 탭 홈 화면.
///
/// "기록하기"는 이 화면이 아니라 [MainTabShell]의 하단 탭바 중앙 FAB로
/// 제공됩니다.
class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _handleZoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _handleZoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: MenlogColors.background,
      child: SafeArea(
        child: Column(
          children: [
            const MenlogHeader(friendGroupMemberCount: 3),
            const SizedBox(height: _kSpacingSmall),
            _buildSearchField(),
            const SizedBox(height: _kSpacingSmall),
            Expanded(child: _buildMap()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: _kSearchBarHeight,
        child: TextField(
          decoration: InputDecoration(
            hintText: '가게 이름으로 검색',
            filled: true,
            fillColor: MenlogColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_kSearchBarRadius),
              borderSide: const BorderSide(
                color: MenlogColors.borderPrimarySoft,
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    if (Env.googleMapsApiKey.isEmpty) return _buildMapKeyMissing();

    return Stack(
      children: [
        GoogleMap(
          style: MapStyle.craftPaper,
          initialCameraPosition: const CameraPosition(
            target: MapConstants.defaultCenter,
            zoom: MapConstants.defaultZoom,
          ),
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            controller.animateCamera(
              CameraUpdate.newLatLngBounds(MapConstants.seoulBounds, 16),
            );
          },
        ),
        Positioned(
          right: _kZoomControlMargin,
          bottom: _kZoomControlMargin,
          child: _MapZoomControls(
            onZoomIn: _handleZoomIn,
            onZoomOut: _handleZoomOut,
          ),
        ),
      ],
    );
  }

  Widget _buildMapKeyMissing() {
    return const ColoredBox(
      color: MenlogColors.mapPlaceholder,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'GOOGLE_MAPS_API_KEY가 설정되지 않았습니다.\n.env 파일에 값을 입력해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

/// 지도 우측 하단에 표시되는 확대/축소 버튼.
/// 안드로이드 기본 줌 컨트롤이 투박해 보여 크래프트지 테마에 맞게 직접 그렸습니다.
class _MapZoomControls extends StatelessWidget {
  const _MapZoomControls({required this.onZoomIn, required this.onZoomOut});

  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: MenlogColors.surface,
        borderRadius: BorderRadius.circular(_kZoomControlRadius),
        border: Border.all(color: MenlogColors.borderPrimarySoft, width: 0.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: _kZoomControlWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildButton(icon: Icons.add, onTap: onZoomIn),
            const Divider(
              height: 1,
              thickness: 0.5,
              color: MenlogColors.borderPrimaryFaint,
            ),
            _buildButton(icon: Icons.remove, onTap: onZoomOut),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: _kZoomControlButtonHeight,
        child: Icon(icon, size: 20, color: MenlogColors.text),
      ),
    );
  }
}
