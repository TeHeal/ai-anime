import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_gen_config.dart';
import 'voice_gen_view.dart';

/// 音色生成弹窗统一入口
abstract final class VoiceGenDialog {
  VoiceGenDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required VoiceGenConfig config,
  }) {
    return showDialog(
      context: context,
      builder: (_) => VoiceGenView(
        config: config,
        ref: ref,
      ),
    );
  }
}
