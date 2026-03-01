import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/services/model_catalog_svc.dart';
import 'components/text_gen_footer.dart';
import 'components/text_gen_header.dart';
import 'components/text_gen_input_panel.dart';
import 'components/text_gen_result_panel.dart';
import 'text_gen_config.dart';
import 'text_gen_controller.dart';

class TextGenView extends StatefulWidget {
  const TextGenView({
    super.key,
    required this.config,
    required this.ref,
    this.onClose,
  });

  final TextGenConfig config;
  final WidgetRef ref;
  final VoidCallback? onClose;

  @override
  State<TextGenView> createState() => _TextGenViewState();
}

class _TextGenViewState extends State<TextGenView> {
  late final TextGenController _ctrl;
  late final TextEditingController _instructionCtrl;
  late final TextEditingController _nameCtrl;
  String _selectedLanguage = '';
  ModelCatalogItem? _selectedTargetModel;
  List<ModelCatalogItem> _imageModels = [];
  bool _loadingModels = false;

  TextGenConfig get config => widget.config;
  Color get accent => config.accentColor;

  @override
  void initState() {
    super.initState();
    _ctrl = TextGenController();
    _instructionCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
    _selectedLanguage = config.language;
    _loadTargetModels();
  }

  Future<void> _loadTargetModels() async {
    setState(() => _loadingModels = true);
    try {
      _imageModels = await ModelCatalogService().list(service: 'image');
    } catch (e, st) {
      debugPrint('TextGenView._loadTargetModels: $e');
      debugPrint(st.toString());
    }
    if (mounted) setState(() => _loadingModels = false);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _instructionCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final instruction = _instructionCtrl.text.trim();
    if (instruction.isEmpty) return;

    final effectiveConfig = TextGenConfig(
      title: config.title,
      accentColor: config.accentColor,
      mode: config.mode,
      onComplete: config.onComplete,
      instructionHint: config.instructionHint,
      referenceText: config.referenceText,
      targetModel: _selectedTargetModel?.displayName ?? '',
      language: _selectedLanguage,
      maxTokens: config.maxTokens,
      quickPrompts: config.quickPrompts,
      saveToLibrary: config.saveToLibrary,
      libraryType: config.libraryType,
    );

    await _ctrl.generate(
      instruction: instruction,
      config: effectiveConfig,
      name: _nameCtrl.text.trim(),
    );
  }

  Future<void> _useResult() async {
    if (_ctrl.result.isEmpty) return;
    await config.onComplete(_ctrl.result);
    if (mounted) widget.onClose?.call();
  }

  Future<void> _saveAndUse() async {
    if (_ctrl.result.isEmpty) return;

    if (_ctrl.savedResource == null && config.saveToLibrary) {
      final notifier = widget.ref.read(resourceListProvider.notifier);
      await notifier.generatePrompt(
        name: _nameCtrl.text.trim().isNotEmpty
            ? _nameCtrl.text.trim()
            : '${config.mode.label}-${DateTime.now().millisecondsSinceEpoch}',
        instruction: _instructionCtrl.text.trim(),
        targetModel: _selectedTargetModel?.displayName ?? '',
        category: config.mode.name,
      );
    }

    await config.onComplete(_ctrl.result);
    if (mounted) widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 780.w,
              maxHeight: 640.h,
              minWidth: 520.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextGenHeader(
                  config: config,
                  accent: accent,
                  onClose: widget.onClose,
                ),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 340.w,
                        child: TextGenInputPanel(
                          config: config,
                          instructionCtrl: _instructionCtrl,
                          nameCtrl: _nameCtrl,
                          selectedLanguage: _selectedLanguage,
                          selectedTargetModel: _selectedTargetModel,
                          imageModels: _imageModels,
                          loadingModels: _loadingModels,
                          accent: accent,
                          onLanguageChanged: (v) =>
                              setState(() => _selectedLanguage = v),
                          onTargetModelChanged: (m) =>
                              setState(() => _selectedTargetModel = m),
                        ),
                      ),
                      Container(width: 1.w, color: AppColors.surfaceMutedDarker),
                      Expanded(
                        child: TextGenResultPanel(
                          ctrl: _ctrl,
                          accent: accent,
                          onGenerate: _generate,
                        ),
                      ),
                    ],
                  ),
                ),
                TextGenFooter(
                  config: config,
                  ctrl: _ctrl,
                  accent: accent,
                  onClose: widget.onClose,
                  onGenerate: _generate,
                  onUseResult: _useResult,
                  onSaveAndUse: _saveAndUse,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
