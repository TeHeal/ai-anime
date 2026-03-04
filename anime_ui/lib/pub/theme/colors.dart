import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── 主色 ──────────────────────────────────────────

  static const Color primary = Color(0xFF9061F9);

  /// 次要强调色（Theme secondary）
  static const Color secondary = Color(0xFFA78BFA);

  /// 主色 hover 态（按钮/链接悬浮）
  static const Color primaryHover = Color(0xFFA78BFA);

  /// 主色 pressed 态（按钮/链接按下）
  static const Color primaryPressed = Color(0xFF7C3AED);

  /// 主色 subtle 背景（卡片选中、徽章底色等）
  static const Color primarySubtle = Color(0x1E9061F9);

  /// 主色/成功色上的文字（如按钮、标签）
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── 背景与表面（带紫调，亮度递增） ─────────────────
  // background(12) < surface(21) < surfaceContainer(26) < High(32) < Highest(40)

  /// 极深背景（播放器、遮罩等）
  static const Color backgroundDarkest = Color(0xFF080816);
  static const Color background = Color(0xFF0C0C18);
  static const Color surface = Color(0xFF151525);
  static const Color surfaceContainer = Color(0xFF1A1A2E);
  static const Color surfaceContainerHigh = Color(0xFF20203A);
  static const Color surfaceContainerHighest = Color(0xFF282848);
  static const Color surfaceVariant = Color(0xFF252535);
  static const Color rightPanelBackground = Color(0xFF131325);

  // ── 中性灰表面（无色调，用于弹窗、输入框、卡片等通用容器） ──

  static const Color surfaceMuted = Color(0xFF3E3E52);
  static const Color surfaceMutedDark = Color(0xFF242434);
  static const Color surfaceMutedDarker = Color(0xFF18181E);

  // ── 文字灰度（蓝灰调，从亮到暗，与紫蓝背景和谐） ──

  static const Color onSurface = Color(0xFFE2E2F0);
  static const Color mutedLight = Color(0xFFC8C8DA);
  static const Color muted = Color(0xFF9898B0);
  static const Color mutedDark = Color(0xFF6A6A82);
  static const Color mutedDarker = Color(0xFF4A4A60);

  /// 最弱蓝灰，亮度严格低于 mutedDarker
  static const Color mutedDarkest = Color(0xFF3C3C52);

  // ── 语义色 ────────────────────────────────────────

  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF97316);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);
  static const Color newTag = Color(0xFFF97316);
  static const Color tagAmber = Color(0xFFF59E0B);

  // ── 边框与分割（border 用于卡片/面板，divider 用于内部分割） ──

  static const Color divider = Color(0xFF222238);
  static const Color border = Color(0xFF2A2A44);

  // ── 输入与交互 ────────────────────────────────────

  /// 深色输入框背景（表单、下拉等）
  static const Color inputBackground = Color(0xFF0D0D18);

  /// 输入框/芯片填充（略亮于 inputBackground，用于搜索框、下拉等）
  static const Color inputFill = Color(0xFF1E1E30);

  /// 深色边框（输入框、卡片等）
  static const Color inputBorder = Color(0xFF232340);

  /// 芯片/按钮 hover 背景（用于筛选 Chip 等）
  static const Color chipBgHover = Color(0xFF38385A);

  /// 芯片/按钮 hover 边框（略亮于 inputBorder）
  static const Color chipBorderHover = Color(0xFF555578);

  // ── 导入/操作强调 ─────────────────────────────────

  /// 导入/上传类操作强调色（替代 Colors.teal）
  static const Color accentImport = Color(0xFF14B8A6);

  // ── 资产分类语义色 ────────────────────────────────

  static const Color categoryCharacter = Color(0xFF9061F9);
  static const Color categoryLocation = Color(0xFF3B82F6);
  static const Color categoryProp = Color(0xFFF97316);
  static const Color categoryStyle = Color(0xFFEC4899);
  static const Color categoryResource = Color(0xFF14B8A6);
  static const Color categoryVoice = Color(0xFF06B6D4);

  // ── 阴影与遮罩 ────────────────────────────────────

  /// 阴影/遮罩用黑色
  static const Color shadowOverlay = Color(0xFF000000);

  // ── 情绪向量色（IndexTTS2 8-dim） ─────────────────

  static const Color emotionHappy = Color(0xFFFBBF24);
  static const Color emotionAngry = Color(0xFFEF4444);
  static const Color emotionSad = Color(0xFF60A5FA);
  static const Color emotionFear = Color(0xFFA78BFA);
  static const Color emotionDisgust = Color(0xFF34D399);
  static const Color emotionMelancholy = Color(0xFF94A3B8);
  static const Color emotionSurprise = Color(0xFFF472B6);
  static const Color emotionCalm = Color(0xFF67E8F9);

  // ── 角色徽章色 ────────────────────────────────────

  static const Color roleOwnerBg = Color(0xFF7C3AED);
  static const Color roleOwnerFg = Color(0xFFEDE9FE);
  static const Color roleDirectorBg = Color(0xFF2563EB);
  static const Color roleDirectorFg = Color(0xFFDBEAFE);
  static const Color roleEditorBg = Color(0xFF16A34A);
  static const Color roleEditorFg = Color(0xFFDCFCE7);
  static const Color roleViewerBg = Color(0xFF6B7280);
  static const Color roleViewerFg = Color(0xFFF3F4F6);
}
