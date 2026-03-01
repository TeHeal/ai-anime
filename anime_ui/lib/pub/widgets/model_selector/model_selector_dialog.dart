import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/models/model_catalog.dart';
import 'model_selector.dart';

/// Compact trigger that opens a full model picker dialog on tap.
/// Best for image/video generation where detailed model info matters.
class ModelSelectorDialogTrigger extends StatelessWidget {
  const ModelSelectorDialogTrigger({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.isLoading,
    required this.onChanged,
    this.label = '模型',
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final bool isLoading;
  final ValueChanged<ModelCatalogItem?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: Spacing.sm.h),
        if (isLoading) _buildLoading() else _buildTrigger(context),
      ],
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: SizedBox(
          width: 14.w,
          height: 14.h,
          child: CircularProgressIndicator(strokeWidth: 2.r, color: accent),
        ),
      ),
    );
  }

  Widget _buildTrigger(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: Spacing.md.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceMutedDarker,
          borderRadius: BorderRadius.circular(RadiusTokens.md.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: selected != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          selected!.displayName,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selected!.features.isNotEmpty)
                          Text(
                            translateFeatures(selected!.features),
                            style: AppTextStyles.labelTinySmall.copyWith(
                              color: AppColors.onSurface.withValues(
                                alpha: 0.55,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    )
                  : Text(
                      '选择模型',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
            ),
            Icon(
              AppIcons.expandMore,
              size: 14.r,
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ModelPickerDialog(
        models: models,
        selected: selected,
        accent: accent,
        onSelected: (m) {
          onChanged(m);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

/// Full-screen dialog listing all available models with details.
class ModelPickerDialog extends StatelessWidget {
  const ModelPickerDialog({
    super.key,
    required this.models,
    required this.selected,
    required this.accent,
    required this.onSelected,
  });

  final List<ModelCatalogItem> models;
  final ModelCatalogItem? selected;
  final Color accent;
  final ValueChanged<ModelCatalogItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.xxl.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 440.w, maxHeight: 480.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  Spacing.md.w,
                  0,
                  Spacing.md.w,
                  Spacing.md.h,
                ),
                itemCount: models.length,
                itemBuilder: (_, i) => _buildItem(models[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.mid.w,
        Spacing.lg.h,
        Spacing.md.w,
        Spacing.sm.h,
      ),
      child: Row(
        children: [
          Icon(AppIcons.settings, size: 18.r, color: accent),
          SizedBox(width: Spacing.sm.w),
          Text(
            '选择模型',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              AppIcons.close,
              size: 16.r,
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(ModelCatalogItem m) {
    final isSelected = m.modelId == selected?.modelId;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.md.r),
        onTap: () => onSelected(m),
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
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            m.displayName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? accent : AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (m.isRecommended) ...[
                          SizedBox(width: Spacing.iconGapSm.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Spacing.badgeGap.w,
                              vertical: Spacing.xxs.h,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                RadiusTokens.xs.r,
                              ),
                            ),
                            child: Text(
                              '推荐',
                              style: AppTextStyles.tiny.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (m.features.isNotEmpty)
                      Text(
                        translateFeatures(m.features),
                        style: AppTextStyles.tiny.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    Text(
                      m.operatorLabel,
                      style: AppTextStyles.labelTinySmall.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) Icon(AppIcons.check, size: 18.r, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
