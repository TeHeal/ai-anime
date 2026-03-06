import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/services/audio_playback_svc.dart';

/// Unified voice picker dialog used across config page, edit page, etc.
///
/// Usage:
/// ```dart
/// final selected = await VoicePicker.show(context, voices: voiceResources);
/// ```
class VoicePicker extends StatefulWidget {
  const VoicePicker({
    super.key,
    required this.voices,
    required this.accentColor,
    this.selectedId,
    this.onSelected,
  });

  final List<Resource> voices;
  final Color accentColor;
  final String? selectedId;
  final ValueChanged<Resource>? onSelected;

  static Future<Resource?> show(
    BuildContext context, {
    required List<Resource> voices,
    Color accentColor = AppColors.info,
    String? selectedId,
  }) {
    return showDialog<Resource>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 480.w, maxHeight: 560.h),
          child: VoicePicker(
            voices: voices,
            accentColor: accentColor,
            selectedId: selectedId,
            onSelected: (v) => Navigator.pop(context, v),
          ),
        ),
      ),
    );
  }

  @override
  State<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<VoicePicker> {
  String _search = '';
  String _genderFilter = '';

  Color get accent => widget.accentColor;

  List<Resource> get _filtered {
    var list = widget.voices;
    if (_genderFilter.isNotEmpty) {
      list = list.where((v) {
        final gender = v.metadata['gender'] as String? ?? '';
        return gender == _genderFilter;
      }).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where(
            (v) =>
                v.name.toLowerCase().contains(q) ||
                v.tags.any((t) => t.toLowerCase().contains(q)),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        _buildFilters(),
        Flexible(
          child: items.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    Spacing.md.w,
                    0,
                    Spacing.md.w,
                    Spacing.md.h,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _VoicePickerItem(
                    voice: items[i],
                    accent: accent,
                    isSelected: items[i].id == widget.selectedId,
                    onTap: () => widget.onSelected?.call(items[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.mid.w,
        Spacing.lg.h,
        Spacing.md.w,
        Spacing.sm.h,
      ),
      child: Row(
        children: [
          Icon(AppIcons.mic, size: 18.r, color: accent),
          SizedBox(width: Spacing.sm.w),
          Text(
            '选择音色',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(AppIcons.close, size: 16.r, color: AppColors.mutedDark),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: EdgeInsets.fromLTRB(Spacing.lg.w, 0, Spacing.lg.w, Spacing.sm.h),
      child: Column(
        children: [
          SizedBox(
            height: 36.h,
            child: TextField(
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: '搜索音色…',
                hintStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.mutedDarker,
                ),
                prefixIcon: Icon(
                  AppIcons.search,
                  size: 16.r,
                  color: AppColors.mutedDark,
                ),
                filled: true,
                fillColor: AppColors.surfaceMutedDarker,
                contentPadding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  borderSide: BorderSide(color: accent),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(height: Spacing.sm.h),
          Row(
            children: [
              _filterChip('全部', ''),
              SizedBox(width: Spacing.sm.w),
              _filterChip('男声', 'male'),
              SizedBox(width: Spacing.sm.w),
              _filterChip('女声', 'female'),
              SizedBox(width: Spacing.sm.w),
              _filterChip('中性', 'neutral'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _genderFilter == value;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _genderFilter = value),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.lg.w,
            vertical: Spacing.xs.h,
          ),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : AppColors.surfaceMutedDarker,
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.4)
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? accent : AppColors.muted,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(AppIcons.mic, size: 32.r, color: AppColors.surfaceMuted),
          SizedBox(height: Spacing.lg.h),
          Text(
            '暂无可用音色',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
          ),
        ],
      ),
    );
  }
}

class _VoicePickerItem extends StatelessWidget {
  const _VoicePickerItem({
    required this.voice,
    required this.accent,
    required this.isSelected,
    required this.onTap,
  });

  final Resource voice;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;

  String? get _audioUrl {
    final url = voice.metadata['audio_url'] as String?;
    if (url != null && url.isNotEmpty) return url;
    if (voice.thumbnailUrl.isNotEmpty &&
        (voice.thumbnailUrl.endsWith('.mp3') ||
            voice.thumbnailUrl.endsWith('.wav'))) {
      return voice.thumbnailUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meta = voice.metadata;
    final gender = meta['gender'] as String? ?? '';
    final model = meta['model'] as String? ?? '';
    final hasAudio = _audioUrl != null;
    final playback = AudioPlaybackService.instance;

    return ListenableBuilder(
      listenable: playback,
      builder: (_, _) {
        final isPlaying = hasAudio && playback.isPlayingUrl(_audioUrl!);

        return Padding(
          padding: EdgeInsets.only(bottom: Spacing.xs.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(RadiusTokens.md.r),
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Spacing.md.w,
                  vertical: Spacing.lg.h,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(RadiusTokens.md.r),
                  border: isSelected
                      ? Border.all(color: accent.withValues(alpha: 0.3))
                      : null,
                ),
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: hasAudio ? SystemMouseCursors.click : SystemMouseCursors.basic,
                      child: GestureDetector(
                        onTap: hasAudio ? () => playback.play(_audioUrl!) : null,
                        child: Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: hasAudio
                                ? accent.withValues(alpha: isPlaying ? 0.25 : 0.1)
                                : AppColors.surfaceMutedDarker,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? AppIcons.stop : AppIcons.playArrow,
                            size: 18.r,
                            color: hasAudio ? accent : AppColors.mutedDarker,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Spacing.md.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            voice.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? accent : AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (voice.description.isNotEmpty)
                            Text(
                              voice.description,
                              style: AppTextStyles.tiny.copyWith(
                                color: AppColors.mutedDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (gender.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: 8.w),
                        child: Icon(
                          gender == 'female' || gender == '女'
                              ? Icons.female_rounded
                              : Icons.male_rounded,
                          size: 14.r,
                          color: AppColors.mutedDark,
                        ),
                      ),
                    if (model.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(left: Spacing.sm.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Spacing.sm.w,
                            vertical: Spacing.xxs.h,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(
                              RadiusTokens.xs.r,
                            ),
                          ),
                          child: Text(
                            model,
                            style: AppTextStyles.labelTinySmall.copyWith(
                              color: accent.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ),
                    if (isSelected)
                      Padding(
                        padding: EdgeInsets.only(left: Spacing.sm.w),
                        child: Icon(AppIcons.check, size: 16.r, color: accent),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
