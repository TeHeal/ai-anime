import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/widgets/app_dialog.dart';
import 'voice_gen_config.dart';
import 'voice_gen_view.dart';

/// Unified entry point for voice generation dialogs.
///
/// Usage:
/// ```dart
/// VoiceGenDialog.show(context, ref,
///   config: VoiceGenConfig.voiceLibrary(
///     onSaved: (mode) async { /* ... */ },
///   ),
/// );
/// ```
abstract final class VoiceGenDialog {
  VoiceGenDialog._();

  static Future<void> show(
    BuildContext context,
    WidgetRef ref, {
    required VoiceGenConfig config,
  }) {
    return AppDialog.show(context, builder: (_, close) {
      return VoiceGenView(config: config, ref: ref, onClose: close);
    });
  }
}
