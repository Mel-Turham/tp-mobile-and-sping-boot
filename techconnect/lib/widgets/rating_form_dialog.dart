import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:techconnect/models/rating.dart';
import 'package:techconnect/theme/app_theme.dart';

class RatingFormDialog extends StatefulWidget {
  final String technicianName;
  final Rating? existingRating;
  final Future<void> Function(int score, String? comment) onSubmit;

  const RatingFormDialog({
    super.key,
    required this.technicianName,
    this.existingRating,
    required this.onSubmit,
  });

  @override
  State<RatingFormDialog> createState() => _RatingFormDialogState();
}

class _RatingFormDialogState extends State<RatingFormDialog> {
  late int _score;
  late TextEditingController _commentController;
  bool _isSubmitting = false;
  String? _error;

  bool get isEditing => widget.existingRating != null;

  @override
  void initState() {
    super.initState();
    _score = widget.existingRating?.score ?? 0;
    _commentController = TextEditingController(
      text: widget.existingRating?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_score == 0) {
      setState(() {
        _error = 'Veuillez sélectionner une note';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final comment = _commentController.text.trim();
      await widget.onSubmit(_score, comment.isEmpty ? null : comment);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryVeryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditing ? Icons.edit : Icons.rate_review,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Modifier mon avis' : 'Donner un avis',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pour ${widget.technicianName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    color: AppColors.textLight,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),

              // Rating stars
              const Text(
                'Votre note',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RatingBar.builder(
                  initialRating: _score.toDouble(),
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 44,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  unratedColor: Colors.grey.shade300,
                  onRatingUpdate: (rating) {
                    setState(() {
                      _score = rating.toInt();
                      _error = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: _score > 0 ? AppColors.primary : AppColors.textLight,
                    fontWeight: _score > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Comment field
              const Text(
                'Votre commentaire (optionnel)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                maxLines: 4,
                maxLength: 1000,
                enabled: !_isSubmitting,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience avec ce technicien...',
                  hintStyle: const TextStyle(color: AppColors.textLight),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),

              // Error message
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Annuler',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              isEditing ? 'Modifier' : 'Publier',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
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

  String _getRatingText() {
    switch (_score) {
      case 1:
        return 'Très insatisfait 😞';
      case 2:
        return 'Insatisfait 😕';
      case 3:
        return 'Correct 😐';
      case 4:
        return 'Satisfait 🙂';
      case 5:
        return 'Très satisfait 😄';
      default:
        return 'Appuyez sur les étoiles pour noter';
    }
  }
}

/// Helper function to show the rating dialog
Future<bool?> showRatingFormDialog({
  required BuildContext context,
  required String technicianName,
  Rating? existingRating,
  required Future<void> Function(int score, String? comment) onSubmit,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => RatingFormDialog(
      technicianName: technicianName,
      existingRating: existingRating,
      onSubmit: onSubmit,
    ),
  );
}
