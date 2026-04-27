import 'package:flutter/material.dart';

/// TextField outlined do protótipo (border-radius 4, border #79747E)
class AppTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  const AppTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
