import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/technician.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';
import 'package:techconnect/widgets/custom_text_field.dart';
import 'package:techconnect/widgets/technician_card.dart';

/// Version complète avec Scaffold (pour utilisation standalone)
class SearchTechnicianScreen extends StatelessWidget {
  const SearchTechnicianScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SearchTechnicianContent(),
    );
  }
}

/// Version content-only pour utilisation dans la navigation par tabs
class SearchTechnicianContent extends StatefulWidget {
  const SearchTechnicianContent({super.key});

  @override
  State<SearchTechnicianContent> createState() => _SearchTechnicianContentState();
}

class _SearchTechnicianContentState extends State<SearchTechnicianContent> {
  final _domainController = TextEditingController();
  final _cityController = TextEditingController();
  final List<Technician> _technicians = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _hasMore = true;
  int _currentPage = 0;

  Future<void> _search({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _technicians.clear();
        _currentPage = 0;
        _hasMore = true;
        _hasSearched = true;
      });
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);

      final results = await apiService.searchTechnicians(
        domain: _domainController.text.trim().isEmpty
            ? null
            : _domainController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        page: _currentPage,
      );

      if (mounted) {
        setState(() {
          _technicians.addAll(results);
          _hasMore = results.length == 10;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _domainController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomTextField(
                  label: 'Domaine',
                  hint: 'Plomberie, Électricité, IT...',
                  controller: _domainController,
                  prefixIcon: const Icon(Icons.work_outline),
                  onChanged: (_) {}, // Pour rebuild si nécessaire
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Ville',
                  hint: 'Paris, Lyon, Marseille...',
                  controller: _cityController,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  onChanged: (_) {},
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Rechercher',
                  icon: Icons.search,
                  onPressed: () => _search(),
                  isLoading: _isLoading && _technicians.isEmpty,
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (!_hasSearched) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Recherchez un technicien',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    if (_technicians.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_technicians.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textLight,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun technicien trouvé',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _technicians.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _technicians.length) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : TextButton(
                onPressed: () => _search(loadMore: true),
                child: const Text('Charger plus'),
              ),
            ),
          );
        }
        return TechnicianCard(technician: _technicians[index]);
      },
    );
  }
}
