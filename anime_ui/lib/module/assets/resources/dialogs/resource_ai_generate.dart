import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_config.dart';
import 'package:anime_ui/pub/widgets/image_gen/image_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_config.dart';
import 'package:anime_ui/pub/widgets/text_gen/text_gen_dialog.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_config.dart';
import 'package:anime_ui/pub/widgets/voice_gen/voice_gen_dialog.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';

/// 根据素材类型的 modality 选择对应的 AI 生成对话框
void showResourceAiGenerateDialog(
  BuildContext context,
  WidgetRef ref, {
  required ResourceLibraryType libraryType,
  required Color accentColor,
}) {
  if (libraryType.modality == ResourceModality.audio) {
    VoiceGenDialog.show(
      context,
      ref,
      config: VoiceGenConfig.voiceLibrary(
        accentColor: accentColor,
        onSaved: (_) async {
          ref.read(resourceListProvider.notifier).load();
        },
      ),
    );
    return;
  }

  if (libraryType.modality == ResourceModality.text) {
    final config = switch (libraryType) {
      ResourceLibraryType.styleGuide => TextGenConfig.styleGuide(
          accentColor: accentColor,
          onComplete: (_) async {
            ref.read(resourceListProvider.notifier).load();
          },
        ),
      ResourceLibraryType.dialogueTemplate => TextGenConfig.dialogue(
          accentColor: accentColor,
          onComplete: (_) async {
            ref.read(resourceListProvider.notifier).load();
          },
        ),
      _ => TextGenConfig.newPrompt(
          accentColor: accentColor,
          category: libraryType.name,
          onComplete: (_) async {
            ref.read(resourceListProvider.notifier).load();
          },
        ),
    };
    TextGenDialog.show(context, ref, config: config);
    return;
  }

  ImageGenDialog.show(
    context,
    ref,
    config: ImageGenConfig.forLibraryType(
      libraryType.name,
      accentColor: accentColor,
      onSaved: (urls, mode, {prompt = '', negativePrompt = ''}) async {
        final notifier = ref.read(resourceListProvider.notifier);
        for (final url in urls) {
          await notifier.addResource(
            Resource(
              name:
                  '${libraryType.label}-${DateTime.now().millisecondsSinceEpoch}',
              libraryType: libraryType.name,
              modality: libraryType.modality.name,
              thumbnailUrl: url,
              metadataJson: jsonEncode({
                'prompt': prompt,
                'negativePrompt': negativePrompt,
              }),
            ),
          );
        }
        ref.read(resourceListProvider.notifier).load();
      },
    ),
  );
}
