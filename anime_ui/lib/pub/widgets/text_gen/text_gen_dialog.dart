import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'text_gen_config.dart';
import 'text_gen_view.dart';

/// 文本生成弹窗统一入口
abstract final class TextGenDialog {
  TextGenDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required TextGenConfig config,
  }) {
    return showDialog(
      context: context,
      builder: (_) => TextGenView(
        config: config,
        ref: ref,
      ),
    );
  }
}
