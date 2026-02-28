import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import '../model_selector/model_selector.dart';
import 'sub_widgets/voice_sample_upload.dart';
import 'voice_gen_config.dart';
import 'voice_gen_controller.dart';

/// 音色生成对话框的左侧输入面板（名称 / 样本 / 提示词 / 标签 / 模型选择）
class VoiceGenInputPanel extends StatelessWidget {
  const VoiceGenInputPanel({
    super.key,
    required this.ctrl,
    required this.config,
    required this.nameCtrl,
    required this.promptCtrl,
    required this.previewTextCtrl,
    required this.descCtrl,
    required this.tagInputCtrl,
    required this.isGeneratingPreviewText,
    this.onGeneratePreviewText,
  });

  final VoiceGenController ctrl;
  final VoiceGenConfig config;
  final TextEditingController nameCtrl;
  final TextEditingController promptCtrl;
  final TextEditingController previewTextCtrl;
  final TextEditingController descCtrl;
  final TextEditingController tagInputCtrl;
  final bool isGeneratingPreviewText;
  final VoidCallback? onGeneratePreviewText;

  Color get accent => config.accentColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(),
          const SizedBox(height: 14),
          if (ctrl.mode == VoiceGenMode.clone) ...[
            _fieldLabel('音频样本', required: true),
            const SizedBox(height: 6),
            VoiceSampleUpload(
              accent: accent,
              sampleUrl: ctrl.sampleAudioUrl,
              sampleFileName: ctrl.sampleFileName,
              onUpload: (bytes, name) async {
                await ctrl.uploadSample(bytes as dynamic, name);
              },
              onRemove: ctrl.removeSample,
            ),
          ] else ...[
            _buildDesignPromptField(),
            const SizedBox(height: 14),
            _buildPreviewTextField(),
          ],
          const SizedBox(height: 14),
          _buildTagSection(),
          const SizedBox(height: 10),
          _buildDescField(),
          const SizedBox(height: 14),
          ModelSelector(
            serviceType: 'voice_clone',
            accent: accent,
            selected: ctrl.selectedModel,
            style: ModelSelectorStyle.chips,
            onChanged: ctrl.setModel,
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('音色名称', required: true),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: nameCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: _inputDeco('输入音色名称，如：温柔少女'),
          ),
        ),
      ],
    );
  }

  Widget _buildDesignPromptField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('音色描述', required: true),
        const SizedBox(height: 6),
        TextField(
          controller: promptCtrl,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          maxLines: 3,
          decoration: _inputDeco(config.designPromptHint),
        ),
        if (config.quickPrompts.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: config.quickPrompts.map((p) {
              return GestureDetector(
                onTap: () {
                  final cur = promptCtrl.text;
                  promptCtrl.text = cur.isEmpty ? p : '$cur，$p';
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                  ),
                  child: Text(p, style: TextStyle(fontSize: 11, color: accent)),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviewTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _fieldLabel('预览文本'),
            const Spacer(),
            TextButton.icon(
              onPressed: isGeneratingPreviewText ? null : onGeneratePreviewText,
              icon: isGeneratingPreviewText
                  ? SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: accent),
                    )
                  : Icon(AppIcons.magicStick, size: 12, color: accent),
              label: Text(
                'AI 生成',
                style: TextStyle(fontSize: 11, color: accent),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: previewTextCtrl,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          maxLines: 2,
          decoration: _inputDeco('输入用于试听的文本（可选，AI 自动生成）'),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('标签'),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ...ctrl.tags.map((tag) => Chip(
                  label: Text(tag),
                  labelStyle: TextStyle(fontSize: 11, color: accent),
                  backgroundColor: accent.withValues(alpha: 0.1),
                  side: BorderSide(color: accent.withValues(alpha: 0.2)),
                  deleteIcon: Icon(AppIcons.close, size: 14, color: accent),
                  onDeleted: () => ctrl.removeTag(tag),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )),
            SizedBox(
              width: 120,
              height: 32,
              child: TextField(
                controller: tagInputCtrl,
                style: const TextStyle(fontSize: 12, color: Colors.white),
                decoration: InputDecoration(
                  hintText: '+ 添加标签',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  border: InputBorder.none,
                ),
                onSubmitted: (v) {
                  ctrl.addTag(v.trim());
                  tagInputCtrl.clear();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('备注'),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: TextField(
            controller: descCtrl,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: _inputDeco('选填，音色备注信息'),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──

  Widget _fieldLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
          ),
        ),
        if (required)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text('*', style: TextStyle(fontSize: 12, color: Colors.red[400])),
          ),
      ],
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[900],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent),
      ),
    );
  }
}
