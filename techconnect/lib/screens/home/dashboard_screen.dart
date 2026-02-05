import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/technician.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';
import 'package:techconnect/widgets/technician_card.dart';

/// Version complète avec Scaffold (pour utilisation standalone)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DashboardContent(),
    );
  }
}

/// Version content-only pour utilisation dans la navigation par tabs
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  final List<Technician> _technicians = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTechnicians();
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
      if (!_isLoading && _hasMore) {
        _loadTechnicians();
      }
    }
  }

  Future<void> _loadTechnicians() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);
      final newTechnicians = await apiService.getTechnicians(page: _currentPage);

      setState(() {
        _technicians.addAll(newTechnicians);
        _hasMore = newTechnicians.length == 10;
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TechConnect'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().logout();
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Affiche l'erreur si présente et liste vide
    if (_error != null && _technicians.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Erreur: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Réessayer',
              onPressed: _loadTechnicians,
            ),
          ],
        ),
      );
    }

    // Chargement initial (liste vide + en cours)
    if (_technicians.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Liste vide sans erreur
    if (_technicians.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textLight),
            const SizedBox(height: 16),
            const Text(
              'Aucun technicien disponible',
              style: TextStyle(color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Actualiser',
              onPressed: _loadTechnicians,
            ),
          ],
        ),
      );
    }

    // Liste avec données
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _technicians.clear();
          _currentPage = 0;
          _hasMore = true;
          _error = null;
        });
        await _loadTechnicians();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _technicians.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _technicians.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return TechnicianCard(technician: _technicians[index]);
        },
      ),
    );
  }
}
