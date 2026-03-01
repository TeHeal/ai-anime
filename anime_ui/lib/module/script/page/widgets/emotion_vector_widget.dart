import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// 情绪向量常量 (IndexTTS2 8-dim emotion vector)
// ---------------------------------------------------------------------------

const emotionLabels = ['开心', '愤怒', '悲伤', '恐惧', '厌恶', '忧郁', '惊讶', '平静'];

const emotionColors = [
  AppColors.emotionHappy,
  AppColors.emotionAngry,
  AppColors.emotionSad,
  AppColors.emotionFear,
  AppColors.emotionDisgust,
  AppColors.emotionMelancholy,
  AppColors.emotionSurprise,
  AppColors.emotionCalm,
];

const emotionIcons = ['😊', '😡', '😢', '😨', '🤢', '😔', '😮', '😌'];

// ---------------------------------------------------------------------------
// 情绪向量组件 (IndexTTS2 8-dim)
// ---------------------------------------------------------------------------

class EmotionVectorWidget extends StatelessWidget {
  final List<double> vector;
  final bool editing;
  final ValueChanged<List<double>> onChanged;

  const EmotionVectorWidget({
    super.key,
    required this.vector,
    required this.editing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final dims = vector.length.clamp(0, 8);
    if (dims == 0 && !editing) {
      return Text(
        '无数据',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDarker),
      );
    }

    final effectiveVec = dims >= 8
        ? vector
        : List.generate(8, (i) => i < dims ? vector[i] : 0.0);

    return Column(
      children: List.generate(8, (i) {
        final val = effectiveVec[i].clamp(0.0, 1.2);
        final normalized = val / 1.2;
        return Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.tinyGap.h),
          child: Row(
            children: [
              SizedBox(
                width: 24.w,
                child: Text(emotionIcons[i], style: AppTextStyles.bodyMedium),
              ),
              SizedBox(
                width: 40.w,
                child: Text(
                  emotionLabels[i],
                  style: AppTextStyles.tiny.copyWith(color: AppColors.muted),
                ),
              ),
              Expanded(
                child: editing
                    ? SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          activeTrackColor: emotionColors[i],
                          inactiveTrackColor: AppColors.surfaceVariant,
                          thumbColor: emotionColors[i],
                          overlayColor: emotionColors[i].withValues(alpha: 0.2),
                        ),
                        child: Slider(
                          value: val,
                          min: 0,
                          max: 1.2,
                          onChanged: (v) {
                            final newVec = List<double>.from(effectiveVec);
                            newVec[i] = double.parse(v.toStringAsFixed(2));
                            onChanged(newVec);
                          },
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(RadiusTokens.xs.r),
                        child: SizedBox(
                          height: 8.h,
                          child: LinearProgressIndicator(
                            value: normalized,
                            backgroundColor: AppColors.surfaceVariant,
                            color: emotionColors[i],
                          ),
                        ),
                      ),
              ),
              SizedBox(width: Spacing.sm.w),
              SizedBox(
                width: 32.w,
                child: Text(
                  val.toStringAsFixed(2),
                  style: AppTextStyles.tiny.copyWith(
                    color: AppColors.muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
