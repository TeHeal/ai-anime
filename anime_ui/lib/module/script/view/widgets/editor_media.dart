import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/storyboard_script.dart';
import 'package:anime_ui/module/script/view/widgets/editor_common.dart';

// ---------------------------------------------------------------------------
// 6. 图像 & 7. 视频
// ---------------------------------------------------------------------------

Widget buildImageFull(ShotV4 shot, bool editing) {
  final img = shot.image;
  if (img == null || !img.enabled) {
    return Text('未启用',
        style: TextStyle(color: Colors.grey[600], fontSize: 13));
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(spacing: 12, runSpacing: 10, children: [
        readField('类型', img.type),
        readField('风格', img.style),
        readField('分辨率', img.resolution),
        readField('宽高比', img.aspectRatio),
        readField('优先级', img.priority),
      ]),
      const SizedBox(height: 10),
      readField('提示词', img.prompt, fullWidth: true),
      const SizedBox(height: 10),
      readField('反向提示词', img.negativePrompt, fullWidth: true),
      if (img.overlay != null) ...[
        const SizedBox(height: 12),
        _overlayCard('叠加特效', img.overlay!),
      ],
    ],
  );
}

Widget buildVideoFull(ShotV4 shot, bool editing) {
  final vid = shot.video;
  if (vid == null || !vid.enabled) {
    return Text('未启用',
        style: TextStyle(color: Colors.grey[600], fontSize: 13));
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(spacing: 12, runSpacing: 10, children: [
        readField('类型', vid.type),
        readField('帧率', '${vid.frameRate}fps'),
        readField('运镜', vid.cameraMovement),
        readField('转场', vid.transition),
        readField('优先级', vid.priority),
      ]),
      const SizedBox(height: 10),
      readField('提示词', vid.prompt, fullWidth: true),
      const SizedBox(height: 10),
      readField('反向提示词', vid.negativePrompt, fullWidth: true),
      if (vid.dependsOn.isNotEmpty) ...[
        const SizedBox(height: 10),
        readField('依赖', vid.dependsOn.join(', '), fullWidth: true),
      ],
      if (vid.overlay != null) ...[
        const SizedBox(height: 12),
        _overlayCard('叠加特效', vid.overlay!),
      ],
      if (vid.lipSync != null) ...[
        const SizedBox(height: 12),
        _lipSyncCard(vid.lipSync!),
      ],
    ],
  );
}

Widget _overlayCard(String title, OverlayEffect overlay) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                  overlay.enabled ? AppIcons.check : AppIcons.circleOutline,
                  size: 14,
                  color:
                      overlay.enabled ? Colors.green : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: overlay.enabled
                          ? Colors.white
                          : Colors.grey[500])),
            ],
          ),
        ),
        if (overlay.enabled) ...[
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 12, runSpacing: 8, children: [
              miniField('类型', overlay.type),
              SizedBox(
                  width: double.infinity,
                  child: miniField('提示词', overlay.prompt)),
              SizedBox(
                  width: double.infinity,
                  child: miniField('反向提示词', overlay.negativePrompt)),
              miniField('优先级', overlay.priority),
            ]),
          ),
        ],
      ],
    ),
  );
}

Widget _lipSyncCard(LipSyncConfig lipSync) {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF252540),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[800]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(
                  lipSync.enabled
                      ? AppIcons.check
                      : AppIcons.circleOutline,
                  size: 14,
                  color:
                      lipSync.enabled ? Colors.green : Colors.grey[600]),
              const SizedBox(width: 8),
              Text('口型同步',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: lipSync.enabled
                          ? Colors.white
                          : Colors.grey[500])),
            ],
          ),
        ),
        if (lipSync.enabled) ...[
          Divider(height: 1, color: Colors.grey[800]),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(spacing: 12, runSpacing: 8, children: [
              miniField('类型', lipSync.type),
              miniField('依赖', lipSync.dependsOn.join(', ')),
              miniField('优先级', lipSync.priority),
            ]),
          ),
        ],
      ],
    ),
  );
}
