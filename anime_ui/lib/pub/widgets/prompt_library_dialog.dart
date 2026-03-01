import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'app_search_field.dart';

/// 通用提示词库选择对话框。
///
/// [prompts] 列表中的每个元素需要有 `name` 和 `description` 属性（dynamic）。
/// 选中后通过 [onSelected] 回调返回 description 文本。
class PromptLibraryDialog extends StatefulWidget {
  const PromptLibraryDialog({
    super.key,
    required this.prompts,
    required this.accent,
    required this.onSelected,
  });

  final List prompts;
  final Color accent;
  final ValueChanged<String> onSelected;

  @override
  State<PromptLibraryDialog> createState() => _PromptLibraryDialogState();
}

class _PromptLibraryDialogState extends State<PromptLibraryDialog> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List get _filtered {
    if (_search.isEmpty) return widget.prompts;
    final q = _search.toLowerCase();
    return widget.prompts
        .where(
          (r) =>
              (r.name as String).toLowerCase().contains(q) ||
              (r.description as String).toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.card.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w, maxHeight: 520.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.mid.w,
                Spacing.lg.h,
                Spacing.md.w,
                Spacing.sm.h,
              ),
              child: Row(
                children: [
                  Icon(
                    AppIcons.document,
                    size: Spacing.menuIconSize.r,
                    color: widget.accent,
                  ),
                  SizedBox(width: Spacing.sm.w),
                  Text(
                    '选择提示词模板',
                    style: AppTextStyles.bodyXLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      AppIcons.close,
                      size: Spacing.lg,
                      color: AppColors.mutedDark,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg.w),
              child: AppSearchField(
                controller: _searchCtrl,
                hintText: '搜索提示词…',
                width: double.infinity,
                accentColor: widget.accent,
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            SizedBox(height: Spacing.sm.h),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  Spacing.lg.w,
                  0,
                  Spacing.lg.w,
                  Spacing.lg.h,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final r = items[i];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                      onTap: () => widget.onSelected(r.description as String),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Spacing.md.w,
                          vertical: Spacing.buttonPaddingV.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            SizedBox(height: Spacing.progressBarHeight.h),
                            Text(
                              r.description as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.mutedDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
