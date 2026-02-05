import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/theme/app_theme.dart';

class RatingStatsWidget extends StatelessWidget {
  final RatingStats stats;
  final VoidCallback? onSeeAllReviews;

  const RatingStatsWidget({
    super.key,
    required this.stats,
    this.onSeeAllReviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Avis et évaluations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              if (onSeeAllReviews != null && stats.totalReviews > 0)
                TextButton(
                  onPressed: onSeeAllReviews,
                  child: const Text(
                    'Voir tout',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (stats.totalReviews == 0)
            _buildNoReviews()
          else
            _buildStatsContent(),
        ],
      ),
    );
  }

  Widget _buildNoReviews() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aucun avis pour le moment',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Soyez le premier à laisser un avis !',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Note moyenne à gauche
        _buildAverageRating(),
        const SizedBox(width: 24),
        // Barres de progression à droite
        Expanded(child: _buildRatingBars()),
      ],
    );
  }

  Widget _buildAverageRating() {
    return Column(
      children: [
        Text(
          stats.averageRating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        RatingBarIndicator(
          rating: stats.averageRating,
          itemBuilder: (context, index) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemCount: 5,
          itemSize: 18,
          direction: Axis.horizontal,
        ),
        const SizedBox(height: 8),
        Text(
          '${stats.totalReviews} avis',
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBars() {
    return Column(
      children: [
        _buildRatingBar(5, stats.fiveStarCount),
        const SizedBox(height: 8),
        _buildRatingBar(4, stats.fourStarCount),
        const SizedBox(height: 8),
        _buildRatingBar(3, stats.threeStarCount),
        const SizedBox(height: 8),
        _buildRatingBar(2, stats.twoStarCount),
        const SizedBox(height: 8),
        _buildRatingBar(1, stats.oneStarCount),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count) {
    final percentage = stats.totalReviews > 0
        ? count / stats.totalReviews
        : 0.0;

    return Row(
      children: [
        // Étoiles
        Text(
          '$stars',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(
          Icons.star,
          size: 14,
          color: Colors.amber,
        ),
        const SizedBox(width: 8),
        // Barre de progression
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getColorForStars(stars),
              ),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Compte
        SizedBox(
          width: 30,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForStars(int stars) {
    switch (stars) {
      case 5:
        return const Color(0xFF4CAF50); // Vert
      case 4:
        return const Color(0xFF8BC34A); // Vert clair
      case 3:
        return const Color(0xFFFFC107); // Jaune
      case 2:
        return const Color(0xFFFF9800); // Orange
      case 1:
        return const Color(0xFFF44336); // Rouge
      default:
        return AppColors.textLight;
    }
  }
}

/// Widget compact pour afficher juste la note moyenne
class RatingStatsCompact extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final VoidCallback? onTap;

  const RatingStatsCompact({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 20,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($totalReviews)',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.textLight,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
