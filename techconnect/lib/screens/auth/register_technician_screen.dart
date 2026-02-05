import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';
import 'package:techconnect/widgets/custom_text_field.dart';

class RegisterTechnicianScreen extends StatefulWidget {
  const RegisterTechnicianScreen({super.key});

  @override
  State<RegisterTechnicianScreen> createState() => _RegisterTechnicianScreenState();
}

class _RegisterTechnicianScreenState extends State<RegisterTechnicianScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _domainController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _domainController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final authService = context.read<AuthService>();
      final success = await authService.registerTechnician(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        domain: _domainController.text.trim(),
        city: _cityController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (success && mounted) {
            context.go('/dashboard');
          } else if (!success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authService.error ?? 'Erreur d\'inscription'),
                backgroundColor: AppColors.error,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devenir technicien'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Inscrivez-vous en tant que technicien',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez notre réseau de professionnels',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  label: 'Nom complet',
                  hint: 'Votre nom',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Email professionnel',
                  hint: 'contact@entreprise.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Téléphone',
                  hint: '+237 XXX XX XX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Domaine d\'expertise',
                  hint: 'Plomberie, Électricité, Informatique...',
                  controller: _domainController,
                  prefixIcon: const Icon(Icons.work_outline),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Ville',
                  hint: 'Douala, yaounde, bangangte...',
                  controller: _cityController,
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description (optionnel)',
                  hint: 'Décrivez votre expérience et vos services...',
                  controller: _descriptionController,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Mot de passe',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Champ requis';
                    }
                    if (value.length < 6) {
                      return '6 caractères minimum';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'Créer mon compte pro',
                  onPressed: _register,
                  isLoading: authService.isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
