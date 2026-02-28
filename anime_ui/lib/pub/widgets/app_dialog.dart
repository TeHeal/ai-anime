import 'package:flutter/material.dart';

/// 项目级 Dialog 统一封装。
///
/// 通过 [builder] 将安全的 `close` 回调注入到调用方，
/// 从 API 层面杜绝 `Navigator.of(context).pop()` 作用域错误。
///
/// ```dart
/// AppDialog.show(context, builder: (_, close) {
///   return MyDialogView(onClose: close);
/// });
/// ```
abstract final class AppDialog {
  AppDialog._();

  /// 显示一个全屏遮罩 Dialog。
  ///
  /// [builder] 接收两个参数：
  /// - `dialogContext`：Dialog 层级的 BuildContext（一般不需要直接使用）
  /// - `close`：关闭当前 Dialog 的安全回调，永远只弹出 Dialog 自身
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget Function(BuildContext dialogContext, VoidCallback close) builder,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return builder(
          dialogContext,
          () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  /// 显示一个可返回结果的 Dialog。
  ///
  /// ```dart
  /// final result = await AppDialog.showWithResult<String>(context,
  ///   builder: (_, close) => ConfirmDialog(onConfirm: () => close('yes')),
  /// );
  /// ```
  static Future<T?> showWithResult<T>(
    BuildContext context, {
    required Widget Function(BuildContext dialogContext, void Function([T?]) close) builder,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogContext) {
        return builder(
          dialogContext,
          ([T? result]) => Navigator.of(dialogContext).pop(result),
        );
      },
    );
  }
}
