import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/text.dart';

class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  static const _roleStyles = <String, ({Color bg, Color fg, String label})>{
    'owner': (
      bg: Color(0xFF7C3AED),
      fg: Color(0xFFEDE9FE),
      label: '所有者',
    ),
    'director': (
      bg: Color(0xFF2563EB),
      fg: Color(0xFFDBEAFE),
      label: '总监',
    ),
    'editor': (
      bg: Color(0xFF16A34A),
      fg: Color(0xFFDCFCE7),
      label: '编辑',
    ),
    'viewer': (
      bg: Color(0xFF6B7280),
      fg: Color(0xFFF3F4F6),
      label: '查看者',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final style = _roleStyles[role] ??
        _roleStyles['viewer']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: style.bg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: style.bg.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Text(
        style.label,
        style: AppTextStyles.labelMedium.copyWith(
          color: style.fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
