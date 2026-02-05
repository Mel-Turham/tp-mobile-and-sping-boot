import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/user.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';

/// Version complète avec Scaffold (pour utilisation standalone)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ProfileContent(),
    );
  }
}

/// Version content-only pour utilisation dans la navigation par tabs
class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final token = context.read<AuthService>().token;
      final apiService = ApiService(token: token);
      final user = await apiService.getCurrentUser();

      if (mounted) {
        setState(() {
          _user = user;
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthService>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Erreur: $_error',
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Réessayer',
              onPressed: _loadProfile,
            ),
          ],
        ),
      )
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    final user = _user!;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 4,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            user.name,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildInfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            icon: Icons.calendar_today_outlined,
            title: 'Membre depuis',
            value: dateFormat.format(user.createdAt),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.rate_review, color: AppColors.primary),
            title: const Text('Mes avis'),
            subtitle: const Text('Voir et gérer mes évaluations'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => context.push('/my-ratings'),
          ),
          if (user.role == 'TECHNICIAN')
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: const Text('Modifier mon profil pro'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité à venir'),
                  ),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Déconnexion',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
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
          Expanded(
            child: Column(
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
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
