import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/models/contact_request.dart';
import 'package:techconnect/services/api_service.dart';
import 'package:techconnect/services/auth_service.dart';
import 'package:techconnect/theme/app_theme.dart';
import 'package:techconnect/widgets/custom_button.dart';
import 'package:techconnect/widgets/custom_text_field.dart';

class ContactScreen extends StatefulWidget {
  final String? technicianEmail;

  const ContactScreen({super.key, this.technicianEmail});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    if (widget.technicianEmail != null) {
      _emailController.text = widget.technicianEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final token = context.read<AuthService>().token;
        final apiService = ApiService(token: token);

        final request = ContactRequest(
          technicianEmail: _emailController.text.trim(),
          message: _messageController.text.trim(),
        );

        await apiService.sendContactEmail(request);

        if (mounted) {
          setState(() {
            _isLoading = false;
            _sent = true;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
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
        title: const Text('Contacter'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: _sent ? _buildSuccessView() : _buildForm(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.message_outlined,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Envoyer un message',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Le technicien recevra votre message par email et pourra vous répondre directement.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              label: 'Email du technicien',
              hint: 'technicien@exemple.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email_outlined),
              readOnly: widget.technicianEmail != null,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un email';
                }
                if (!value.contains('@')) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CustomTextField(
              label: 'Votre message',
              hint: 'Décrivez votre besoin en détail...',
              controller: _messageController,
              maxLines: 6,
              prefixIcon: const Icon(Icons.message_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un message';
                }
                if (value.length < 10) {
                  return 'Le message doit contenir au moins 10 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Envoyer le message',
              icon: Icons.send,
              onPressed: _sendMessage,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Message envoyé !',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Le technicien a reçu votre message et vous répondra dans les plus brefs délais.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Retour à l\'accueil',
              onPressed: () => context.go('/dashboard'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _sent = false;
                  _messageController.clear();
                  if (widget.technicianEmail == null) {
                    _emailController.clear();
                  }
                });
              },
              child: const Text('Envoyer un autre message'),
            ),
          ],
        ),
      ),
    );
  }
}
