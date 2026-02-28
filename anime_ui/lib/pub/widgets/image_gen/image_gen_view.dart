import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/resources/providers/resource_state.dart';
import 'package:anime_ui/pub/models/resource.dart';
import '../model_selector/model_selector.dart';
import '../prompt_field_with_assistant.dart';
import '../prompt_library_dialog.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'image_gen_config.dart';
import 'image_gen_controller.dart';
import 'image_lightbox.dart';
import 'sub_widgets/gen_result_grid.dart';
import 'sub_widgets/mode_badge.dart';
import 'sub_widgets/output_count_bar.dart';
import 'sub_widgets/ratio_picker.dart';
import 'sub_widgets/ref_image_grid.dart';

// ─── 主视图（左右双栏，纯 StatefulWidget + ListenableBuilder）───

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

  // ─── 生成逻辑 ────────────────────────────────────────────

  Future<void> _generate() async {
    await _ctrl.generate(
      onGenerate: ({
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
        final notifier = widget.ref.read(resourceListProvider.notifier);

        // 构造参考图字符串（单张用 referenceImageUrl，多张暂拼接逗号）
        final refImgUrl = refImages.isNotEmpty ? refImages.first : '';
        final multiRefImgs = refImages.length > 1 ? refImages : <String>[];

        // 确定 size 参数
        String sizeParam = '';
        int? w = width;
        int? h = height;
        if (ratio.isEmpty) {
          sizeParam = resolution;
          w = null;
          h = null;
        }

        // 分批执行（outputCount 次，或一次性）
        final tasks = <Future<void>>[];
        final count = outputCount;
        for (int i = 0; i < count; i++) {
          tasks.add(_generateOne(
            notifier: notifier,
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
          ));
        }
        await Future.wait(tasks);
      },
    );
  }

  Future<void> _generateOne({
    required dynamic notifier,
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
    final resourceId = await notifier.generateImage(
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
      final resources = widget.ref.read(resourceListProvider).value ?? [];
      final generated = resources.where((r) => r.id == resourceId).firstOrNull;
      if (generated != null && generated.thumbnailUrl.isNotEmpty) {
        onResult(generated.thumbnailUrl);
      }
    }
  }

  // ─── 保存选中结果 ──────────────────────────────────────

  Future<void> _saveResults() async {
    if (_ctrl.results.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final urls = _ctrl.results.map((r) => r.url).toList();
      await config.onSaved(
        urls,
        _ctrl.mode,
        prompt: _promptCtrl.text.trim(),
        negativePrompt: _negPromptCtrl.text.trim(),
      );
      if (mounted) widget.onClose?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败：$e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── 从提示词库选择 ────────────────────────────────────

  void _showPromptLibrary(ValueChanged<String> onSelected) {
    final resources = widget.ref.read(resourceListProvider).value ?? [];
    final prompts = resources.where((r) => r.libraryType == 'prompt').toList();
    if (prompts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('提示词库中暂无模板'),
          backgroundColor: Colors.grey[800],
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

  // ─── BUILD ────────────────────────────────────────────

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
              maxWidth: 900,
              maxHeight: 700,
              minWidth: 600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                Flexible(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 左侧：输入区 ──
                      SizedBox(
                        width: 360,
                        child: _buildInputPanel(),
                      ),
                      // 分割线
                      Container(
                        width: 1,
                        color: Colors.grey[850],
                      ),
                      // ── 右侧：结果区 ──
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

  // ─── Header ───────────────────────────────────────────

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
            child: Icon(AppIcons.magicStick, size: 18, color: accent),
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
                ModeBadge(mode: _ctrl.mode, accent: accent),
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

  // ─── 左侧：输入面板 ───────────────────────────────────

  Widget _buildInputPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 提示词
          _buildPromptField(),
          const SizedBox(height: 16),

          // 参考图（根据 config 约束决定是否显示）
          if (config.maxRefImages > 0) ...[
            RefImageGrid(
              controller: _ctrl,
              maxImages: config.maxRefImages,
              accent: accent,
            ),
            const SizedBox(height: 16),
          ],

          // 高级选项折叠区
          _buildAdvancedToggle(),
          if (_showAdvanced) ...[
            const SizedBox(height: 12),
            _buildAdvancedContent(),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptField() {
    return PromptFieldWithAssistant(
      controller: _promptCtrl,
      hint: config.promptHint,
      accent: accent,
      quickPrompts: config.quickPrompts,
      onLibraryTap: (setText) => _showPromptLibrary(setText),
      negPromptController: _negPromptCtrl,
      negPromptHint: '不想出现的元素，如：模糊、变形、低质量…',
      negOnLibraryTap: (setText) => _showPromptLibrary(setText),
      onSaveToLibrary: (text, name, {required bool isNegative}) async {
        await widget.ref.read(resourceListProvider.notifier).addResource(
          Resource(
            name: name,
            libraryType: 'prompt',
            modality: 'text',
            description: text,
          ),
        );
      },
    );
  }

  Widget _buildAdvancedToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showAdvanced = !_showAdvanced),
      child: Row(
        children: [
          Icon(
            _showAdvanced ? AppIcons.expandMore : AppIcons.chevronRight,
            size: 13,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 5),
          Text(
            '高级选项（比例 / 模型）',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RatioPicker(
          selectedRatio: _ctrl.ratio,
          selectedResolution: _ctrl.resolution,
          allowedRatios: config.allowedRatios,
          accent: accent,
          onRatioChanged: _ctrl.setRatio,
          onResolutionChanged: _ctrl.setResolution,
        ),
        const SizedBox(height: 14),
        ModelSelector(
          serviceType: 'image',
          accent: accent,
          selected: _ctrl.selectedModel,
          style: ModelSelectorStyle.dialog,
          onChanged: _ctrl.setModel,
        ),
        // 尺寸验证提示
        if (_ctrl.sizeValidationError != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(AppIcons.warning, size: 13, color: Colors.orange[400]),
              const SizedBox(width: 4),
              Text(
                _ctrl.sizeValidationError!,
                style: TextStyle(fontSize: 11, color: Colors.orange[400]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ─── 右侧：结果面板 ───────────────────────────────────

  Widget _buildResultPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 输出数量
          OutputCountBar(
            value: _ctrl.outputCount,
            maxCount: config.maxOutputCount,
            accent: accent,
            onChanged: _ctrl.setOutputCount,
          ),
          if (config.maxOutputCount > 1) const SizedBox(height: 16),

          // 结果网格
          GenResultGrid(
            results: _ctrl.results,
            isGenerating: _ctrl.isGenerating,
            progress: _ctrl.progress,
            accent: accent,
            outputCount: _ctrl.outputCount,
            onImageTap: (url) => _showLightbox(url),
          ),

          // 错误提示
          if (_ctrl.hasError && _ctrl.errorMsg != null) ...[
            const SizedBox(height: 12),
            _buildError(_ctrl.errorMsg!),
          ],

          // 结果操作
          if (_ctrl.isDone && _ctrl.results.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildResultActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.error, size: 16, color: Colors.red[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(fontSize: 12, color: Colors.red[300]),
            ),
          ),
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
          onPressed: _isSaving ? null : _saveResults,
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
          label: Text(
            '保存 ${_ctrl.results.length} 张',
          ),
          style: FilledButton.styleFrom(backgroundColor: accent),
        ),
      ],
    );
  }

  // ─── Footer ───────────────────────────────────────────

  Widget _buildFooter() {
    final canGenerate = !_ctrl.isGenerating &&
        (_promptCtrl.text.isNotEmpty || _ctrl.refImages.isNotEmpty);

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
              _ctrl.progress > 0
                  ? '生成中 ${_ctrl.progress}%…'
                  : '生成中…',
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
            onPressed: canGenerate ? _generate : null,
            icon: Icon(
              _ctrl.isGenerating ? AppIcons.inProgress : AppIcons.magicStick,
              size: 16,
            ),
            label: Text(_ctrl.isGenerating ? '生成中…' : '开始生成'),
            style: FilledButton.styleFrom(
              backgroundColor: canGenerate ? accent : Colors.grey[800],
              foregroundColor: canGenerate ? Colors.white : Colors.grey[600],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 大图预览 ─────────────────────────────────────────

  void _showLightbox(String url) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      pageBuilder: (_, _, _) => ImageLightbox(
        imageUrl: resolveFileUrl(url),
        accent: accent,
      ),
    ));
  }
}
