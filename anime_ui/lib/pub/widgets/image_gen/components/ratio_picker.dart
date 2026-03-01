import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 宽高比选择器（含分辨率切换）
class RatioPicker extends StatelessWidget {
  const RatioPicker({
    super.key,
    required this.selectedRatio,
    required this.selectedResolution,
    required this.allowedRatios,
    required this.accent,
    required this.onRatioChanged,
    required this.onResolutionChanged,
  });

  final String selectedRatio;
  final String selectedResolution;
  final List<String> allowedRatios; // 空 list = 全部显示
  final Color accent;
  final ValueChanged<String> onRatioChanged;
  final ValueChanged<String> onResolutionChanged;

  static const _allRatios = [
    ('智能', ''),
    ('1:1', '1:1'),
    ('4:3', '4:3'),
    ('3:4', '3:4'),
    ('16:9', '16:9'),
    ('9:16', '9:16'),
    ('3:2', '3:2'),
    ('2:3', '2:3'),
    ('21:9', '21:9'),
  ];

  List<(String, String)> get _visibleRatios {
    if (allowedRatios.isEmpty) return _allRatios;
    return _allRatios.where((e) => allowedRatios.contains(e.$2)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ratios = _visibleRatios;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 宽高比行
        Row(
          children: [
            Text(
              '宽高比',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
            const Spacer(),
            // 分辨率切换
            _ResolutionToggle(
              selected: selectedResolution,
              accent: accent,
              onChanged: onResolutionChanged,
            ),
          ],
        ),
        SizedBox(height: Spacing.sm.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ratios.map((entry) {
              final (label, value) = entry;
              final isSelected = selectedRatio == value;
              return Padding(
                padding: EdgeInsets.only(right: Spacing.sm.w),
                child: _RatioChip(
                  label: label,
                  value: value,
                  selected: isSelected,
                  accent: accent,
                  onTap: () => onRatioChanged(value),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RatioChip extends StatefulWidget {
  const _RatioChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_RatioChip> createState() => _RatioChipState();
}

class _RatioChipState extends State<_RatioChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final selected = widget.selected;
    final value = widget.value;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: Spacing.barHeight.w,
          height: 52.h,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : _hovered
                ? accent.withValues(alpha: 0.06)
                : AppColors.surfaceMutedDarker,
            borderRadius: BorderRadius.circular(RadiusTokens.md.r),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.5)
                  : _hovered
                  ? accent.withValues(alpha: 0.25)
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RatioIcon(value: value, accent: accent, selected: selected),
              SizedBox(height: Spacing.xs.h),
              Text(
                widget.label,
                style: AppTextStyles.labelTiny.copyWith(
                  color: selected ? accent : AppColors.mutedDark,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatioIcon extends StatelessWidget {
  const _RatioIcon({
    required this.value,
    required this.accent,
    required this.selected,
  });

  final String value;
  final Color accent;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? accent : AppColors.mutedDarker;
    double w = 14, h = 14;
    if (value.contains(':')) {
      final parts = value.split(':');
      final rw = double.tryParse(parts[0]) ?? 1;
      final rh = double.tryParse(parts[1]) ?? 1;
      if (rw > rh) {
        w = 16;
        h = 16 * rh / rw;
      } else {
        h = 16;
        w = 16 * rw / rh;
      }
    } else {
      // 智能模式：显示闪光图标
      return Icon(AppIcons.autoAwesome, size: 14.r, color: color);
    }
    return Container(
      width: w.w,
      height: h.h,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5.r),
        borderRadius: BorderRadius.circular((RadiusTokens.xs / 2).r),
      ),
    );
  }
}

class _ResolutionToggle extends StatelessWidget {
  const _ResolutionToggle({
    required this.selected,
    required this.accent,
    required this.onChanged,
  });

  final String selected;
  final Color accent;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: ['2K', '4K'].map((v) {
        final isSelected = selected == v;
        return Padding(
          padding: EdgeInsets.only(left: Spacing.sm.w),
          child: GestureDetector(
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.lg.w,
                vertical: Spacing.xs.h,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? accent.withValues(alpha: 0.15)
                    : AppColors.surfaceMutedDarker,
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                border: Border.all(
                  color: isSelected
                      ? accent.withValues(alpha: 0.4)
                      : AppColors.surfaceContainer,
                ),
              ),
              child: Text(
                v,
                style: AppTextStyles.tiny.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? accent : AppColors.mutedDark,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
