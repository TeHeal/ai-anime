/// 剧本预览页 — 内容块编辑、待确认面板等子组件
/// 从 preview_page.dart 拆分，满足单文件 ≤600 行规范
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/services/script_parse_svc.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 内容块类型颜色与标签（供 BlockItem、UnconfirmedPanel 共用）
const previewBlockColors = {
  'action': AppColors.success,
  'dialogue': AppColors.info,
  'os': AppColors.primary,
  'closeup': AppColors.warning,
  'direction': AppColors.tagAmber,
  'unknown': AppColors.mutedDarkest,
};

const previewBlockLabels = {
  'action': '动作',
  'dialogue': '对白',
  'os': '旁白',
  'closeup': '特写',
  'direction': '导演',
  'unknown': '未知',
};

// --- Block Item ---

class PreviewBlockItem extends StatefulWidget {
  final ParsedBlock block;
  final VoidCallback? onChanged;

  const PreviewBlockItem({super.key, required this.block, this.onChanged});

  @override
  State<PreviewBlockItem> createState() => _PreviewBlockItemState();
}

class _PreviewBlockItemState extends State<PreviewBlockItem> {
  bool _editing = false;
  late TextEditingController _contentCtrl;
  late TextEditingController _charCtrl;
  late TextEditingController _emotionCtrl;

  @override
  void initState() {
    super.initState();
    _contentCtrl = TextEditingController(text: widget.block.content);
    _charCtrl = TextEditingController(text: widget.block.character);
    _emotionCtrl = TextEditingController(text: widget.block.emotion);
  }

  @override
  void didUpdateWidget(covariant PreviewBlockItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.block != widget.block) {
      _contentCtrl.text = widget.block.content;
      _charCtrl.text = widget.block.character;
      _emotionCtrl.text = widget.block.emotion;
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _charCtrl.dispose();
    _emotionCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.block.content = _contentCtrl.text;
    widget.block.character = _charCtrl.text;
    widget.block.emotion = _emotionCtrl.text;
    widget.block.confidence = 1.0;
    setState(() => _editing = false);
    widget.onChanged?.call();
  }

  void _cancel() {
    _contentCtrl.text = widget.block.content;
    _charCtrl.text = widget.block.character;
    _emotionCtrl.text = widget.block.emotion;
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final block = widget.block;
    final color = previewBlockColors[block.type] ?? AppColors.muted;
    final isLow = block.isLowConfidence;

    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(
          color: isLow
              ? AppColors.warning.withValues(alpha: 0.6)
              : AppColors.surfaceContainer,
          width: isLow ? 2 : 1,
        ),
        color: isLow
            ? AppColors.warning.withValues(alpha: 0.05)
            : AppColors.surface.withValues(alpha: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4.w,
            constraints: BoxConstraints(minHeight: 40.h),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(RadiusTokens.sm.r),
                bottomLeft: Radius.circular(RadiusTokens.sm.r),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _PreviewTypeDropdown(
                        value: block.type,
                        onChanged: (v) {
                          setState(() {
                            block.type = v;
                            if (v != 'unknown') block.confidence = 1.0;
                          });
                          widget.onChanged?.call();
                        },
                      ),
                      if (_editing) ...[
                        const SizedBox(width: Spacing.sm),
                        SizedBox(
                          width: 80.w,
                          child: TextField(
                            controller: _charCtrl,
                            style: AppTextStyles.labelMedium,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '角色',
                              hintStyle: AppTextStyles.tiny.copyWith(
                                color: AppColors.mutedDarker,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: Spacing.sm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.xs,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.sm),
                        SizedBox(
                          width: 70.w,
                          child: TextField(
                            controller: _emotionCtrl,
                            style: AppTextStyles.labelMedium,
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: '情绪',
                              hintStyle: AppTextStyles.tiny.copyWith(
                                color: AppColors.mutedDarker,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Spacing.sm,
                                vertical: Spacing.sm,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  RadiusTokens.xs,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        if (block.character.isNotEmpty) ...[
                          const SizedBox(width: Spacing.sm),
                          Text(
                            block.character,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (block.emotion.isNotEmpty) ...[
                          const SizedBox(width: Spacing.sm),
                          Text(
                            '（${block.emotion}）',
                            style: AppTextStyles.tiny.copyWith(
                              color: AppColors.mutedDark,
                            ),
                          ),
                        ],
                      ],
                      const Spacer(),
                      if (isLow && !_editing)
                        Padding(
                          padding: EdgeInsets.only(right: Spacing.sm.w),
                          child: Icon(
                            AppIcons.warning,
                            size: 14.r,
                            color: AppColors.warning,
                          ),
                        ),
                      if (_editing) ...[
                        _PreviewActionBtn(
                          icon: AppIcons.check,
                          color: AppColors.success,
                          tooltip: '保存',
                          onTap: _save,
                        ),
                        const SizedBox(width: Spacing.xs),
                        _PreviewActionBtn(
                          icon: AppIcons.close,
                          color: AppColors.muted,
                          tooltip: '取消',
                          onTap: _cancel,
                        ),
                      ] else
                        _PreviewActionBtn(
                          icon: AppIcons.editOutline,
                          color: AppColors.mutedDark,
                          tooltip: '编辑',
                          onTap: () => setState(() => _editing = true),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                  if (_editing)
                    TextField(
                      controller: _contentCtrl,
                      maxLines: null,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.all(Spacing.sm),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            RadiusTokens.xs.r,
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      block.content,
                      style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewTypeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PreviewTypeDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final color = previewBlockColors[value] ?? AppColors.muted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
      ),
      child: DropdownButton<String>(
        value: previewBlockLabels.containsKey(value) ? value : 'unknown',
        items: previewBlockLabels.entries.map((e) {
          final c = previewBlockColors[e.key] ?? AppColors.muted;
          return DropdownMenuItem(
            value: e.key,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                ),
                const SizedBox(width: Spacing.sm),
                Text(e.value, style: AppTextStyles.tiny.copyWith(color: c)),
              ],
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
        isDense: true,
        underline: const SizedBox.shrink(),
        dropdownColor: AppColors.surface,
        style: AppTextStyles.tiny.copyWith(color: color),
      ),
    );
  }
}

class _PreviewActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _PreviewActionBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xs),
          child: Icon(icon, size: 16.r, color: color),
        ),
      ),
    );
  }
}
