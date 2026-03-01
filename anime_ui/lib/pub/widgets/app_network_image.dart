import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 网络图片组件：缓存、占位、失败重试
///
/// 替代 Image.network，统一处理加载态与错误态
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      url,
      fit: fit,
      width: width?.w,
      height: height?.h,
      cache: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.lg.r),
                child: CircularProgressIndicator(strokeWidth: 2.r),
              ),
            );
          case LoadState.failed:
            return Center(
              child: Icon(
                AppIcons.brokenImage,
                size: (Spacing.xl * 2).r,
                color: AppColors.mutedDarker,
              ),
            );
          case LoadState.completed:
            return null;
        }
      },
    );
  }
}
