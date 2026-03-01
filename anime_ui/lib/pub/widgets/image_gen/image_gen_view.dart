import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/services/api_svc.dart';
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';
import 'components/image_gen_footer.dart';
import 'components/image_gen_header.dart';
import 'components/image_gen_input_panel.dart';
import 'components/image_gen_result_panel.dart';
import 'image_gen_config.dart';
import 'image_gen_controller.dart';

class ImageGenView extends StatefulWidget {
  const ImageGenView({
    super.key,
    required this.config,
    required this.ref,
    this.onClose,
  });

  final ImageGenConfig config;
  final WidgetRef ref;
  final VoidCallback? onClose;

  @override
  State<ImageGenView> createState() => _ImageGenViewState();
}

class _ImageGenViewState extends State<ImageGenView> {
  late final ImageGenController _ctrl;
  late final TextEditingController _promptCtrl;
  late final TextEditingController _negPromptCtrl;
  bool _showAdvanced = false;
  bool _isSaving = false;

  ImageGenConfig get config => widget.config;
  Color get accent => config.accentColor;

  @override
  void initState() {
    super.initState();
    _ctrl = ImageGenController();
    _ctrl.setRatio(config.defaultRatio);
    _promptCtrl = TextEditingController();
    _negPromptCtrl = TextEditingController();
    _promptCtrl.addListener(() => _ctrl.setPrompt(_promptCtrl.text));
    _negPromptCtrl.addListener(() => _ctrl.setNegPrompt(_negPromptCtrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _promptCtrl.dispose();
    _negPromptCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    await _ctrl.generate(
      onGenerate:
          ({
            required prompt,
            required negPrompt,
            required refImages,
            required outputCount,
            required ratio,
            required resolution,
            required width,
            required height,
            required provider,
            required model,
            required onProgress,
            required onResult,
          }) async {
            final port = widget.ref.read(resourceListPortProvider);
            final refImgUrl = refImages.isNotEmpty ? refImages.first : '';
            final multiRefImgs = refImages.length > 1 ? refImages : <String>[];

            String sizeParam = '';
            int? w = width;
            int? h = height;
            if (ratio.isEmpty) {
              sizeParam = resolution;
              w = null;
              h = null;
            }

            final tasks = <Future<void>>[];
            final count = outputCount;
            for (int i = 0; i < count; i++) {
              tasks.add(
                _generateOne(
                  port: port,
                  prompt: prompt,
                  negPrompt: negPrompt,
                  referenceImageUrl: refImgUrl,
                  referenceImages: multiRefImgs,
                  provider: provider,
                  model: model,
                  width: w,
                  height: h,
                  size: sizeParam,
                  onProgress: i == 0 ? onProgress : null,
                  onResult: onResult,
                ),
              );
            }
            await Future.wait(tasks);
          },
    );
  }

  Future<void> _generateOne({
    required dynamic port,
    required String prompt,
    required String negPrompt,
    required String referenceImageUrl,
    required List<String> referenceImages,
    required String provider,
    required String model,
    required int? width,
    required int? height,
    required String size,
    required void Function(int)? onProgress,
    required void Function(String) onResult,
  }) async {
    final resourceId = await port.generateImage(
      name: '${config.title}-${DateTime.now().millisecondsSinceEpoch}',
      libraryType: config.libraryType,
      modality: config.modality,
      prompt: prompt,
      negativePrompt: negPrompt,
      referenceImageUrl: referenceImages.isNotEmpty
          ? referenceImages.join(',')
          : referenceImageUrl,
      provider: provider,
      model: model,
      width: width,
      height: height,
      size: size,
      onProgress: onProgress ?? (_) {},
    );

    if (resourceId != null) {
      final resources = port.resources.value ?? [];
      final generated = resources.where((r) => r.id == resourceId).firstOrNull;
      if (generated != null && generated.thumbnailUrl.isNotEmpty) {
        onResult(generated.thumbnailUrl);
      }
    }
  }

  Future<void> _saveResults() async {
    if (_ctrl.results.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await config.onSaved(
        _ctrl.results.map((r) => r.url).toList(),
        _ctrl.mode,
        prompt: _promptCtrl.text.trim(),
        negativePrompt: _negPromptCtrl.text.trim(),
      );
      if (mounted) widget.onClose?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败：$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPromptLibrary(ValueChanged<String> onSelected) {
    final resources =
        widget.ref.read(resourceListPortProvider).resources.value ?? [];
    final prompts = resources.where((r) => r.libraryType == 'prompt').toList();
    if (prompts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('提示词库中暂无模板'),
          backgroundColor: AppColors.surfaceContainer,
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => PromptLibraryDialog(
        prompts: prompts,
        accent: accent,
        onSelected: (p) {
          onSelected(p);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _showLightbox(String url) {
    showImageViewer(
      context,
      CachedNetworkImageProvider(resolveFileUrl(url)),
      swipeDismissible: true,
      doubleTapZoomable: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.xxxl.r),
          ),
          child: Builder(
            builder: (context) {
              final w = MediaQuery.sizeOf(context).width;
              final narrow = w < Breakpoints.md;
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: narrow ? 600.w : 900.w,
                  maxHeight: 700.h,
                  minWidth: narrow ? 320.w : 600.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageGenHeader(
                      config: config,
                      ctrl: _ctrl,
                      accent: accent,
                      onClose: widget.onClose ?? () => Navigator.pop(context),
                    ),
                    Flexible(
                      child: narrow
                          ? SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(Spacing.lg.r),
                                    child: ImageGenInputPanel(
                                      config: config,
                                      ctrl: _ctrl,
                                      ref: widget.ref,
                                      promptCtrl: _promptCtrl,
                                      negPromptCtrl: _negPromptCtrl,
                                      showAdvanced: _showAdvanced,
                                      onToggleAdvanced: () => setState(
                                        () => _showAdvanced = !_showAdvanced,
                                      ),
                                      onPromptLibraryTap: _showPromptLibrary,
                                    ),
                                  ),
                                  Container(
                                    height: 1.h,
                                    color: AppColors.divider,
                                  ),
                                  SizedBox(
                                    height: 280.h,
                                    child: ImageGenResultPanel(
                                      config: config,
                                      ctrl: _ctrl,
                                      accent: accent,
                                      isSaving: _isSaving,
                                      onSave: _saveResults,
                                      onImageTap: _showLightbox,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 360.w,
                                  child: ImageGenInputPanel(
                                    config: config,
                                    ctrl: _ctrl,
                                    ref: widget.ref,
                                    promptCtrl: _promptCtrl,
                                    negPromptCtrl: _negPromptCtrl,
                                    showAdvanced: _showAdvanced,
                                    onToggleAdvanced: () => setState(
                                      () => _showAdvanced = !_showAdvanced,
                                    ),
                                    onPromptLibraryTap: _showPromptLibrary,
                                  ),
                                ),
                                Container(width: 1.w, color: AppColors.divider),
                                Expanded(
                                  child: ImageGenResultPanel(
                                    config: config,
                                    ctrl: _ctrl,
                                    accent: accent,
                                    isSaving: _isSaving,
                                    onSave: _saveResults,
                                    onImageTap: _showLightbox,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    ImageGenFooter(
                      ctrl: _ctrl,
                      accent: accent,
                      canGenerate:
                          !_ctrl.isGenerating &&
                          (_promptCtrl.text.isNotEmpty ||
                              _ctrl.refImages.isNotEmpty),
                      onClose: widget.onClose ?? () => Navigator.pop(context),
                      onGenerate: _generate,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
