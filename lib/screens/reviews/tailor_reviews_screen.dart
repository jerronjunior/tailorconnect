import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../models/review_model.dart';
import '../../providers/order_providers.dart';
import '../../providers/review_providers.dart';
import '../../providers/tailor_providers.dart';

/// Shows the tailor's overall rating and every review left by customers.
class TailorReviewsScreen extends ConsumerWidget {
  const TailorReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(tailorProfileProvider);
    final reviewsAsync = ref.watch(tailorReviewsProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Reviews', style: TextStyle(color: Colors.white)),
      ),
      body: reviewsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.goldAccent)),
        error: (e, _) => Center(
          child: Text('Could not load reviews: $e',
              style: const TextStyle(color: Colors.white70)),
        ),
        data: (reviews) {
          final profile = profileAsync.valueOrNull;
          return ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              _RatingSummary(
                ratingAvg: profile?.ratingAvg ?? 0,
                ratingCount: profile?.ratingCount ?? 0,
              ),
              const SizedBox(height: AppSizes.lg),
              if (reviews.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSizes.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(LucideIcons.star, size: 56, color: Colors.white24),
                        SizedBox(height: AppSizes.md),
                        Text('No reviews yet', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                )
              else
                for (final review in reviews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: _ReviewCard(review: review),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.ratingAvg, required this.ratingCount});

  final double ratingAvg;
  final int ratingCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Text(
            ratingAvg.toStringAsFixed(1),
            style: const TextStyle(
                color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: AppSizes.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StarRow(rating: ratingAvg),
              const SizedBox(height: 4),
              Text(
                ratingCount == 0
                    ? 'No reviews yet'
                    : '$ratingCount ${ratingCount == 1 ? 'review' : 'reviews'}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Icon(
          half ? LucideIcons.starHalf : LucideIcons.star,
          size: 18,
          color: (filled || half) ? AppColors.goldAccent : Colors.white24,
        );
      }),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.review});

  final ReviewModel review;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerName = ref.watch(customerNameProvider(review.customerId));

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHighlight,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  customerName.when(
                    data: (name) => name,
                    loading: () => '…',
                    error: (_, __) => 'Customer',
                  ),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              if (review.createdAt != null)
                Text(
                  DateFormat('MMM d, yyyy').format(review.createdAt!),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 4),
          _StarRow(rating: review.rating),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(review.comment, style: const TextStyle(color: Colors.white70)),
          ],
        ],
      ),
    );
  }
}
