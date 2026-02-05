import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/models/user.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/rating_card.dart';
import 'package:techconnect/widgets/rating_form_dialog.dart';
import 'package:techconnect/widgets/rating_stats_widget.dart';

class RatingsTabScreen extends StatelessWidget {
  const RatingsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: RatingsTabContent(),
    );
  }
}

class RatingsTabContent extends StatefulWidget {
  const RatingsTabContent({super.key});

  @override
  State<RatingsTabContent> createState() => _RatingsTabContentState();
}

class _RatingsTabContentState extends State<RatingsTabContent>
    with SingleTickerProviderStateMixin {
  User? _user;
  bool _isLoading = true;
  String? _error;

  // Pour les techniciens - avis reçus
  RatingStats? _myStats;
  List<Rating> _receivedRatings = [];
  bool _isLoadingReceivedMore = false;
  bool _hasMoreReceived = true;
  int _receivedPage = 0;

  // Pour les utilisateurs - avis donnés
  List<Rating> _givenRatings = [];
  bool _isLoadingGivenMore = false;
  bool _hasMoreGiven = true;
  int _givenPage = 0;

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
      if (_user?.role == 'TECHNICIAN') {
        if (!_isLoadingReceivedMore && _hasMoreReceived) {
          _loadMoreReceivedRatings();
        }
      } else {
        if (!_isLoadingGivenMore && _hasMoreGiven) {
          _loadMoreGivenRatings();
        }
      }
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);

      // Charger l'utilisateur
      final user = await apiService.getCurrentUser();

      if (mounted) {
        setState(() {
          _user = user;
        });

        if (user.role == 'TECHNICIAN') {
          await _loadTechnicianRatings();
        } else {
          await _loadUserRatings();
        }
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

  Future<void> _loadTechnicianRatings() async {
    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);

      // Charger les stats et les avis reçus
      final results = await Future.wait([
        apiService.getTechnicianRatingStats(_user!.id),
        apiService.getTechnicianRatings(_user!.id, page: 0),
      ]);

      if (mounted) {
        setState(() {
          _myStats = results[0] as RatingStats;
          _receivedRatings = results[1] as List<Rating>;
          _hasMoreReceived = (results[1] as List<Rating>).length == 10;
          _receivedPage = 1;
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

  Future<void> _loadUserRatings() async {
    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);

      final ratings = await apiService.getMyRatings(page: 0);

      if (mounted) {
        setState(() {
          _givenRatings = ratings;
          _hasMoreGiven = ratings.length == 10;
          _givenPage = 1;
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

  Future<void> _loadMoreReceivedRatings() async {
    if (_isLoadingReceivedMore) return;

    setState(() {
      _isLoadingReceivedMore = true;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);
      final newRatings = await apiService.getTechnicianRatings(
        _user!.id,
        page: _receivedPage,
      );

      if (mounted) {
        setState(() {
          _receivedRatings.addAll(newRatings);
          _hasMoreReceived = newRatings.length == 10;
          _receivedPage++;
          _isLoadingReceivedMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingReceivedMore = false;
        });
      }
    }
  }

  Future<void> _loadMoreGivenRatings() async {
    if (_isLoadingGivenMore) return;

    setState(() {
      _isLoadingGivenMore = true;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);
      final newRatings = await apiService.getMyRatings(page: _givenPage);

      if (mounted) {
        setState(() {
          _givenRatings.addAll(newRatings);
          _hasMoreGiven = newRatings.length == 10;
          _givenPage++;
          _isLoadingGivenMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingGivenMore = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _receivedRatings.clear();
      _givenRatings.clear();
      _receivedPage = 0;
      _givenPage = 0;
      _hasMoreReceived = true;
      _hasMoreGiven = true;
    });
    await _loadData();
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
        automaticallyImplyLeading: false,
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
                onPressed: _loadData,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_user?.role == 'TECHNICIAN') {
      return _buildTechnicianView();
    } else {
      return _buildUserView();
    }
  }

  Widget _buildTechnicianView() {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // En-tête pour technicien
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vos avis clients',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Découvrez ce que vos clients pensent de vous',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Statistiques
          if (_myStats != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RatingStatsWidget(stats: _myStats!),
              ),
            ),

          // Titre des avis
          if (_receivedRatings.isNotEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Tous les avis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),

          // Liste des avis reçus
          if (_receivedRatings.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _receivedRatings.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return RatingCard(rating: _receivedRatings[index]);
                },
                childCount:
                    _receivedRatings.length + (_hasMoreReceived ? 1 : 0),
              ),
            ),

          // Message si aucun avis
          if (_receivedRatings.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(
                icon: Icons.rate_review_outlined,
                title: 'Aucun avis pour le moment',
                subtitle:
                    'Vos clients pourront bientôt vous laisser des avis !',
              ),
            ),

          // Espacement
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildUserView() {
    if (_givenRatings.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: _buildEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'Vous n\'avez pas encore donné d\'avis',
              subtitle: 'Recherchez un technicien et partagez votre expérience !',
              action: ElevatedButton.icon(
                onPressed: () => context.go('/search'),
                icon: const Icon(Icons.search),
                label: const Text('Rechercher un technicien'),
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // En-tête
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.rate_review,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mes évaluations',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_givenRatings.length} avis donné${_givenRatings.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Liste des avis donnés
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _givenRatings.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final rating = _givenRatings[index];
                return InkWell(
                  onTap: () {
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
              childCount: _givenRatings.length + (_hasMoreGiven ? 1 : 0),
            ),
          ),

          // Espacement
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textLight.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
