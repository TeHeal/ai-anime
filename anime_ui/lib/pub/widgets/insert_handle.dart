import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 段落间插入按钮 — 默认居中短横线，hover 向两侧延伸 + 居中胶囊按钮
class InsertHandle extends StatefulWidget {
  const InsertHandle({super.key, required this.onInsert});

  final VoidCallback onInsert;

  @override
  State<InsertHandle> createState() => _InsertHandleState();
}

class _InsertHandleState extends State<InsertHandle> {
  bool _hovered = false;

  static const _lineColor = AppColors.border;
  static const _accent = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onInsert,
        child: SizedBox(
          height: Spacing.xxl.h,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final fullWidth = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 横线：默认 100px，hover 延伸到全宽
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeInOut,
                    width: _hovered ? fullWidth : 100.w,
                    height: (_hovered ? 1.5 : 6).h,
                    decoration: BoxDecoration(
                      color: _lineColor,
                      borderRadius: BorderRadius.circular(
                        (_hovered ? 1 : RadiusTokens.xs - 1).r,
                      ),
                    ),
                  ),
                  // 胶囊按钮
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _hovered ? 1.0 : 0.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.gridGap.w,
                        vertical: Spacing.chipPaddingV.h,
                      ),
                      decoration: BoxDecoration(
                        color: _accent,
                        borderRadius: BorderRadius.circular(
                          RadiusTokens.card.r,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.add,
                            size: Spacing.gridGap.r,
                            color: AppColors.onPrimary,
                          ),
                          SizedBox(width: Spacing.xs.w),
                          Text(
                            '新增内容',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
