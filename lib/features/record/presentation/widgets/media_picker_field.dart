import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/visit.dart';

const double _kFieldHeight = 180;
const double _kFieldRadius = 12;
const double _kRemoveButtonSize = 28;

/// 사용자가 고른 사진/영상 원본 파일. 업로드는 저장 버튼을 누를 때
/// 일어나므로, 이 시점에는 아직 로컬 파일 참조만 들고 있는다 — 업로드가
/// 실패해도 이 값이 그대로 남아 재시도할 수 있다.
class PickedMedia {
  const PickedMedia({required this.file, required this.mediaType});

  final XFile file;
  final MediaType mediaType;
}

/// 기록하기 화면의 사진/영상 첨부 필드.
class MediaPickerField extends StatelessWidget {
  const MediaPickerField({
    required this.picked,
    required this.onChanged,
    super.key,
  });

  final PickedMedia? picked;
  final ValueChanged<PickedMedia?> onChanged;

  @override
  Widget build(BuildContext context) {
    final current = picked;
    if (current == null) return _buildEmptyState(context);
    return _buildPreview(context, current);
  }

  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      borderRadius: BorderRadius.circular(_kFieldRadius),
      child: Container(
        height: _kFieldHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: MenlogColors.surface,
          borderRadius: BorderRadius.circular(_kFieldRadius),
          border: Border.all(color: MenlogColors.borderPrimarySoft),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: MenlogColors.text),
            SizedBox(height: 8),
            Text('사진/영상 첨부', style: TextStyle(color: MenlogColors.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context, PickedMedia current) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(_kFieldRadius),
          child: SizedBox(
            height: _kFieldHeight,
            width: double.infinity,
            child: _buildPreviewContent(current),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: _RemoveButton(onTap: () => onChanged(null)),
        ),
      ],
    );
  }

  Widget _buildPreviewContent(PickedMedia current) {
    if (current.mediaType == MediaType.photo) {
      return Image.file(File(current.file.path), fit: BoxFit.cover);
    }

    return Container(
      color: MenlogColors.dark,
      child: const Center(
        child: Icon(Icons.videocam, color: Colors.white, size: 40),
      ),
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    final choice = await showModalBottomSheet<_MediaPickChoice>(
      context: context,
      backgroundColor: MenlogColors.background,
      builder: (context) => const _MediaPickSheet(),
    );
    if (choice == null) return;
    if (!context.mounted) return;

    final picker = ImagePicker();
    if (choice == _MediaPickChoice.photo) {
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return;
      onChanged(PickedMedia(file: file, mediaType: MediaType.photo));
      return;
    }

    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    onChanged(PickedMedia(file: file, mediaType: MediaType.video));
  }
}

enum _MediaPickChoice { photo, video }

class _MediaPickSheet extends StatelessWidget {
  const _MediaPickSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_outlined, color: MenlogColors.dark),
            title: const Text('사진 선택', style: TextStyle(color: MenlogColors.dark)),
            onTap: () => Navigator.of(context).pop(_MediaPickChoice.photo),
          ),
          ListTile(
            leading: const Icon(
              Icons.videocam_outlined,
              color: MenlogColors.dark,
            ),
            title: const Text('동영상 선택', style: TextStyle(color: MenlogColors.dark)),
            onTap: () => Navigator.of(context).pop(_MediaPickChoice.video),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_kRemoveButtonSize / 2),
      child: Container(
        width: _kRemoveButtonSize,
        height: _kRemoveButtonSize,
        decoration: const BoxDecoration(
          color: MenlogColors.dark,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 16),
      ),
    );
  }
}
