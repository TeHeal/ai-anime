import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/style.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_search_field.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_trigger.dart';
import 'package:anime_ui/module/assets/styles/providers/styles.dart';
import 'package:anime_ui/module/assets/styles/widgets/style_form_dialog.dart';

/// 风格图 AI 生成配置（工具栏与空状态共用）
ImageGenConfig buildStyleImageGenConfig(WidgetRef ref) {
  return ImageGenConfig.style(
    onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
      if (urls.isEmpty) return;
      final notifier = ref.read(assetStylesProvider.notifier);
      final base = DateTime.now().millisecondsSinceEpoch;
      for (var i = 0; i < urls.length; i++) {
        final url = urls[i];
        if (url.isEmpty) continue;
        final refImagesJson = jsonEncode([{'url': url}]);
        await notifier.add(Style(
          name: urls.length > 1 ? '风格-$base-${i + 1}' : '风格-$base',
          description: prompt,
          negativePrompt: negativePrompt,
          referenceImagesJson: refImagesJson,
          thumbnailUrl: url,
        ));
      }
    },
  );
}

/// 风格工具栏：搜索、上传、AI 生成
class StyleToolbar extends ConsumerStatefulWidget {
  const StyleToolbar({
    super.key,
    required this.onUpload,
  });

  final VoidCallback onUpload;

  @override
  ConsumerState<StyleToolbar> createState() => _StyleToolbarState();
}

class _StyleToolbarState extends ConsumerState<StyleToolbar> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
      text: ref.read(styleNameSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameSearch = ref.watch(styleNameSearchProvider);
    if (nameSearch.isEmpty && _searchCtrl.text.isNotEmpty) {
      _searchCtrl.clear();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.lg.w,
        vertical: Spacing.sm.h,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          AppSearchField(
            controller: _searchCtrl,
            hintText: '搜索风格名称…',
            width: 200.w,
            height: 34.h,
            onChanged: (v) => ref.read(styleNameSearchProvider.notifier).set(v),
          ),
          SizedBox(width: Spacing.sm.w),
          const Expanded(child: SizedBox.shrink()),
          FilledButton.icon(
            onPressed: widget.onUpload,
            icon: Icon(AppIcons.add, size: 16.r),
            label: const Text('创建风格'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              foregroundColor: AppColors.primary,
            ),
          ),
          SizedBox(width: Spacing.sm.w),
          ImageGenTrigger(
            config: buildStyleImageGenConfig(ref),
            label: 'AI 生成',
            icon: AppIcons.magicStick,
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

/// 显示风格创建/编辑弹窗
void showStyleFormDialog(BuildContext context, WidgetRef ref, {Style? existing}) {
  showDialog(
    context: context,
    builder: (_) => StyleFormDialog(
      ref: ref,
      existing: existing,
      onSave: (name, description, negativePrompt, refImagesJson, thumbnailUrl) {
        if (existing != null) {
          ref.read(assetStylesProvider.notifier).update(
                existing.copyWith(
                  name: name,
                  description: description,
                  negativePrompt: negativePrompt,
                  referenceImagesJson: refImagesJson,
                  thumbnailUrl: thumbnailUrl,
                ),
              );
        } else {
          ref.read(assetStylesProvider.notifier).add(Style(
                name: name,
                description: description,
                negativePrompt: negativePrompt,
                referenceImagesJson: refImagesJson,
                thumbnailUrl: thumbnailUrl,
              ));
        }
      },
    ),
  );
}
