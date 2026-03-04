import 'package:flutter/material.dart';

/// 统一动效令牌，避免动画时长/曲线散落各处
///
/// 参考 Material Design 3 motion 规范，结合项目实际使用情况。
/// 使用方式：`MotionTokens.durationMedium`、`MotionTokens.curveStandard`。
abstract final class MotionTokens {
  // ── 时长 ──

  /// 微交互（hover、ripple）
  static const Duration durationFast = Duration(milliseconds: 150);

  /// 标准交互（展开/折叠、切换）
  static const Duration durationMedium = Duration(milliseconds: 250);

  /// 页面过渡、大面积变化
  static const Duration durationSlow = Duration(milliseconds: 350);

  /// 强调动效（入场、引导）
  static const Duration durationEmphasis = Duration(milliseconds: 500);

  // ── 曲线 ──

  /// 标准 ease-out（展开、进入）
  static const Curve curveStandard = Curves.easeOutCubic;

  /// 快出慢进（消失、折叠）
  static const Curve curveDecelerate = Curves.easeOut;

  /// 弹性（按钮点击反馈、卡片弹回）
  static const Curve curveSpring = Curves.easeOutBack;

  /// 线性（进度条、计时器）
  static const Curve curveLinear = Curves.linear;

  /// 平滑（大面积过渡）
  static const Curve curveSmooth = Curves.easeInOut;
}
