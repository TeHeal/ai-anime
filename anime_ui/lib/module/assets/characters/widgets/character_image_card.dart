import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/services/file_svc.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/utils/snackbar_helpers.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';

const _angleLabels = {
  'front': '正面',
  'side': '侧面',
  'back': '背面',
  'three_quarter': '3/4',
};

/// 16:9 主图比例
const double _ratioW = 16.0;
const double _ratioH = 9.0;
const double _innerGap = 16.0;
const double _thumbGap = 8.0;

/// 角色形象卡片：16:9 主图 + 右侧三张角度缩略图 + AI 生成 / 上传
class CharacterImageCard extends ConsumerStatefulWidget {
  const CharacterImageCard({super.key, required this.character});

  final Character character;

  @override
  ConsumerState<CharacterImageCard> createState() => _CharacterImageCardState();
}

class _CharacterImageCardState extends ConsumerState<CharacterImageCard> {
  bool _uploading = false;

  Character get c => widget.character;

  String? _urlForAngle(String angle) {
    for (final img in c.referenceImages) {
      if ((img['angle'] as String? ?? '') == angle) {
        final url = img['url'] as String? ?? '';
        if (url.isNotEmpty) return url;
      }
    }
    if (angle == 'front' && c.imageUrl.isNotEmpty) return c.imageUrl;
    return null;
  }

  Future<void> _handleGenerate() async {
    if (c.id == null) return;
    await ImageGenDialog.show(
      context,
      ref,
      config: ImageGenConfig.character(
        onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
          if (urls.isEmpty || c.id == null) return;
          await ref.read(assetCharactersProvider.notifier).addReferenceImage(
                c.id!,
                angle: 'front',
                url: urls.first,
                genMeta: {'prompt': prompt, 'negativePrompt': negativePrompt},
              );
        },
      ),
    );
  }

  Future<void> _handleUpload() async {
    if (c.id == null) return;
    final refImages = c.referenceImages;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    final existingAngles =
        refImages.map((img) => img['angle'] as String? ?? '').toSet();
    final available = _angleLabels.entries
        .where((e) => !existingAngles.contains(e.key))
        .toList();
    if (available.isEmpty) {
      if (mounted) showToast(context, '所有角度已有参考图', isInfo: true);
      return;
    }

    String selectedAngle = available.first.key;
    if (available.length > 1 && mounted) {
      final picked = await showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            '选择角度',
            style: AppTextStyles.h4.copyWith(color: AppColors.onSurface),
          ),
          backgroundColor: AppColors.surfaceMutedDarker,
          children: available
              .map(
                (e) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(ctx, e.key),
                  child: Text(
                    e.value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      );
      if (picked == null) return;
      selectedAngle = picked;
    }

    setState(() => _uploading = true);
    try {
      final url = await FileService().upload(
        file.bytes!,
        file.name,
        category: 'character_reference',
      );
      await ref.read(assetCharactersProvider.notifier).addReferenceImage(
            c.id!,
            angle: selectedAngle,
            url: url,
          );
      if (mounted) {
        showToast(context, '已上传到「${_angleLabels[selectedAngle]}」');
      }
    } catch (e) {
      if (mounted) showToast(context, '上传失败: $e', isError: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;

          // 计算主图和缩略图尺寸：主图 16:9，右侧 3 张缩略图等高排列
          // mainW + _innerGap + thumbW = available
          // mainH = mainW * 9/16
          // thumbH = (mainH - 2*_thumbGap) / 3
          // thumbW = thumbH * 16/9
          final mainW = ((available - _innerGap + 32 * _thumbGap / 27) * 3 / 4)
              .clamp(available * 0.5, available - _innerGap - 40);
          final mainH = mainW * _ratioH / _ratioW;
          final thumbH = (mainH - _thumbGap * 2) / 3;
          final thumbW = thumbH * _ratioW / _ratioH;

          final refImages = c.referenceImages;
          final frontUrl = _urlForAngle('front');
          final sideUrl = _urlForAngle('side');
          final backUrl = _urlForAngle('back');
          final threeQuarterUrl = _urlForAngle('three_quarter');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '形象参考',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: Spacing.md.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainImage(frontUrl, mainW, mainH),
                  const SizedBox(width: _innerGap),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _AngleThumb(
                        url: sideUrl,
                        label: '侧',
                        angle: 'side',
                        refImages: refImages,
                        characterId: c.id,
                        width: thumbW,
                        height: thumbH,
                      ),
                      const SizedBox(height: _thumbGap),
                      _AngleThumb(
                        url: backUrl,
                        label: '背',
                        angle: 'back',
                        refImages: refImages,
                        characterId: c.id,
                        width: thumbW,
                        height: thumbH,
                      ),
                      const SizedBox(height: _thumbGap),
                      _AngleThumb(
                        url: threeQuarterUrl,
                        label: '3/4',
                        angle: 'three_quarter',
                        refImages: refImages,
                        characterId: c.id,
                        width: thumbW,
                        height: thumbH,
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: Spacing.md.h),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: c.isGenerating ? null : _handleGenerate,
                    icon: Icon(
                      AppIcons.autoAwesome,
                      size: 16.r,
                      color: c.isGenerating ? AppColors.muted : null,
                    ),
                    label: Text(c.isGenerating ? '生成中...' : 'AI 生成'),
                  ),
                  SizedBox(width: Spacing.sm.w),
                  OutlinedButton.icon(
                    onPressed: _uploading ? null : _handleUpload,
                    icon: _uploading
                        ? SizedBox(
                            width: 14.r,
                            height: 14.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(AppIcons.upload, size: 16.r),
                    label: Text(_uploading ? '上传中...' : '上传'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainImage(String? url, double width, double height) {
    if (width <= 0 || height <= 0) return const SizedBox.shrink();

    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
        child: CachedNetworkImage(
          imageUrl: resolveFileUrl(url),
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.categoryCharacter.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
      ),
      child: Center(
        child: Text(
          c.name.isNotEmpty ? c.name.characters.first : '?',
          style: AppTextStyles.h1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.categoryCharacter,
          ),
        ),
      ),
    );
  }
}

/// 侧栏角度缩略图
class _AngleThumb extends ConsumerWidget {
  const _AngleThumb({
    required this.url,
    required this.label,
    required this.angle,
    required this.refImages,
    required this.characterId,
    required this.width,
    required this.height,
  });

  final String? url;
  final String label;
  final String angle;
  final List<Map<String, dynamic>> refImages;
  final String? characterId;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (width <= 0 || height <= 0) return const SizedBox.shrink();

    final existingIdx = refImages.indexWhere(
      (img) => (img['angle'] as String? ?? '') == angle,
    );
    final hasImage = url != null && url!.isNotEmpty;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        color: hasImage ? null : AppColors.surfaceMutedDarker,
        border: Border.all(color: AppColors.border),
        image: hasImage
            ? DecorationImage(
                image: CachedNetworkImageProvider(resolveFileUrl(url!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          if (!hasImage)
            Center(
              child: Icon(
                AppIcons.add,
                size: 18.r,
                color: AppColors.mutedDark,
              ),
            ),
          Positioned(
            bottom: 3.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.tiny.copyWith(
                  color: AppColors.mutedLight,
                  shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                ),
              ),
            ),
          ),
          if (existingIdx >= 0 && characterId != null)
            Positioned(
              top: 2.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => ref
                    .read(assetCharactersProvider.notifier)
                    .deleteReferenceImage(characterId!, existingIdx),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.xs.w,
                    vertical: 1.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                  ),
                  child: Text(
                    '删除',
                    style: AppTextStyles.tiny.copyWith(
                      fontSize: 9.sp,
                      color: AppColors.mutedLight,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
