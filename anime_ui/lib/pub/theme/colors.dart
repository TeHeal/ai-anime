import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color primary = Color(0xFF8B5CF6);

  /// 次要强调色（Theme secondary，替代 Colors.purpleAccent）
  static const Color secondary = Color(0xFFA78BFA);

  static const Color surface = Color(0xFF1A1A2E);
  static const Color background = Color(0xFF0F0F1A);
  static const Color onSurface = Color(0xFFE4E4E7);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF97316);
  static const Color success = Color(0xFF22C55E);
  static const Color info = Color(0xFF3B82F6);
  static const Color newTag = Color(0xFFF97316);
  static const Color tagAmber = Color(0xFFF59E0B);

  // Surface variations for the dark theme
  static const Color surfaceContainer = Color(0xFF16162A);
  static const Color surfaceContainerHigh = Color(0xFF1E1E30);
  static const Color surfaceContainerHighest = Color(0xFF252540);
  static const Color surfaceVariant = Color(0xFF252535);
  static const Color divider = Color(0xFF2A2A3C);
  static const Color border = Color(0xFF2A2A40);
  static const Color rightPanelBackground = Color(0xFF15152A);

  /// 灰色语义（替代 Colors.grey[xxx]）
  static const Color mutedLight = Color(0xFFD4D4D4);
  static const Color muted = Color(0xFFA3A3A3);
  static const Color mutedDark = Color(0xFF737373);
  static const Color mutedDarker = Color(0xFF525252);
  static const Color mutedDarkest = Color(0xFF6B7280);
  static const Color surfaceMuted = Color(0xFF404040);
  static const Color surfaceMutedDark = Color(0xFF262626);
  static const Color surfaceMutedDarker = Color(0xFF1A1A1A);

  /// 导入/上传类操作强调色（替代 Colors.teal）
  static const Color accentImport = Color(0xFF14B8A6);

  /// 资产分类语义色（overview 卡片等）
  static const Color categoryCharacter = Color(0xFF8B5CF6);
  static const Color categoryLocation = Color(0xFF3B82F6);
  static const Color categoryProp = Color(0xFFF97316);
  static const Color categoryStyle = Color(0xFFEC4899);
  static const Color categoryResource = Color(0xFF14B8A6);
  static const Color categoryVoice = Color(0xFF06B6D4);

  /// 主色/成功色上的文字（如按钮、标签）
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// 深色输入框背景（表单、下拉等）
  static const Color inputBackground = Color(0xFF0F0F17);

  /// 深色边框（输入框、卡片等）
  static const Color inputBorder = Color(0xFF232336);

  /// 极深背景（播放器、遮罩等）
  static const Color backgroundDarkest = Color(0xFF0A0A1A);

  /// 阴影/遮罩用黑色
  static const Color shadowOverlay = Color(0xFF000000);

  /// 情绪向量色（IndexTTS2 8-dim）
  static const Color emotionHappy = Color(0xFFFBBF24);
  static const Color emotionAngry = Color(0xFFEF4444);
  static const Color emotionSad = Color(0xFF60A5FA);
  static const Color emotionFear = Color(0xFFA78BFA);
  static const Color emotionDisgust = Color(0xFF34D399);
  static const Color emotionMelancholy = Color(0xFF94A3B8);
  static const Color emotionSurprise = Color(0xFFF472B6);
  static const Color emotionCalm = Color(0xFF67E8F9);

  /// 角色徽章色（owner/director/editor/viewer）
  static const Color roleOwnerBg = Color(0xFF7C3AED);
  static const Color roleOwnerFg = Color(0xFFEDE9FE);
  static const Color roleDirectorBg = Color(0xFF2563EB);
  static const Color roleDirectorFg = Color(0xFFDBEAFE);
  static const Color roleEditorBg = Color(0xFF16A34A);
  static const Color roleEditorFg = Color(0xFFDCFCE7);
  static const Color roleViewerBg = Color(0xFF6B7280);
  static const Color roleViewerFg = Color(0xFFF3F4F6);
}
