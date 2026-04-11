// lib/widgets/gradient_input_field.dart
// Reusable styled text field with the app's silver-grey gradient background.
// Supports an optional show/hide toggle for password fields (showToggle: true).
// All auth screens (Login, SignUp, ForgotPassword) use this widget so the
// appearance is always consistent — no more blue password boxes.

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GradientInputField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;   // set true for password fields
  final bool showToggle;    // set true to show the eye icon on password fields
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;

  const GradientInputField({
    super.key,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.showToggle = false,  // NEW: defaults to false so existing usages are unchanged
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<GradientInputField> createState() => _GradientInputFieldState();
}

class _GradientInputFieldState extends State<GradientInputField> {
  // Tracks whether the text is currently hidden (only relevant when showToggle=true)
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    // Start hidden if obscureText is requested
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      // Dim the field when it is disabled (e.g. after OTP is sent)
      opacity: widget.enabled ? 1.0 : 0.6,
      child: Container(
        decoration: BoxDecoration(
          // Silver-grey gradient — matches the Email field on all screens
          gradient: AppColors.secondaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryDark.withAlpha((0.5 * 255).toInt()),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          // Use the local _obscure state so the toggle can flip it
          obscureText: _obscure,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: AppColors.textGrey.withAlpha((0.5 * 255).toInt()),
              fontSize: 16,
            ),
            // Prefix icon (e.g. lock, email)
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textGrey)
                : null,
            // Suffix eye icon — only rendered when showToggle is true
            suffixIcon: widget.showToggle
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textGrey,
                    ),
                    onPressed: () {
                      // Flip visibility state and rebuild the widget
                      setState(() => _obscure = !_obscure);
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: widget.maxLines > 1 ? 16 : 18,
            ),
          ),
        ),
      ),
    );
  }
}
