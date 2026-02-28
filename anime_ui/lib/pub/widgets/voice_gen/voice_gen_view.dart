import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'voice_gen_config.dart';
import 'voice_gen_controller.dart';
import 'voice_gen_input_panel.dart';
import 'sub_widgets/voice_result_preview.dart';

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

class _VoiceGenViewState extends State<VoiceGenView>
    with SingleTickerProviderStateMixin {
  late final VoiceGenController _ctrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _promptCtrl;
  late final TextEditingController _previewTextCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _tagInputCtrl;
  late final TabController _tabCtrl;
  bool _isSaving = false;
  bool _isGeneratingPreviewText = false;

  VoiceGenConfig get config => widget.config;
  Color get accent => config.accentColor;

  @override
  void initState() {
    super.initState();
    _ctrl = VoiceGenController();
    _ctrl.mode = config.defaultMode;

    _nameCtrl = TextEditingController();
    _promptCtrl = TextEditingController();
    _previewTextCtrl = TextEditingController();
    _descCtrl = TextEditingController();
    _tagInputCtrl = TextEditingController();

    _nameCtrl.addListener(() => _ctrl.setName(_nameCtrl.text));
    _promptCtrl.addListener(() => _ctrl.setDesignPrompt(_promptCtrl.text));
    _previewTextCtrl.addListener(() => _ctrl.setPreviewText(_previewTextCtrl.text));
    _descCtrl.addListener(() => _ctrl.setDescription(_descCtrl.text));

    _tabCtrl = TabController(
      length: config.allowedModes.length,
      vsync: this,
      initialIndex: config.allowedModes.indexOf(config.defaultMode).clamp(0, config.allowedModes.length - 1),
    );
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        _ctrl.setMode(config.allowedModes[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _promptCtrl.dispose();
    _previewTextCtrl.dispose();
    _descCtrl.dispose();
    _tagInputCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  // ── Generate ──

  Future<void> _generate() async {
    await _ctrl.generate(
      onGenerate: ({
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
        final notifier = widget.ref.read(resourceListProvider.notifier);
        final tagsJson = tags.isEmpty ? '' : jsonEncode(tags);

        if (mode == VoiceGenMode.clone) {
          await notifier.generateVoice(
            name: name,
            sampleUrl: sampleUrl,
            tagsJson: tagsJson,
            description: description,
            onProgress: onProgress,
          );
        } else {
          final resource = await notifier.generateVoiceDesign(
            name: name,
            prompt: designPrompt,
            previewText: previewText,
            provider: provider,
            model: model,
            tagsJson: tagsJson,
            description: description,
            onProgress: onProgress,
          );
          final audioUrl = resource.metadata['audio_url'] as String? ?? '';
          if (audioUrl.isNotEmpty) {
            onResult(audioUrl);
          }
        }
      },
    );
  }

  Future<void> _generatePreviewText() async {
    if (_promptCtrl.text.trim().isEmpty) return;
    setState(() => _isGeneratingPreviewText = true);
    try {
      final notifier = widget.ref.read(resourceListProvider.notifier);
      final text = await notifier.generatePreviewText(
        voicePrompt: _promptCtrl.text,
      );
      if (mounted && text.isNotEmpty) {
        _previewTextCtrl.text = text;
      }
    } catch (e, st) {
      debugPrint('VoiceGenView._generatePreviewText: $e');
      debugPrint(st.toString());
    } finally {
      if (mounted) setState(() => _isGeneratingPreviewText = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await config.onSaved(_ctrl.mode);
      if (mounted) widget.onClose?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e'), backgroundColor: Colors.red[700]),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (_, _) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 860,
              maxHeight: 680,
              minWidth: 560,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                if (config.allowedModes.length > 1) _buildModeTabs(),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 380,
                        child: VoiceGenInputPanel(
                          ctrl: _ctrl,
                          config: config,
                          nameCtrl: _nameCtrl,
                          promptCtrl: _promptCtrl,
                          previewTextCtrl: _previewTextCtrl,
                          descCtrl: _descCtrl,
                          tagInputCtrl: _tagInputCtrl,
                          isGeneratingPreviewText: _isGeneratingPreviewText,
                          onGeneratePreviewText: _generatePreviewText,
                        ),
                      ),
                      Container(width: 1, color: Colors.grey[850]),
                      Expanded(child: _buildResultPanel()),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 16, 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[850]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(AppIcons.mic, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _ctrl.mode.label,
                  style: TextStyle(fontSize: 12, color: accent),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(AppIcons.close, size: 18, color: Colors.grey[500]),
            onPressed: widget.onClose ?? () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTabs() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[850]!)),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicatorColor: accent,
        labelColor: accent,
        unselectedLabelColor: Colors.grey[500],
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: config.allowedModes.map((m) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  m == VoiceGenMode.clone ? AppIcons.upload : AppIcons.magicStick,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(m.label),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Right: Result Panel ──

  Widget _buildResultPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '生成结果',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 12),
          VoiceResultPreview(
            accent: accent,
            audioUrl: _ctrl.resultAudioUrl,
            isGenerating: _ctrl.isGenerating,
            progress: _ctrl.progress,
            errorMsg: _ctrl.hasError ? _ctrl.errorMsg : null,
          ),
          if (_ctrl.isDone && _ctrl.resultAudioUrl.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildResultActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _ctrl.reset,
          icon: Icon(AppIcons.refresh, size: 14),
          label: const Text('重新生成'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey[400],
            side: BorderSide(color: Colors.grey[700]!),
          ),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(AppIcons.save, size: 14),
          label: const Text('保存音色'),
          style: FilledButton.styleFrom(backgroundColor: accent),
        ),
      ],
    );
  }

  // ── Footer ──

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[850]!)),
      ),
      child: Row(
        children: [
          if (_ctrl.isGenerating) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            ),
            const SizedBox(width: 8),
            Text(
              _ctrl.progress > 0 ? '生成中 ${_ctrl.progress}%…' : '生成中…',
              style: TextStyle(fontSize: 12, color: accent),
            ),
          ],
          const Spacer(),
          TextButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[500]),
            child: const Text('取消'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: _ctrl.canGenerate ? _generate : null,
            icon: Icon(
              _ctrl.isGenerating ? AppIcons.inProgress : AppIcons.magicStick,
              size: 16,
            ),
            label: Text(_ctrl.isGenerating ? '生成中…' : '开始生成'),
            style: FilledButton.styleFrom(
              backgroundColor: _ctrl.canGenerate ? accent : Colors.grey[800],
              foregroundColor: _ctrl.canGenerate ? Colors.white : Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
