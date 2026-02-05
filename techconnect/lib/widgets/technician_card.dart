import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/models/technician.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/rating_form_dialog.dart';

class TechnicianCard extends StatelessWidget {
  final Technician technician;

  const TechnicianCard({super.key, required this.technician});

  Future<void> _showRatingDialog(BuildContext context) async {
    final token = context.read<AuthService>().token;
    final apiService = ApiService(token: token);

    // Vérifier si l'utilisateur a déjà donné un avis
    Rating? existingRating;
    try {
      existingRating = await apiService.getMyRatingForTechnician(technician.id);
    } catch (e) {
      // Ignorer l'erreur, l'utilisateur n'a pas encore donné d'avis
    }

    if (!context.mounted) return;

    final result = await showRatingFormDialog(
      context: context,
      technicianName: technician.name,
      existingRating: existingRating,
      onSubmit: (score, comment) async {
        final token = context.read<AuthService>().token;
        final apiService = ApiService(token: token);

        if (existingRating != null) {
          await apiService.updateRating(
            existingRating.id,
            RatingUpdateRequest(score: score, comment: comment),
          );
        } else {
          await apiService.createRating(
            RatingRequest(
              technicianId: technician.id,
              score: score,
              comment: comment,
            ),
          );
        }
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingRating != null
                ? 'Avis modifié avec succès'
                : 'Avis publié avec succès ! Merci 🎉',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => context.push('/technician/${technician.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          technician.domain,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.textLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              technician.city,
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: technician.rating,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 16,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${technician.reviewCount})',
                              style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRatingDialog(context),
                      icon: const Icon(Icons.star_outline, size: 18),
                      label: const Text('Évaluer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/technician/${technician.id}'),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Voir profil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primaryVeryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: technician.profileImageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                technician.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  );
                },
              ),
            )
          : const Icon(
              Icons.person,
              size: 40,
              color: AppColors.primary,
            ),
    );
  }
}
