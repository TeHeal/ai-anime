import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/services/model_catalog_svc.dart';
import 'package:anime_ui/pub/services/model_preference_svc.dart';
import 'model_selector_chips.dart';
import 'model_selector_dialog.dart';
import 'model_selector_dropdown.dart';

export 'model_selector_chips.dart';
export 'model_selector_dialog.dart';
export 'model_selector_dropdown.dart';

/// Display styles for the unified model selector.
enum ModelSelectorStyle { chips, dropdown, dialog }

/// Feature label translations used across all selector styles.
const kFeatureLabels = <String, String>{
  'text2img': '文生图',
  'img2img': '图生图',
  'multi_image': '多图',
  'text2video': '文生视频',
  'img2video': '图生视频',
  'audio': '音频',
  'multi_shot': '多镜头',
  'tts': '语音合成',
  'voice_clone': '声音克隆',
  'chat': '对话',
  'reasoning': '推理',
  'tools': '工具调用',
};

String translateFeatures(String features) {
  if (features.isEmpty) return '';
  return features
      .split(',')
      .map((f) => kFeatureLabels[f.trim()] ?? f.trim())
      .join(' · ');
}

/// Unified model selector that loads models for a given [serviceType] and
/// presents them using the specified [style].
///
/// Handles loading, preference memory, and smart defaults automatically.
class ModelSelector extends StatefulWidget {
  const ModelSelector({
    super.key,
    required this.serviceType,
    required this.accent,
    required this.onChanged,
    this.selected,
    this.style = ModelSelectorStyle.dialog,
    this.label = '模型',
    this.bestForHint = '',
  });

  final String serviceType;
  final Color accent;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final ModelCatalogItem? selected;
  final ModelSelectorStyle style;
  final String label;
  final String bestForHint;

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  final _catalogSvc = ModelCatalogService();
  final _prefSvc = ModelPreferenceService();

  List<ModelCatalogItem> _models = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _loading = true);
    try {
      final items = await _catalogSvc.list(service: widget.serviceType);
      _models = items;

      if (widget.selected == null && items.isNotEmpty) {
        final best = await _prefSvc.pickDefault(
          items,
          serviceType: widget.serviceType,
          bestForHint: widget.bestForHint,
        );
        widget.onChanged(best);
      }
    } catch (e, st) {
      debugPrint('ModelSelector._load: $e');
      debugPrint(st.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  void _onSelect(ModelCatalogItem? m) {
    widget.onChanged(m);
    if (m != null) {
      _prefSvc.save(widget.serviceType, m.modelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.style) {
      ModelSelectorStyle.chips => ModelSelectorChips(
          models: _models,
          selected: widget.selected,
          accent: widget.accent,
          isLoading: _loading,
          label: widget.label,
          onChanged: _onSelect,
        ),
      ModelSelectorStyle.dropdown => ModelSelectorDropdown(
          models: _models,
          selected: widget.selected,
          accent: widget.accent,
          isLoading: _loading,
          label: widget.label,
          onChanged: _onSelect,
        ),
      ModelSelectorStyle.dialog => ModelSelectorDialogTrigger(
          models: _models,
          selected: widget.selected,
          accent: widget.accent,
          isLoading: _loading,
          label: widget.label,
          onChanged: _onSelect,
        ),
    };
  }
}
