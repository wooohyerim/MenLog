import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:menlog/core/theme/menlog_colors.dart';
import 'package:menlog/data/models/region_conquest.dart';

const double _kThumbnailSize = 64;

/// 정복된 지역을 탭했을 때 뜨는 바텀시트 — 그 지역 매장별 방문 카드
/// (기획서 3.1 기능3).
class RegionVisitBottomSheet extends StatelessWidget {
  const RegionVisitBottomSheet({required this.summary, super.key});

  final RegionConquestSummary summary;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${summary.sidoName} ${summary.sggName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: MenlogColors.dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '매장 ${summary.shopCount}곳',
              style: const TextStyle(color: MenlogColors.text),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: summary.shops.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _ShopVisitCard(shop: summary.shops[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopVisitCard extends StatelessWidget {
  const _ShopVisitCard({required this.shop});

  final ShopVisitSummary shop;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: shop.thumbnailUrl,
            width: _kThumbnailSize,
            height: _kThumbnailSize,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) => const ColoredBox(
              color: MenlogColors.surface,
              child: SizedBox(width: _kThumbnailSize, height: _kThumbnailSize),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildDetails()),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          shop.shopName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: MenlogColors.dark,
          ),
        ),
        Text(
          '★' * shop.rating,
          style: const TextStyle(color: MenlogColors.primary, fontSize: 12),
        ),
        _buildMemo(),
        Text(
          _formatDate(shop.visitedAt),
          style: const TextStyle(color: MenlogColors.text, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMemo() {
    final memo = shop.memo;
    if (memo == null || memo.isEmpty) return const SizedBox.shrink();

    return Text(
      memo,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: MenlogColors.text, fontSize: 12),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }
}
