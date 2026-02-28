import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';

/// Dropdown-style model selector. Best for config pages and inline forms.
class ModelSelectorDropdown extends StatelessWidget {
  const ModelSelectorDropdown({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.isLoading,
    required this.onChanged,
    this.label = '模型',
    this.leadingIcon,
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final bool isLoading;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final String label;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: 8),
          ],
          Expanded(child: _buildDropdown()),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    if (isLoading) {
      return Row(
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: accent),
          ),
          const SizedBox(width: 8),
          Text('加载中…',
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        ],
      );
    }

    if (models.isEmpty) {
      return Text('暂无可用模型',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]));
    }

    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: selected?.modelId,
        isExpanded: true,
        dropdownColor: Colors.grey[900],
        style: const TextStyle(color: Colors.white, fontSize: 14),
        items: models.map((m) {
          return DropdownMenuItem<String>(
            value: m.modelId,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    m.displayName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  m.operatorLabel,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                if (m.isRecommended) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '推荐',
                      style: TextStyle(fontSize: 9, color: accent),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        onChanged: (modelId) {
          if (modelId == null) return;
          final m = models.firstWhere((m) => m.modelId == modelId);
          onChanged(m);
        },
      ),
    );
  }
}

/// Inline dropdown for selecting a model by display name only.
/// Used in forms where minimal display is needed (e.g. text gen "target model").
class ModelSelectorMini extends StatelessWidget {
  const ModelSelectorMini({
    super.key,
    required this.models,
    required this.selected,
    required this.onChanged,
    this.isLoading = false,
    this.allowEmpty = true,
    this.emptyLabel = '通用',
    this.label = '目标模型',
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final bool isLoading;
  final bool allowEmpty;
  final String emptyLabel;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey[500],
                    ),
                  ),
                )
              : DropdownButton<String>(
                  value: selected?.modelId ?? '',
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: Colors.grey[900],
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  items: [
                    if (allowEmpty)
                      DropdownMenuItem(
                        value: '',
                        child: Text(emptyLabel),
                      ),
                    ...models.map((m) => DropdownMenuItem(
                          value: m.modelId,
                          child: Text(m.displayName),
                        )),
                  ],
                  onChanged: (v) {
                    if (v == null || v.isEmpty) {
                      onChanged(null);
                    } else {
                      onChanged(
                          models.where((m) => m.modelId == v).firstOrNull);
                    }
                  },
                ),
        ),
      ],
    );
  }
}
