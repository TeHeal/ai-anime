/// 统一 Toast 与提示词库弹窗的辅助函数
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/widgets/prompt_library_dialog.dart';

/// Toast 语义类型
enum _ToastType { success, error, info }

/// 从顶部中心弹出轻量通知条（基于 shadcn_flutter ToastLayer）
///
/// [isError] 为 true 时红色错误样式，[isInfo] 为 true 时蓝色信息样式，否则绿色成功样式。
void showToast(
  BuildContext context,
  String msg, {
  bool isError = false,
  bool isInfo = false,
  Duration duration = const Duration(seconds: 3),
}) {
  if (!context.mounted) return;
  final type = isError
      ? _ToastType.error
      : (isInfo ? _ToastType.info : _ToastType.success);

  shadcn.showToast(
    context: context,
    location: shadcn.ToastLocation.topCenter,
    showDuration: duration,
    builder: (ctx, overlay) => _ToastCard(
      message: msg,
      type: type,
      onClose: overlay.close,
    ),
  );
}

/// 内部 Toast 卡片 Widget（适配项目设计系统）
class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.message,
    required this.type,
    required this.onClose,
  });

  final String message;
  final _ToastType type;
  final VoidCallback onClose;

  Color get _bgColor {
    switch (type) {
      case _ToastType.error:
        return AppColors.error;
      case _ToastType.info:
        return AppColors.info;
      case _ToastType.success:
        return AppColors.success;
    }
  }

  IconData get _icon {
    switch (type) {
      case _ToastType.error:
        return AppIcons.errorOutline;
      case _ToastType.info:
        return AppIcons.info;
      case _ToastType.success:
        return AppIcons.check;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.6,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.cardPadding.w,
            vertical: Spacing.md.h,
          ),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
            boxShadow: [
              BoxShadow(
                color: _bgColor.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(_icon, color: AppColors.onPrimary, size: 18.r),
              SizedBox(width: Spacing.sm.w),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: Spacing.sm.w),
              GestureDetector(
                onTap: onClose,
                child: Icon(
                  AppIcons.close,
                  color: AppColors.onPrimary.withValues(alpha: 0.7),
                  size: 16.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 显示提示词库选择对话框
///
/// [prompts] 需包含 name、description 属性。若为空则显示「提示词库中暂无模板」信息提示。
void showPromptLibrary(
  BuildContext context, {
  required List<dynamic> prompts,
  required Color accent,
  required ValueChanged<String> onSelected,
}) {
  if (prompts.isEmpty) {
    showToast(context, '提示词库中暂无模板', isInfo: true);
    return;
  }
  showDialog(
    context: context,
    builder: (ctx) => PromptLibraryDialog(
      prompts: prompts,
      accent: accent,
      onSelected: (p) {
        onSelected(p);
        Navigator.pop(ctx);
      },
    ),
  );
}
