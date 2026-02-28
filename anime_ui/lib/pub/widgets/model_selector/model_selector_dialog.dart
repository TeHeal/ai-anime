import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'model_selector.dart';

/// Compact trigger that opens a full model picker dialog on tap.
/// Best for image/video generation where detailed model info matters.
class ModelSelectorDialogTrigger extends StatelessWidget {
  const ModelSelectorDialogTrigger({
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
        else
          _buildTrigger(context),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Center(
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: accent),
        ),
      ),
    );
  }

  Widget _buildTrigger(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          children: [
            Expanded(
              child: selected != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selected!.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selected!.features.isNotEmpty)
                          Text(
                            translateFeatures(selected!.features),
                            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    )
                  : Text(
                      '选择模型',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
            ),
            Icon(AppIcons.expandMore, size: 14, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ModelPickerDialog(
        models: models,
        selected: selected,
        accent: accent,
        onSelected: (m) {
          onChanged(m);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// Full-screen dialog listing all available models with details.
class ModelPickerDialog extends StatelessWidget {
  const ModelPickerDialog({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final ValueChanged<ModelCatalogItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: models.length,
                itemBuilder: (_, i) => _buildItem(models[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Icon(AppIcons.settings, size: 18, color: accent),
          const SizedBox(width: 8),
          const Text(
            '选择模型',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(AppIcons.close, size: 16, color: Colors.grey[500]),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(ModelCatalogItem m) {
    final isSelected = m.modelId == selected?.modelId;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onSelected(m),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? accent.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.displayName,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? accent : Colors.white,
                            ),
                          ),
                        ),
                        if (m.isRecommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '推荐',
                              style: TextStyle(
                                fontSize: 9,
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (m.features.isNotEmpty)
                      Text(
                        translateFeatures(m.features),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    Text(
                      m.operatorLabel,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(AppIcons.check, size: 18, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
