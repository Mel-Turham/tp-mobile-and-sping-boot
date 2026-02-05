import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/rating_card.dart';
import 'package:techconnect/widgets/rating_form_dialog.dart';
import 'package:techconnect/widgets/rating_stats_widget.dart';

class TechnicianReviewsScreen extends StatefulWidget {
  final int technicianId;
  final String technicianName;

  const TechnicianReviewsScreen({
    super.key,
    required this.technicianId,
    required this.technicianName,
  });

  @override
  State<TechnicianReviewsScreen> createState() => _TechnicianReviewsScreenState();
}

class _TechnicianReviewsScreenState extends State<TechnicianReviewsScreen> {
  final List<Rating> _ratings = [];
  RatingStats? _stats;
  Rating? _myRating;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;
  int? _currentUserId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreRatings();
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = context.read<AuthService>();
      final token = authService.token;
      final apiService = ApiService(token: token);

      // Charger l'utilisateur actuel pour identifier son avis
      final currentUser = await apiService.getCurrentUser();
      _currentUserId = currentUser.id;

      // Charger les statistiques et les avis en parallèle
      final results = await Future.wait([
        apiService.getTechnicianRatingStats(widget.technicianId),
        apiService.getTechnicianRatings(widget.technicianId, page: 0),
        apiService.getMyRatingForTechnician(widget.technicianId),
      ]);

      if (mounted) {
        setState(() {
          _stats = results[0] as RatingStats;
          _ratings.addAll(results[1] as List<Rating>);
          _myRating = results[2] as Rating?;
          _hasMore = (results[1] as List<Rating>).length == 10;
          _currentPage = 1;
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

  Future<void> _loadMoreRatings() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);
      final newRatings = await apiService.getTechnicianRatings(
        widget.technicianId,
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          _ratings.addAll(newRatings);
          _hasMore = newRatings.length == 10;
          _currentPage++;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _ratings.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    await _loadData();
  }

  Future<void> _showRatingDialog({Rating? existingRating}) async {
    final result = await showRatingFormDialog(
      context: context,
      technicianName: widget.technicianName,
      existingRating: existingRating,
      onSubmit: (score, comment) async {
        final token = context.read<AuthService>().token;
        final apiService = ApiService(token: token);

        if (existingRating != null) {
          // Mise à jour
          await apiService.updateRating(
            existingRating.id,
            RatingUpdateRequest(score: score, comment: comment),
          );
        } else {
          // Création
          await apiService.createRating(
            RatingRequest(
              technicianId: widget.technicianId,
              score: score,
              comment: comment,
            ),
          );
        }
      },
    );

    if (result == true && mounted) {
      await _refresh();
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

        await _refresh();
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
      appBar: AppBar(
        title: Text('Avis - ${widget.technicianName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: _myRating == null && !_isLoading
          ? FloatingActionButton.extended(
              onPressed: () => _showRatingDialog(),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.rate_review),
              label: const Text('Donner un avis'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erreur: $_error',
                textAlign: TextAlign.center,
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
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Statistiques
          if (_stats != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: RatingStatsWidget(stats: _stats!),
              ),
            ),

          // Mon avis (en premier si existe)
          if (_myRating != null)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Mon avis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  RatingCard(
                    rating: _myRating!,
                    isCurrentUserRating: true,
                    onEdit: () => _showRatingDialog(existingRating: _myRating),
                    onDelete: () => _deleteRating(_myRating!),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(),
                  ),
                ],
              ),
            ),

          // Titre des autres avis
          if (_ratings.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  _myRating != null ? 'Autres avis' : 'Tous les avis',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

          // Liste des avis (filtrer mon avis si déjà affiché)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final filteredRatings = _myRating != null
                    ? _ratings.where((r) => r.id != _myRating!.id).toList()
                    : _ratings;

                if (index >= filteredRatings.length) {
                  if (_hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return null;
                }

                final rating = filteredRatings[index];
                return RatingCard(
                  rating: rating,
                  isCurrentUserRating: rating.userId == _currentUserId,
                  onEdit: rating.userId == _currentUserId
                      ? () => _showRatingDialog(existingRating: rating)
                      : null,
                  onDelete: rating.userId == _currentUserId
                      ? () => _deleteRating(rating)
                      : null,
                );
              },
              childCount: (_myRating != null
                      ? _ratings.where((r) => r.id != _myRating!.id).length
                      : _ratings.length) +
                  (_hasMore ? 1 : 0),
            ),
          ),

          // Message si aucun avis
          if (_ratings.isEmpty && _myRating == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 64,
                      color: AppColors.textLight.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun avis pour le moment',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Soyez le premier à donner votre avis !',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Espacement en bas
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }
}
