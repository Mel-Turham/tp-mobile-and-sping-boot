import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/rating_card.dart';
import 'package:techconnect/widgets/rating_form_dialog.dart';

class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  final List<Rating> _ratings = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadRatings();
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

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);
      final ratings = await apiService.getMyRatings(page: 0);

      if (mounted) {
        setState(() {
          _ratings.clear();
          _ratings.addAll(ratings);
          _hasMore = ratings.length == 10;
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
      final newRatings = await apiService.getMyRatings(page: _currentPage);

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
    await _loadRatings();
  }

  Future<void> _editRating(Rating rating) async {
    final result = await showRatingFormDialog(
      context: context,
      technicianName: rating.technicianName,
      existingRating: rating,
      onSubmit: (score, comment) async {
        final token = context.read<AuthService>().token;
        final apiService = ApiService(token: token);
        await apiService.updateRating(
          rating.id,
          RatingUpdateRequest(score: score, comment: comment),
        );
      },
    );

    if (result == true && mounted) {
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avis modifié avec succès'),
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
        content: Text(
          'Êtes-vous sûr de vouloir supprimer votre avis pour ${rating.technicianName} ? Cette action est irréversible.',
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
        title: const Text('Mes avis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(),
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
                onPressed: _loadRatings,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ratings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 80,
                color: AppColors.textLight.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Vous n\'avez pas encore donné d\'avis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Recherchez un technicien et partagez votre expérience !',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/search'),
                icon: const Icon(Icons.search),
                label: const Text('Rechercher un technicien'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _ratings.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _ratings.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final rating = _ratings[index];
          return InkWell(
            onTap: () {
              // Naviguer vers le profil du technicien
              context.push('/technician/${rating.technicianId}');
            },
            child: RatingCard(
              rating: rating,
              showTechnicianName: true,
              isCurrentUserRating: true,
              onEdit: () => _editRating(rating),
              onDelete: () => _deleteRating(rating),
            ),
          );
        },
      ),
    );
  }
}
