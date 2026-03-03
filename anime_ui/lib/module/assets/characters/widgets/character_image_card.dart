import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/module/assets/characters/providers/characters.dart';

/// 角色形象卡片：参考图展示 + ImageGenDialog 生成
class CharacterImageCard extends ConsumerWidget {
  const CharacterImageCard({
    super.key,
    required this.character,
  });

  final Character character;

  Character get c => character;

  static String? _imageUrlForAngle(
    List<Map<String, dynamic>> refImages,
    String angle, {
    String? mainImageUrl,
  }) {
    for (final img in refImages) {
      if ((img['angle'] as String? ?? '') == angle) {
        final url = img['url'] as String? ?? '';
        if (url.isNotEmpty) return url;
      }
    }
    if (angle == 'front' && mainImageUrl != null && mainImageUrl.isNotEmpty) {
      return mainImageUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refImages = c.referenceImages;
    final frontUrl =
        _imageUrlForAngle(refImages, 'front', mainImageUrl: c.imageUrl);

    return Container(
      padding: EdgeInsets.all(Spacing.lg.r),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '形象参考',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          SizedBox(height: Spacing.md.h),
          _buildImageArea(context, frontUrl),
          SizedBox(height: Spacing.md.h),
          OutlinedButton.icon(
            onPressed: c.isGenerating ? null : () => _handleGenerate(context, ref),
            icon: Icon(
              AppIcons.autoAwesome,
              size: 16.r,
              color: c.isGenerating ? AppColors.muted : null,
            ),
            label: Text(c.isGenerating ? '生成中...' : 'AI 生成'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageArea(BuildContext context, String? url) {
    const double aspectRatio = 3 / 4;
    final width = 180.w;
    final height = width / aspectRatio;

    if (url != null && url.isNotEmpty) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          image: DecorationImage(
            image: CachedNetworkImageProvider(resolveFileUrl(url)),
            fit: BoxFit.cover,
          ),
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

  Future<void> _handleGenerate(BuildContext context, WidgetRef ref) async {
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
}
