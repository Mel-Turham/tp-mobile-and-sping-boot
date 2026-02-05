import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/models/technician.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';
import 'package:techconnect/widgets/rating_card.dart';
import 'package:techconnect/widgets/rating_form_dialog.dart';
import 'package:techconnect/widgets/rating_stats_widget.dart';

class TechnicianDetailScreen extends StatefulWidget {
  final int id;

  const TechnicianDetailScreen({super.key, required this.id});

  @override
  State<TechnicianDetailScreen> createState() => _TechnicianDetailScreenState();
}

class _TechnicianDetailScreenState extends State<TechnicianDetailScreen> {
  Technician? _technician;
  RatingStats? _ratingStats;
  List<Rating> _recentRatings = [];
  Rating? _myRating;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);

      // Charger les données en parallèle
      final results = await Future.wait([
        apiService.getTechnicianById(widget.id),
        apiService.getTechnicianRatingStats(widget.id),
        apiService.getTechnicianRatings(widget.id, page: 0, size: 3),
        apiService.getMyRatingForTechnician(widget.id),
      ]);

      if (mounted) {
        setState(() {
          _technician = results[0] as Technician;
          _ratingStats = results[1] as RatingStats;
          _recentRatings = results[2] as List<Rating>;
          _myRating = results[3] as Rating?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showRatingDialog({Rating? existingRating}) async {
    if (_technician == null) return;

    final result = await showRatingFormDialog(
      context: context,
      technicianName: _technician!.name,
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
              technicianId: widget.id,
              score: score,
              comment: comment,
            ),
          );
        }
      },
    );

    if (result == true && mounted) {
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existingRating != null
                  ? 'Avis modifié avec succès'
                  : 'Avis publié avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _deleteRating(Rating rating) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'avis'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer votre avis ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final token = context.read<AuthService>().token;
        final apiService = ApiService(token: token);
        await apiService.deleteRating(rating.id);

        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Avis supprimé'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.primaryVeryLight,
                child: _technician?.profileImageUrl != null
                    ? Image.network(
                        _technician!.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.person,
                              size: 100,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          size: 100,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Text(
                                'Erreur: $_error',
                                style: const TextStyle(color: AppColors.error),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadData,
                                child: const Text('Réessayer'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _technician != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Bouton pour donner un avis
                    if (_myRating == null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRatingDialog(),
                          icon: const Icon(Icons.star_outline),
                          label: const Text('Donner un avis'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRatingDialog(existingRating: _myRating),
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier mon avis'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    // Bouton contacter
                    Expanded(
                      child: CustomButton(
                        text: 'Contacter',
                        icon: Icons.message,
                        onPressed: () {
                          context.push(
                            '/contact',
                            extra: _technician!.email,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildContent() {
    final technician = _technician!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom et domaine
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  technician.name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 28,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryVeryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  technician.domain,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Note avec lien vers les avis
          InkWell(
            onTap: () {
              context.push(
                '/technician/${widget.id}/reviews',
                extra: {'name': technician.name},
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  RatingBarIndicator(
                    rating: _ratingStats?.averageRating ?? technician.rating,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 24,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_ratingStats?.averageRating ?? technician.rating).toStringAsFixed(1)} (${_ratingStats?.totalReviews ?? technician.reviewCount} avis)',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Informations de contact
          _buildInfoCard(
            icon: Icons.location_on,
            title: 'Localisation',
            content: technician.city,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.phone,
            title: 'Téléphone',
            content: technician.phone,
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            icon: Icons.email,
            title: 'Email',
            content: technician.email,
          ),

          // Description
          if (technician.description != null && technician.description!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'À propos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              technician.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],

          const SizedBox(height: 24),

          // Section des avis
          _buildRatingsSection(),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildRatingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Statistiques
        if (_ratingStats != null)
          RatingStatsWidget(
            stats: _ratingStats!,
            onSeeAllReviews: () {
              context.push(
                '/technician/${widget.id}/reviews',
                extra: {'name': _technician!.name},
              );
            },
          ),

        // Mon avis
        if (_myRating != null) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mon avis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showRatingDialog(existingRating: _myRating),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Modifier'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RatingCard(
            rating: _myRating!,
            isCurrentUserRating: true,
            onEdit: () => _showRatingDialog(existingRating: _myRating),
            onDelete: () => _deleteRating(_myRating!),
          ),
        ],

        // Avis récents
        if (_recentRatings.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _myRating != null ? 'Autres avis' : 'Avis récents',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              if (_ratingStats != null && _ratingStats!.totalReviews > 3)
                TextButton(
                  onPressed: () {
                    context.push(
                      '/technician/${widget.id}/reviews',
                      extra: {'name': _technician!.name},
                    );
                  },
                  child: const Text('Voir tout'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Afficher les avis récents (filtrer mon avis si présent)
          ..._recentRatings
              .where((r) => _myRating == null || r.id != _myRating!.id)
              .take(3)
              .map((rating) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RatingCard(rating: rating),
                  )),
        ],

        // Bouton pour donner un avis si pas encore fait
        if (_myRating == null && _ratingStats != null && _ratingStats!.totalReviews == 0) ...[
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => _showRatingDialog(),
              icon: const Icon(Icons.rate_review),
              label: const Text('Soyez le premier à donner un avis'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                ),
              ),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
