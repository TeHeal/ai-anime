import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_gen_config.dart';
import 'image_gen_view.dart';

/// 所有需要人工参与的图像生成，统一调用此函数。
abstract final class ImageGenDialog {
  ImageGenDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required ImageGenConfig config,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ImageGenView(
        config: config,
        ref: ref,
      ),
    );
  }
}
