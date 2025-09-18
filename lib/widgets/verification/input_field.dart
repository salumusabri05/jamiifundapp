import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VerificationInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final bool isRequired;
  final TextInputType keyboardType;
  final int maxLines;
  final bool obscureText;
  
  const VerificationInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF8A2BE2)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8A2BE2), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: isRequired ? (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        return null;
      } : null,
    );
  }
}
