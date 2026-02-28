import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/widgets/app_dialog.dart';
import 'image_gen_config.dart';
import 'image_gen_view.dart';

// ─── 对外唯一入口 ─────────────────────────────────────────

/// 所有需要人工参与的图像生成，统一调用此函数。
///
/// 示例（资源库）：
/// ```dart
/// ImageGenDialog.show(context, ref,
///   config: ImageGenConfig.style(
///     onSaved: (urls, mode) async {
///       await ref.read(resourceListProvider.notifier)
///           .addGeneratedImages(urls, libraryType: 'style');
///     },
///   ),
/// );
/// ```
///
/// 示例（分镜板）：
/// ```dart
/// ImageGenDialog.show(context, ref,
///   config: ImageGenConfig.shot(
///     onSaved: (urls, _) async {
///       await ref.read(boardProvider.notifier)
///           .setShotImage(shotId, urls.first);
///     },
///   ),
/// );
/// ```
abstract final class ImageGenDialog {
  ImageGenDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required ImageGenConfig config,
  }) {
    return AppDialog.show(context, builder: (_, close) {
      return ImageGenView(config: config, ref: ref, onClose: close);
    });
  }
}
