import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/gen_dialog_shell.dart';
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';
import 'components/image_gen_input_panel.dart';
import 'components/image_gen_result_panel.dart';
import 'image_gen_config.dart';
import 'image_gen_controller.dart';

/// 图像生成弹窗视图
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
            for (int i = 0; i < outputCount; i++) {
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
      final matches = resources.where((r) => r.id == resourceId);
      final generated = matches.isEmpty ? null : matches.first;
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
      if (mounted) showToast(context, '保存失败：$e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPromptLibrary(ValueChanged<String> onSelected) {
    final resources =
        widget.ref.read(resourceListPortProvider).resources.value ?? [];
    final prompts = resources.where((r) => r.libraryType == 'prompt').toList();
    if (prompts.isEmpty) {
      showToast(context, '提示词库中暂无模板', isInfo: true);
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

  Widget _buildFooterLeading() {
    final modelName = _ctrl.selectedModel?.displayName ?? '';
    if (_ctrl.isGenerating) {
      return Row(
        children: [
          SizedBox(
            width: 14.w, height: 14.h,
            child: CircularProgressIndicator(
              strokeWidth: 2.r, color: accent,
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          Text(
            _ctrl.progress > 0 ? '生成中 ${_ctrl.progress}%…' : '生成中…',
            style: AppTextStyles.caption.copyWith(color: accent),
          ),
        ],
      );
    }
    if (modelName.isNotEmpty) {
      return Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.sm.w, vertical: Spacing.xxs.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.autoAwesome, size: 11.r, color: AppColors.mutedDark),
                SizedBox(width: Spacing.xs.w),
                Text(modelName,
                    style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDark)),
              ],
            ),
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
      builder: (context, _) {
        final narrow = MediaQuery.sizeOf(context).width < Breakpoints.md;
        return GenDialogShell(
          title: config.title,
          subtitle: '填写提示词后点击生成',
          icon: AppIcons.magicStick,
          accent: accent,
          primaryLabel: '开始生成',
          onPrimary: _generate,
          canPrimary: !_ctrl.isGenerating &&
              (_promptCtrl.text.isNotEmpty || _ctrl.refImages.isNotEmpty),
          generating: _ctrl.isGenerating,
          onClose: widget.onClose,
          footerLeading: _buildFooterLeading(),
          maxWidth: narrow ? 520.w : 920.w,
          minWidth: narrow ? 320.w : 560.w,
          body: narrow
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
                          onPromptLibraryTap: _showPromptLibrary,
                        ),
                      ),
                      Container(height: 1.h, color: AppColors.divider),
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
              : ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 260.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: ImageGenInputPanel(
                          config: config,
                          ctrl: _ctrl,
                          ref: widget.ref,
                          promptCtrl: _promptCtrl,
                          negPromptCtrl: _negPromptCtrl,
                          onPromptLibraryTap: _showPromptLibrary,
                        ),
                      ),
                      Container(width: 1.w, color: AppColors.divider),
                      Expanded(
                        flex: 3,
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
        );
      },
    );
  }
}
