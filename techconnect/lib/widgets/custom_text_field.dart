import 'package:flutter/material.dart';
import 'package:techconnect/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final void Function(String)? onChanged;
  final bool readOnly;  // AJOUTER CETTE LIGNE

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.onChanged,
    this.readOnly = false,  // AJOUTER CETTE LIGNE (valeur par défaut)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          maxLines: maxLines,
          onChanged: onChanged,
          readOnly: readOnly,  // AJOUTER CETTE LIGNE
          enabled: !readOnly,  // Optionnel : désactive aussi le champ visuellement
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: readOnly ? AppColors.background : Colors.white,  // Grisé si readOnly
          ),
        ),
      ],
    );
  }
}