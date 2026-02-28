import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';

/// 图片大图预览灯箱（全屏遮罩 + 缩放查看）
class ImageLightbox extends StatelessWidget {
  const ImageLightbox({super.key, required this.imageUrl, required this.accent});

  final String imageUrl;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(
                AppIcons.brokenImage,
                size: 64,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
