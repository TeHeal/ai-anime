import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'asset_section_label.dart';

/// 通用标签编辑器，自带 [AssetSectionLabel] + Wrap Chip 输入。
///
/// 支持回车添加标签，点击 × 删除标签。
class AssetTagEditor extends StatefulWidget {
  const AssetTagEditor({
    super.key,
    required this.tags,
    required this.onTagAdded,
    required this.onTagRemoved,
    this.accent,
    this.label = '标签',
    this.controller,
    this.showBar = true,
  });

  final List<String> tags;
  final ValueChanged<String> onTagAdded;
  final ValueChanged<String> onTagRemoved;
  final Color? accent;
  final String label;

  /// 外部控制器，不传则内部创建
  final TextEditingController? controller;
  final bool showBar;

  @override
  State<AssetTagEditor> createState() => _AssetTagEditorState();
}

class _AssetTagEditorState extends State<AssetTagEditor> {
  late final TextEditingController _ctrl;
  final _focusNode = FocusNode();
  bool _ownsCtrl = false;

  Color get _accent => widget.accent ?? AppColors.primary;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _ctrl = widget.controller!;
    } else {
      _ctrl = TextEditingController();
      _ownsCtrl = true;
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_ownsCtrl) _ctrl.dispose();
    super.dispose();
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    if (tag.isNotEmpty && !widget.tags.contains(tag)) {
      widget.onTagAdded(tag);
    }
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AssetSectionLabel(
          widget.label,
          accent: _accent,
          showBar: widget.showBar,
        ),
        SizedBox(height: Spacing.xs.h),
        MouseRegion(
          cursor: SystemMouseCursors.text,
          child: GestureDetector(
            onTap: () => _focusNode.requestFocus(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.sm.w,
                vertical: Spacing.xs.h,
              ),
              constraints: BoxConstraints(minHeight: 36.h),
              decoration: BoxDecoration(
                color: AppColors.inputBackground.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                ),
              ),
              child: Wrap(
                spacing: Spacing.xs.w,
                runSpacing: Spacing.xs.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...widget.tags.map(
                    (tag) => _TagChip(
                      label: tag,
                      accent: _accent,
                      onDelete: () => widget.onTagRemoved(tag),
                    ),
                  ),
                  IntrinsicWidth(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: 80.w),
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focusNode,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.onSurface),
                        decoration: InputDecoration(
                          hintText:
                              widget.tags.isEmpty ? '输入后按回车添加' : '添加…',
                          hintStyle: AppTextStyles.tiny
                              .copyWith(color: AppColors.mutedDark),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Spacing.xs.w,
                            vertical: Spacing.xs.h,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: _addTag,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: Spacing.md.h),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.accent,
    required this.onDelete,
  });

  final String label;
  final Color accent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm.w,
        vertical: Spacing.xxs.h,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
        border: Border.all(color: accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.tiny.copyWith(color: AppColors.onSurface),
          ),
          SizedBox(width: Spacing.xxs.w),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onDelete,
              child: Icon(
                AppIcons.close,
                size: 12.r,
                color: accent.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
