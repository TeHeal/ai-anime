import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/widgets/gen_dialog_shell.dart';
import 'components/voice_gen_input_panel.dart';
import 'components/voice_gen_right_panel.dart';
import 'voice_gen_config.dart';
import 'voice_gen_controller.dart';

class VoiceGenView extends StatefulWidget {
  const VoiceGenView({
    super.key,
    required this.config,
    required this.ref,
    this.onClose,
  });

  final VoiceGenConfig config;
  final WidgetRef ref;
  final VoidCallback? onClose;

  @override
  State<VoiceGenView> createState() => _VoiceGenViewState();
}

class _VoiceGenViewState extends State<VoiceGenView> {
  late final VoiceGenController _ctrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _promptCtrl;
  late final TextEditingController _previewTextCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagInputCtrl;
  bool _isSaving = false;
  bool _isSaved = false;
  bool _isGeneratingPreviewText = false;

  VoiceGenConfig get config => widget.config;
  Color get accent => config.accentColor;

  @override
  void initState() {
    super.initState();
    _ctrl = VoiceGenController();
    _ctrl.mode = VoiceGenMode.design;

    _nameCtrl = TextEditingController();
    _promptCtrl = TextEditingController();
    _previewTextCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _tagInputCtrl = TextEditingController();

    _nameCtrl.addListener(() => _ctrl.setName(_nameCtrl.text));
    _promptCtrl.addListener(() => _ctrl.setDesignPrompt(_promptCtrl.text));
    _previewTextCtrl
        .addListener(() => _ctrl.setPreviewText(_previewTextCtrl.text));
    _descCtrl.addListener(() => _ctrl.setDescription(_descCtrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _promptCtrl.dispose();
    _previewTextCtrl.dispose();
    _descCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    await _ctrl.generate(
      onGenerate:
          ({
            required mode,
            required name,
            required description,
            required tags,
            required sampleUrl,
            required designPrompt,
            required previewText,
            required provider,
            required model,
            required onProgress,
            required onResult,
          }) async {
            final port = widget.ref.read(resourceListPortProvider);
            final tagsJson = tags.isEmpty ? '' : jsonEncode(tags);

            final resource = await port.generateVoiceDesign(
              name: name,
              prompt: designPrompt,
              previewText: previewText,
              provider: provider,
              model: model,
              tagsJson: tagsJson,
              description: description,
              onProgress: onProgress,
            );
            final audioUrl =
                resource.metadata['audioUrl'] as String? ?? '';
            if (audioUrl.isNotEmpty) onResult(audioUrl);
          },
    );
  }

  Future<void> _generatePreviewText() async {
    if (_promptCtrl.text.trim().isEmpty) return;
    setState(() => _isGeneratingPreviewText = true);
    try {
      final port = widget.ref.read(resourceListPortProvider);
      final text = await port.generatePreviewText(
        voicePrompt: _promptCtrl.text,
      );
      if (mounted && text.isNotEmpty) _previewTextCtrl.text = text;
    } catch (e, st) {
      debugPrint('VoiceGenView._generatePreviewText: $e\n$st');
      if (mounted) showToast(context, '生成预览文本失败', isError: true);
    } finally {
      if (mounted) setState(() => _isGeneratingPreviewText = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await config.onSaved(_ctrl.mode);
      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
        });
        showToast(context, '音色已保存到素材库');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        showToast(context, '保存失败：$e', isError: true);
      }
    }
  }

  Widget _buildFooterLeading() {
    if (_ctrl.isGenerating) {
      return Row(
        children: [
          SizedBox(
            width: 14.w, height: 14.h,
            child: CircularProgressIndicator(
                strokeWidth: 2.r, color: accent),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            _ctrl.progress > 0 ? '生成中 ${_ctrl.progress}%…' : '生成中…',
            style: AppTextStyles.caption.copyWith(color: accent),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) {
        final narrow = MediaQuery.sizeOf(context).width < Breakpoints.md;
        return GenDialogShell(
          title: config.title,
          subtitle: '用 AI 描述你想要的声音',
          icon: AppIcons.mic,
          accent: accent,
          primaryLabel: '开始生成',
          onPrimary: _generate,
          canPrimary: _ctrl.canGenerate,
          generating: _ctrl.isGenerating,
          onClose: widget.onClose,
          footerLeading: _buildFooterLeading(),
          maxWidth: narrow ? 520.w : 880.w,
          minWidth: narrow ? 340.w : 480.w,
          body: narrow
              ? _buildNarrowBody()
              : _buildWideBody(),
        );
      },
    );
  }

  /// 窄屏：纵向堆叠
  Widget _buildNarrowBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          VoiceGenInputPanel(
            config: config,
            ctrl: _ctrl,
            ref: widget.ref,
            nameCtrl: _nameCtrl,
            promptCtrl: _promptCtrl,
          ),
          Container(height: 1.h, color: AppColors.surfaceMutedDarker),
          VoiceGenRightPanel(
            config: config,
            ctrl: _ctrl,
            accent: accent,
            previewTextCtrl: _previewTextCtrl,
            descCtrl: _descCtrl,
            tagInputCtrl: _tagInputCtrl,
            isGeneratingPreviewText: _isGeneratingPreviewText,
            onGeneratePreviewText: _generatePreviewText,
            isSaving: _isSaving,
            isSaved: _isSaved,
            onSave: _save,
          ),
        ],
      ),
    );
  }

  /// 宽屏：左右分栏
  Widget _buildWideBody() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 左侧：核心输入（名称 + 描述 prompt）
          Expanded(
            flex: 1,
            child: VoiceGenInputPanel(
              config: config,
              ctrl: _ctrl,
              ref: widget.ref,
              nameCtrl: _nameCtrl,
              promptCtrl: _promptCtrl,
            ),
          ),
          Container(width: 1.w, color: AppColors.surfaceMutedDarker),
          // 右侧：参数配置 + 生成结果
          Expanded(
            flex: 1,
            child: VoiceGenRightPanel(
              config: config,
              ctrl: _ctrl,
              accent: accent,
              previewTextCtrl: _previewTextCtrl,
              descCtrl: _descCtrl,
              tagInputCtrl: _tagInputCtrl,
              isGeneratingPreviewText: _isGeneratingPreviewText,
              onGeneratePreviewText: _generatePreviewText,
              isSaving: _isSaving,
              isSaved: _isSaved,
              onSave: _save,
            ),
          ),
        ],
      ),
    );
  }
}
