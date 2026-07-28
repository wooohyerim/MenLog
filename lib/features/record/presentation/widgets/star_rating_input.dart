import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';

const int _kStarCount = 5;
const double _kStarSize = 32;

/// 1~5점 별점 입력 위젯. 0이면 아직 선택 전(필수값 미입력 상태)이다.
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({
    required this.rating,
    required this.onChanged,
    super.key,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_kStarCount, _buildStar),
    );
  }

  Widget _buildStar(int index) {
    final starValue = index + 1;
    final isFilled = starValue <= rating;

    return IconButton(
      onPressed: () => onChanged(starValue),
      icon: Icon(
        _starIcon(isFilled),
        color: MenlogColors.primary,
        size: _kStarSize,
      ),
    );
  }

  IconData _starIcon(bool isFilled) {
    if (isFilled) return Icons.star;
    return Icons.star_border;
  }
}
