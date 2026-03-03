import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'components/voice_gen_footer.dart';
import 'components/voice_gen_header.dart';
import 'components/voice_gen_input_panel.dart';
import 'components/voice_gen_mode_tabs.dart';
import 'components/voice_gen_result_panel.dart';
import 'voice_gen_config.dart';
import 'voice_gen_controller.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

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
    _previewTextCtrl.addListener(
      () => _ctrl.setPreviewText(_previewTextCtrl.text),
    );
    _descCtrl.addListener(() => _ctrl.setDescription(_descCtrl.text));

    _tabCtrl = TabController(
      length: config.allowedModes.length,
      vsync: this,
      initialIndex: config.allowedModes
          .indexOf(config.defaultMode)
          .clamp(0, config.allowedModes.length - 1),
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

            if (mode == VoiceGenMode.clone) {
              final resource = await port.generateVoice(
                name: name,
                sampleUrl: sampleUrl,
                tagsJson: tagsJson,
                description: description,
                onProgress: onProgress,
              );
              final audioUrl = resource.metadata['audioUrl'] as String? ??
                  resource.thumbnailUrl;
              if (audioUrl.isNotEmpty) onResult(audioUrl);
            } else {
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
      final port = widget.ref.read(resourceListPortProvider);
      final text = await port.generatePreviewText(
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
        showToast(context, '保存失败：$e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              maxWidth: 860.w,
              maxHeight: 680.h,
              minWidth: 560.w,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                VoiceGenHeader(
                  config: config,
                  ctrl: _ctrl,
                  accent: accent,
                  onClose: widget.onClose ?? () => Navigator.pop(context),
                ),
                if (config.allowedModes.length > 1)
                  VoiceGenModeTabs(
                    tabController: _tabCtrl,
                    allowedModes: config.allowedModes,
                    accent: accent,
                  ),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 380.w,
                        child: VoiceGenInputPanel(
                          config: config,
                          ctrl: _ctrl,
                          ref: widget.ref,
                          nameCtrl: _nameCtrl,
                          promptCtrl: _promptCtrl,
                          previewTextCtrl: _previewTextCtrl,
                          descCtrl: _descCtrl,
                          tagInputCtrl: _tagInputCtrl,
                          isGeneratingPreviewText: _isGeneratingPreviewText,
                          onGeneratePreviewText: _generatePreviewText,
                        ),
                      ),
                      Container(
                        width: 1.w,
                        color: AppColors.surfaceMutedDarker,
                      ),
                      Expanded(
                        child: VoiceGenResultPanel(
                          ctrl: _ctrl,
                          accent: accent,
                          isSaving: _isSaving,
                          onSave: _save,
                        ),
                      ),
                    ],
                  ),
                ),
                VoiceGenFooter(
                  ctrl: _ctrl,
                  accent: accent,
                  onClose: widget.onClose ?? () => Navigator.pop(context),
                  onGenerate: _generate,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
