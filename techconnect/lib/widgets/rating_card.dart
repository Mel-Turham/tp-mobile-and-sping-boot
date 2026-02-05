import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/theme/app_theme.dart';

class RatingCard extends StatelessWidget {
  final Rating rating;
  final bool showTechnicianName;
  final bool isCurrentUserRating;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const RatingCard({
    super.key,
    required this.rating,
    this.showTechnicianName = false,
    this.isCurrentUserRating = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
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
        border: isCurrentUserRating
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(rating.userName),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Nom et date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rating.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (isCurrentUserRating)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryVeryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Mon avis',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(rating.createdAt),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Actions pour l'utilisateur actuel
              if (isCurrentUserRating && (onEdit != null || onDelete != null))
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                  onSelected: (value) {
                    if (value == 'edit' && onEdit != null) {
                      onEdit!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: AppColors.primary),
                            SizedBox(width: 8),
                            Text('Modifier'),
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Rating stars
          Row(
            children: [
              RatingBarIndicator(
                rating: rating.score.toDouble(),
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 20,
                direction: Axis.horizontal,
              ),
              const SizedBox(width: 8),
              Text(
                '${rating.score}/5',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          // Nom du technicien si nécessaire
          if (showTechnicianName) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  'Pour: ${rating.technicianName}',
                  style: const TextStyle(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          // Commentaire
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rating.comment!,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
          // Indicateur de modification
          if (rating.updatedAt != null &&
              rating.updatedAt!.isAfter(rating.createdAt)) ...[
            const SizedBox(height: 8),
            Text(
              'Modifié le ${dateFormat.format(rating.updatedAt!)}',
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
