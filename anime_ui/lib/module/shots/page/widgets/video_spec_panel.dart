import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/module/shots/page/provider.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 视频输出规格面板：分辨率、宽高比、时长、种子、高级选项
class VideoSpecPanel extends ConsumerWidget {
  const VideoSpecPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(compositeConfigProvider);
    final notifier = ref.read(compositeConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('视频规格'),
        SizedBox(height: Spacing.sm.h),
        // 分辨率 + 宽高比（一行）
        Row(
          children: [
            Expanded(
              child: _ResolutionSelector(
                value: config.videoResolution,
                onChanged: (v) => notifier.updateVideoSpec(resolution: v),
              ),
            ),
            SizedBox(width: Spacing.md.w),
            Expanded(
              flex: 2,
              child: _RatioSelector(
                value: config.videoRatio,
                onChanged: (v) => notifier.updateVideoSpec(ratio: v),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.md.h),
        // 时长 + 种子（一行）
        Row(
          children: [
            Expanded(
              child: _DurationSlider(
                value: config.videoDuration,
                onChanged: (v) => notifier.updateVideoSpec(duration: v),
              ),
            ),
            SizedBox(width: Spacing.md.w),
            SizedBox(
              width: 120.w,
              child: _SeedField(
                value: config.videoSeed,
                onChanged: (v) => notifier.updateVideoSpec(seed: v),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.lg.h),
        _sectionTitle('高级选项'),
        SizedBox(height: Spacing.sm.h),
        // 开关组
        Wrap(
          spacing: Spacing.sm.w,
          runSpacing: Spacing.sm.h,
          children: [
            _OptionToggle(
              icon: AppIcons.sound,
              label: '有声视频',
              enabled: config.generateAudio,
              onTap: () => notifier.updateVideoSpec(
                  generateAudio: !config.generateAudio),
            ),
            _OptionToggle(
              icon: AppIcons.film,
              label: '样片预览',
              enabled: config.draftMode,
              onTap: () =>
                  notifier.updateVideoSpec(draftMode: !config.draftMode),
              tooltip: '低成本生成预览视频，确认后再生成正式高画质版本',
            ),
            _OptionToggle(
              icon: AppIcons.clock,
              label: '离线推理',
              enabled: config.serviceTier == 'flex',
              onTap: () => notifier.updateVideoSpec(
                serviceTier:
                    config.serviceTier == 'flex' ? 'default' : 'flex',
              ),
              tooltip: '价格为在线推理 50%，适合对时延不敏感的批量场景',
            ),
            _OptionToggle(
              icon: AppIcons.link,
              label: '返回尾帧',
              enabled: config.returnLastFrame,
              onTap: () => notifier.updateVideoSpec(
                  returnLastFrame: !config.returnLastFrame),
              tooltip: '返回视频最后一帧，用于连续生成多段视频时衔接',
            ),
            _OptionToggle(
              icon: AppIcons.camera,
              label: '固定摄像头',
              enabled: config.cameraFixed,
              onTap: () => notifier.updateVideoSpec(
                  cameraFixed: !config.cameraFixed),
            ),
            _OptionToggle(
              icon: AppIcons.layers,
              label: '连续模式',
              enabled: config.continuousMode,
              onTap: () => notifier.updateVideoSpec(
                  continuousMode: !config.continuousMode),
              tooltip: '自动将上一个视频尾帧作为下一个的首帧，批量生成连贯长视频',
            ),
          ],
        ),
        if (config.draftMode) ...[
          SizedBox(height: Spacing.sm.h),
          _draftHint(),
        ],
        if (config.serviceTier == 'flex') ...[
          SizedBox(height: Spacing.sm.h),
          _offlineHint(),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.caption.copyWith(
        color: AppColors.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _draftHint() {
    return Container(
      padding: EdgeInsets.all(Spacing.sm.r),
      decoration: BoxDecoration(
        color: AppColors.tagAmber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.tagAmber.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.warning, size: 13.r,
              color: AppColors.tagAmber.withValues(alpha: 0.9)),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              '样片仅支持 480p，token 消耗更少。确认效果后可一键转为正式高清视频。',
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.tagAmber.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _offlineHint() {
    return Container(
      padding: EdgeInsets.all(Spacing.sm.r),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.clock, size: 13.r,
              color: AppColors.info.withValues(alpha: 0.7)),
          SizedBox(width: Spacing.sm.w),
          Expanded(
            child: Text(
              '离线推理价格仅为在线的 50%，但响应时间较长（小时级）。',
              style: AppTextStyles.tiny.copyWith(
                color: AppColors.info.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 分辨率选择器 ──

class _ResolutionSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ResolutionSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('分辨率',
            style: AppTextStyles.tiny
                .copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
        SizedBox(height: 4.h),
        DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          dropdownColor: AppColors.surfaceContainer,
          underline: const SizedBox(),
          style: AppTextStyles.caption.copyWith(color: AppColors.onSurface),
          items: VideoResolutionOption.all
              .map((o) => DropdownMenuItem(value: o.value, child: Text(o.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}

// ── 宽高比选择器 ──

class _RatioSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _RatioSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('宽高比',
            style: AppTextStyles.tiny
                .copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
        SizedBox(height: 4.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: VideoRatioOption.all.map((o) {
              final selected = value == o.value;
              return Padding(
                padding: EdgeInsets.only(right: Spacing.xs.w),
                child: GestureDetector(
                  onTap: () => onChanged(o.value),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: Spacing.sm.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: Text(
                      o.value,
                      style: AppTextStyles.tiny.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.onSurface.withValues(alpha: 0.55),
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── 时长滑块 ──

class _DurationSlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _DurationSlider({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('时长',
                style: AppTextStyles.tiny.copyWith(
                    color: AppColors.onSurface.withValues(alpha: 0.5))),
            const Spacer(),
            Text('${value}s',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 3.h,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 2,
            max: 12,
            divisions: 10,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}

// ── 种子输入 ──

class _SeedField extends StatelessWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  const _SeedField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Seed',
            style: AppTextStyles.tiny
                .copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
        SizedBox(height: 4.h),
        SizedBox(
          height: 30.h,
          child: TextField(
            controller: TextEditingController(
                text: value != null ? value.toString() : ''),
            style: AppTextStyles.caption.copyWith(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: '随机',
              hintStyle: AppTextStyles.tiny
                  .copyWith(color: AppColors.onSurface.withValues(alpha: 0.3)),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: Spacing.sm.w, vertical: 6.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final parsed = int.tryParse(v);
              onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }
}

// ── 选项开关 ──

class _OptionToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final String? tooltip;

  const _OptionToggle({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final chip = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: Spacing.sm.w, vertical: Spacing.xs.h),
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12.r,
              color: enabled
                  ? AppColors.primary
                  : AppColors.onSurface.withValues(alpha: 0.4),
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: AppTextStyles.tiny.copyWith(
                color: enabled
                    ? AppColors.primary
                    : AppColors.onSurface.withValues(alpha: 0.5),
                fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: chip);
    }
    return chip;
  }
}
