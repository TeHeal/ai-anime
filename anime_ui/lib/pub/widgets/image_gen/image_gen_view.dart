import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/providers/resource_list_port_provider.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';
import 'components/image_gen_footer.dart';
import 'components/image_gen_header.dart';
import 'components/image_gen_input_panel.dart';
import 'components/image_gen_result_panel.dart';
import 'image_gen_config.dart';
import 'image_gen_controller.dart';

/// 图像生成弹窗视图
///
/// 用于角色参考图、风格图、表情图、道具图等场景的 AI 图像生成。
/// 左侧为提示词、参考图、宽高比等输入区，右侧为生成预览区。
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
  /// 生成控制器：模式、参考图、输出数量、宽高比等
  late final ImageGenController _ctrl;
  /// 正向提示词输入框
  late final TextEditingController _promptCtrl;
  /// 反向提示词输入框
  late final TextEditingController _negPromptCtrl;
  /// 保存中状态，用于禁用重复点击
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
    // 输入框变化时同步到控制器
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

  /// 执行生成：由控制器校验参数后回调，按 outputCount 并发多张
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

            // 智能模式（ratio 为空）时用 size 参数，否则用 width/height
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

  /// 单张生成：调用 port 的 generateImage，完成后通过 onResult 回传缩略图 URL
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

  /// 保存生成结果到目标库，调用 config.onSaved 后关闭弹窗
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
        showToast(context, '保存失败：$e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// 打开提示词库弹窗，选择后填入输入框
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

  /// 大图预览：使用 easy_image_viewer 全屏查看
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
        return Builder(
            builder: (context) {
              final narrow = MediaQuery.sizeOf(context).width < Breakpoints.md;
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: narrow ? 520.w : 920.w,
                  maxHeight: 740.h,
                  minWidth: narrow ? 320.w : 560.w,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题栏：模式切换、关闭
                    ImageGenHeader(
                      config: config,
                      ctrl: _ctrl,
                      accent: accent,
                      onClose: widget.onClose ?? () => Navigator.pop(context),
                    ),
                    // 主内容区：不撑满，按内容最小占用（loose 避免多余空白）
                    Flexible(
                      fit: FlexFit.loose,
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
                            ),
                    // 底部操作栏：取消、开始生成
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
        );
      },
    );
  }
}
