import 'package:flutter/material.dart';

class SecondaryBtn extends StatelessWidget {
  const SecondaryBtn({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
