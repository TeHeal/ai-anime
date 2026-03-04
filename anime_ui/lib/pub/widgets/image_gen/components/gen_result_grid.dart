import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/utils/url.dart' show resolveFileUrl;
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/widgets/app_network_image.dart';
import '../image_gen_controller.dart';

/// 生成结果网格（流式追加，支持点击大图预览）
class GenResultGrid extends StatelessWidget {
  const GenResultGrid({
    super.key,
    required this.results,
    required this.isGenerating,
    required this.progress,
    required this.accent,
    required this.outputCount,
    this.onImageTap,
  });

  final List<GenResult> results;
  final bool isGenerating;
  final int progress;
  final Color accent;
  final int outputCount;
  final void Function(String url)? onImageTap;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty && !isGenerating) {
      return _EmptyResultArea(accent: accent);
    }

    final crossAxisCount = outputCount == 1 ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isGenerating && results.isEmpty)
          Expanded(
            child: _GeneratingPlaceholder(accent: accent, progress: progress),
          ),
        if (results.isNotEmpty)
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: Spacing.sm.w,
                mainAxisSpacing: Spacing.sm.h,
                childAspectRatio: 1,
              ),
              itemCount: results.length,
              itemBuilder: (_, i) {
                final result = results[i];
                return _ResultCell(
                  url: result.url,
                  accent: accent,
                  onTap: () => onImageTap?.call(result.url),
                );
              },
            ),
          ),
        if (isGenerating && results.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: Spacing.sm.h),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress / 100 : null,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(accent),
              minHeight: 3.h,
            ),
          ),
      ],
    );
  }
}

/// 空状态预览区 — 径向渐变背景 + 步骤引导
class _EmptyResultArea extends StatelessWidget {
  const _EmptyResultArea({required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
        gradient: RadialGradient(
          center: const Alignment(0, 0.2),
          radius: 0.9,
          colors: [
            accent.withValues(alpha: 0.06),
            AppColors.surfaceContainerHigh,
          ],
        ),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标容器
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
              border: Border.all(color: accent.withValues(alpha: 0.1)),
            ),
            child: Icon(
              AppIcons.gallery,
              size: 24.r,
              color: accent.withValues(alpha: 0.3),
            ),
          ),
          SizedBox(height: Spacing.lg.h),
          Text(
            '生成结果将在此显示',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mutedDark,
            ),
          ),
          SizedBox(height: Spacing.xs.h),
          Text(
            '支持多张流式预览 · 点击可查看大图',
            style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
          ),
          // 步骤引导
          SizedBox(height: Spacing.xl.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepHint(num: '1', label: '输入提示词', accent: accent),
              SizedBox(width: Spacing.mid.w),
              _StepHint(num: '2', label: '选择参数', accent: accent),
              SizedBox(width: Spacing.mid.w),
              _StepHint(num: '3', label: '开始生成', accent: accent),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  const _StepHint({
    required this.num,
    required this.label,
    required this.accent,
  });

  final String num;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18.r,
          height: 18.r,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              num,
              style: AppTextStyles.tiny.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10.sp,
                color: AppColors.mutedDark,
              ),
            ),
          ),
        ),
        SizedBox(width: Spacing.iconGapSm.w),
        Text(
          label,
          style: AppTextStyles.tiny.copyWith(color: AppColors.mutedDarker),
        ),
      ],
    );
  }
}

class _GeneratingPlaceholder extends StatefulWidget {
  const _GeneratingPlaceholder({required this.accent, required this.progress});
  final Color accent;
  final int progress;

  @override
  State<_GeneratingPlaceholder> createState() => _GeneratingPlaceholderState();
}

class _GeneratingPlaceholderState extends State<_GeneratingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 0.4,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, _) => Container(
        decoration: BoxDecoration(
          color: widget.accent.withValues(alpha: _pulse.value * 0.08),
          borderRadius: BorderRadius.circular(RadiusTokens.xl.r),
          border: Border.all(
            color: widget.accent.withValues(alpha: _pulse.value * 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Spacing.xxl.w,
              height: Spacing.xxl.h,
              child: CircularProgressIndicator(
                strokeWidth: 3.r,
                color: widget.accent,
                value: widget.progress > 0 ? widget.progress / 100 : null,
              ),
            ),
            SizedBox(height: Spacing.md.h),
            Text(
              widget.progress > 0 ? '生成中… ${widget.progress}%' : '生成中…',
              style: AppTextStyles.bodySmall.copyWith(
                color: widget.accent.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCell extends StatefulWidget {
  const _ResultCell({
    required this.url,
    required this.accent,
    required this.onTap,
  });

  final String url;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_ResultCell> createState() => _ResultCellState();
}

class _ResultCellState extends State<_ResultCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppNetworkImage(
                url: resolveFileUrl(widget.url),
                fit: BoxFit.cover,
              ),
              if (_hovered)
                Container(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.38),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.lg.w,
                        vertical: Spacing.chipPaddingV.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.shadowOverlay.withValues(alpha: 0.54),
                        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            AppIcons.search,
                            size: 13.r,
                            color: AppColors.onPrimary,
                          ),
                          SizedBox(width: Spacing.xs.w),
                          Text(
                            '查看大图',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
