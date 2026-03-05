import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'package:anime_ui/pub/services/model_catalog_svc.dart';
import 'package:anime_ui/pub/widgets/gen_dialog_shell.dart';
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
  String? _modelLoadError;

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
      debugPrint('TextGenView._loadTargetModels: $e\n$st');
      _modelLoadError = '模型加载失败';
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
      final port = widget.ref.read(resourceListPortProvider);
      await port.generatePrompt(
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

  Future<void> _optimizeResult() async {
    if (_ctrl.result.isEmpty) return;
    final instruction = _instructionCtrl.text.trim();
    if (instruction.isEmpty) return;

    final optimizeConfig = TextGenConfig(
      title: config.title,
      accentColor: config.accentColor,
      mode: TextGenMode.optimize,
      onComplete: config.onComplete,
      instructionHint: config.instructionHint,
      referenceText: _ctrl.result,
      targetModel: _selectedTargetModel?.displayName ?? '',
      language: _selectedLanguage,
      maxTokens: config.maxTokens,
      quickPrompts: config.quickPrompts,
      saveToLibrary: config.saveToLibrary,
      libraryType: config.libraryType,
    );

    await _ctrl.generate(
      instruction: instruction,
      config: optimizeConfig,
      name: _nameCtrl.text.trim(),
    );
  }

  bool get _hasResult =>
      _ctrl.status == TextGenStatus.done && _ctrl.result.isNotEmpty;
  bool get _isGenerating => _ctrl.status == TextGenStatus.generating;

  List<Widget> _buildFooterActions() {
    if (_hasResult) {
      return [
        TextButton(
          onPressed: _isGenerating ? null : widget.onClose,
          child: Text('取消',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted)),
        ),
        SizedBox(width: Spacing.sm.w),
        if (config.saveToLibrary && _ctrl.savedResource == null)
          OutlinedButton(
            onPressed: _saveAndUse,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: accent.withValues(alpha: 0.4)),
            ),
            child: Text('保存并使用',
                style: AppTextStyles.bodySmall.copyWith(color: accent)),
          ),
        SizedBox(width: Spacing.sm.w),
        FilledButton(
          onPressed: _useResult,
          style: FilledButton.styleFrom(backgroundColor: accent),
          child: const Text('使用结果'),
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) {
        final narrow = MediaQuery.sizeOf(context).width < Breakpoints.md;
        final inputPanel = TextGenInputPanel(
          config: config,
          instructionCtrl: _instructionCtrl,
          nameCtrl: _nameCtrl,
          selectedLanguage: _selectedLanguage,
          selectedTargetModel: _selectedTargetModel,
          imageModels: _imageModels,
          loadingModels: _loadingModels,
          modelLoadError: _modelLoadError,
          accent: accent,
          onLanguageChanged: (v) => setState(() => _selectedLanguage = v),
          onTargetModelChanged: (m) =>
              setState(() => _selectedTargetModel = m),
        );
        final resultPanel = TextGenResultPanel(
          ctrl: _ctrl,
          accent: accent,
          onGenerate: _generate,
          onOptimize: _optimizeResult,
        );

        return GenDialogShell(
          title: config.title,
          subtitle: config.mode.label,
          icon: AppIcons.document,
          accent: accent,
          primaryLabel: _isGenerating ? '生成中…' : '生成',
          onPrimary: _generate,
          canPrimary: !_isGenerating && _instructionCtrl.text.isNotEmpty,
          generating: _isGenerating,
          onClose: widget.onClose,
          footerActions: _hasResult ? _buildFooterActions() : null,
          footerLeading: _hasResult && config.saveToLibrary
              ? Text(
                  _ctrl.savedResource != null ? '已保存到素材库' : '',
                  style: AppTextStyles.tiny
                      .copyWith(color: AppColors.mutedDark),
                )
              : null,
          maxWidth: narrow ? 560.w : 860.w,
          minWidth: narrow ? 360.w : 560.w,
          body: narrow
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      inputPanel,
                      Container(
                          height: 1.h, color: AppColors.surfaceMutedDarker),
                      resultPanel,
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(child: inputPanel),
                    ),
                    Container(
                        width: 1.w, color: AppColors.surfaceMutedDarker),
                    Expanded(child: resultPanel),
                  ],
                ),
        );
      },
    );
  }
}
