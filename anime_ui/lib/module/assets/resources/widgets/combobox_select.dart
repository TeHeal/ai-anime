import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 可自定义输入的下拉选择组件
///
/// 展示预设选项列表，同时支持用户输入自定义值。
class ComboboxSelect extends StatefulWidget {
  const ComboboxSelect({
    super.key,
    required this.options,
    required this.value,
    required this.hint,
    required this.accentColor,
    required this.onChanged,
  });

  final List<String> options;
  final String value;
  final String hint;
  final Color accentColor;
  final ValueChanged<String> onChanged;

  @override
  State<ComboboxSelect> createState() => _ComboboxSelectState();
}

class _ComboboxSelectState extends State<ComboboxSelect> {
  final _layerLink = LayerLink();
  final _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (_) => _ComboboxOverlay(
        width: size.width,
        link: _layerLink,
        options: widget.options,
        currentValue: widget.value,
        accentColor: widget.accentColor,
        onSelect: (v) {
          widget.onChanged(v);
          _removeOverlay();
        },
        onDismiss: _removeOverlay,
      ),
    );

    overlay.insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted && _isOpen) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.value.isNotEmpty;
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _toggle,
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: Spacing.sm.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceMutedDark,
              borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
              border: Border.all(
                color: _isOpen
                    ? widget.accentColor.withValues(alpha: 0.6)
                    : AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? widget.value : widget.hint,
                    style: AppTextStyles.bodySmall.copyWith(
                      color:
                          hasValue ? AppColors.onSurface : AppColors.mutedDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18.r,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComboboxOverlay extends StatefulWidget {
  const _ComboboxOverlay({
    required this.width,
    required this.link,
    required this.options,
    required this.currentValue,
    required this.accentColor,
    required this.onSelect,
    required this.onDismiss,
  });

  final double width;
  final LayerLink link;
  final List<String> options;
  final String currentValue;
  final Color accentColor;
  final ValueChanged<String> onSelect;
  final VoidCallback onDismiss;

  @override
  State<_ComboboxOverlay> createState() => _ComboboxOverlayState();
}

class _ComboboxOverlayState extends State<_ComboboxOverlay> {
  final _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          offset: Offset(0, 42.h),
          showWhenUnlinked: false,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: widget.width,
              constraints: BoxConstraints(maxHeight: 280.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(RadiusTokens.lg.r),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.options.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: Spacing.xs.h),
                        shrinkWrap: true,
                        itemCount: widget.options.length,
                        itemBuilder: (_, i) {
                          final opt = widget.options[i];
                          final isActive = opt == widget.currentValue;
                          return InkWell(
                            onTap: () => widget.onSelect(opt),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Spacing.md.w,
                                vertical: Spacing.sm.h,
                              ),
                              color: isActive
                                  ? widget.accentColor.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      opt,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: isActive
                                            ? widget.accentColor
                                            : AppColors.onSurface,
                                        fontWeight: isActive
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isActive)
                                    Icon(
                                      Icons.check,
                                      size: 14.r,
                                      color: widget.accentColor,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: Spacing.sm.w,
                      vertical: Spacing.sm.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 32.h,
                            child: TextField(
                              controller: _customCtrl,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: '输入自定义值…',
                                hintStyle: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.muted,
                                ),
                                filled: true,
                                fillColor: AppColors.inputBackground,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: Spacing.sm.w,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(RadiusTokens.sm.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (v) {
                                final trimmed = v.trim();
                                if (trimmed.isNotEmpty) {
                                  widget.onSelect(trimmed);
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: Spacing.xs.w),
                        SizedBox(
                          height: 32.h,
                          child: TextButton(
                            onPressed: () {
                              final trimmed = _customCtrl.text.trim();
                              if (trimmed.isNotEmpty) {
                                widget.onSelect(trimmed);
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  widget.accentColor.withValues(alpha: 0.15),
                              padding: EdgeInsets.symmetric(
                                horizontal: Spacing.md.w,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '确认',
                              style: AppTextStyles.caption.copyWith(
                                color: widget.accentColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
