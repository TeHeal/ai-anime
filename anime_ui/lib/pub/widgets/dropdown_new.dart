import 'package:flutter/material.dart';
import 'package:anime_ui/pub/theme/colors.dart';

class DropdownNew<T> extends StatelessWidget {
  const DropdownNew({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.isNew = false,
  });

  final T value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<T>(
            value: value,
            items: items,
            onChanged: onChanged,
          ),
        ),
        if (isNew)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.newTag,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('NEW', style: TextStyle(fontSize: 10)),
          ),
      ],
    );
  }
}
