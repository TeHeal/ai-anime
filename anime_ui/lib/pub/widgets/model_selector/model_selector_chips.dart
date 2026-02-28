import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';

/// Horizontal chip-style model selector. Best for small model lists (≤5).
class ModelSelectorChips extends StatelessWidget {
  const ModelSelectorChips({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.isLoading,
    required this.onChanged,
    this.label = '模型',
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final bool isLoading;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        if (isLoading)
          _buildLoading()
        else if (models.isEmpty)
          Text('暂无可用模型',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]))
        else
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: models.map((m) => _chip(m)).toList(),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return Row(
      children: [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: accent),
        ),
        const SizedBox(width: 8),
        Text('加载模型中…',
            style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _chip(ModelCatalogItem m) {
    final isSelected = selected?.id == m.id;
    return GestureDetector(
      onTap: () => onChanged(m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.15)
              : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.5)
                : Colors.grey[800]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (m.isRecommended) ...[
              Icon(AppIcons.bolt, size: 12, color: Colors.amber[400]),
              const SizedBox(width: 4),
            ],
            Text(
              m.displayName,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? accent : Colors.grey[300],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              m.operatorLabel,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}
