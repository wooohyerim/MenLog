import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

/// 검색 결과가 없을 때 매장을 수동으로 등록하는 폼. 이름/주소를 모두
/// 입력해야 "선택 완료"가 활성화된다 — 주소는 지도 탭 정복맵의
/// `RegionMatcher`가 지역을 판정하는 유일한 근거라 비워둘 수 없다.
class ManualShopForm extends StatefulWidget {
  const ManualShopForm({
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final void Function(String name, String address) onSubmit;
  final VoidCallback onCancel;

  @override
  State<ManualShopForm> createState() => _ManualShopFormState();
}

class _ManualShopFormState extends State<ManualShopForm> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty;

  VoidCallback? get _onSubmitPressed {
    if (!_canSubmit) return null;
    return () => widget.onSubmit(
      _nameController.text.trim(),
      _addressController.text.trim(),
    );
  }

  void _handleFieldChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('매장 직접 입력', style: TextStyle(color: MenlogColors.dark)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          onChanged: _handleFieldChanged,
          style: const TextStyle(color: MenlogColors.dark),
          decoration: const InputDecoration(hintText: '매장 이름'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          onChanged: _handleFieldChanged,
          style: const TextStyle(color: MenlogColors.dark),
          decoration: const InputDecoration(hintText: '주소'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: widget.onCancel,
                child: const Text('취소'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _onSubmitPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MenlogColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('선택 완료'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
