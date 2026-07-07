import 'package:flutter/material.dart';
import 'luxury_button.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return LuxuryButton(
      text: label,
      onPressed: onPressed ?? () {},
      isLoading: isLoading,
    );
  }
}
