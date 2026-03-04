import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';

import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;

/// 全屏图片预览：双指缩放、点击关闭
///
/// 复用 easy_image_viewer，统一配置。
void showImageLightbox(
  BuildContext context, {
  required String imageUrl,
}) {
  if (imageUrl.isEmpty) return;
  showImageViewer(
    context,
    CachedNetworkImageProvider(resolveFileUrl(imageUrl)),
    swipeDismissible: true,
    doubleTapZoomable: true,
  );
}
