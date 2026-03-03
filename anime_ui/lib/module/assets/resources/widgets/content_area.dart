import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:anime_ui/pub/models/resource.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

import '../models/resource_category.dart';
import '../providers/provider.dart';
import '../style_library/style_library.dart';
import 'resource_card.dart';

/// 内容区：风格库或资源网格
class ContentArea extends ConsumerStatefulWidget {
  const ContentArea({super.key, required this.modality});

  final ResourceModality modality;

  @override
  ConsumerState<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends ConsumerState<ContentArea> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(resourceListProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final libraryType = ref.watch(selectedLibraryTypeProvider);

    if (libraryType == ResourceLibraryType.style) {
      return const StyleLibraryView();
    }

    final resources = ref.watch(filteredResourceListProvider);
    final color = widget.modality.color;
    final isTextOrAudio = widget.modality == ResourceModality.text ||
        widget.modality == ResourceModality.audio;
    final cardAspectRatio = isTextOrAudio ? 1.0 : 3 / 2;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          _ResourceFilterBar(accentColor: color),
          _ContentToolbar(totalCount: resources.length, accentColor: color),
          Expanded(
            child: resources.isEmpty
                ? _buildEmpty(context, libraryType, color)
                : _buildGrid(context, resources, cardAspectRatio, color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(
    BuildContext context,
    ResourceLibraryType libraryType,
    Color color,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            libraryType.icon,
            size: 48.r,
            color: color.withValues(alpha: 0.3),
          ),
          SizedBox(height: Spacing.md.h),
          Text(
            '${libraryType.label}暂无素材',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Spacing.xs.h),
          Text(
            '添加第一个素材开始创作',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.mutedDark),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<Resource> resources,
    double cardAspectRatio,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = Breakpoints.columnCountForWidth(
          constraints.maxWidth,
          maxCols: 5,
        );
        return GridView.builder(
          padding: EdgeInsets.all(Spacing.mid.r),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: Spacing.gridGap.w,
            mainAxisSpacing: Spacing.gridGap.h,
            childAspectRatio: _cardAspectRatio(cardAspectRatio),
          ),
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final res = resources[index];
            return ResourceCard(
              resource: res,
              accentColor: color,
              aspectRatio: cardAspectRatio,
            );
          },
        );
      },
    );
  }

  double _cardAspectRatio(double thumbAspect) {
    if (thumbAspect >= 1.0) return thumbAspect * 0.55;
    return thumbAspect * 0.42;
  }
}

/// 筛选栏：搜索
class _ResourceFilterBar extends ConsumerStatefulWidget {
  const _ResourceFilterBar({required this.accentColor});

  final Color accentColor;

  @override
  ConsumerState<_ResourceFilterBar> createState() =>
      _ResourceFilterBarState();
}

class _ResourceFilterBarState extends ConsumerState<_ResourceFilterBar> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = ref.read(resourceSearchProvider);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(selectedLibraryTypeProvider, (_, __) {
      _searchCtrl.clear();
    });
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.md.h,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: '搜索素材名称或标签…',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.muted),
          prefixIcon: Icon(
            AppIcons.search,
            size: 18.r,
            color: AppColors.muted,
          ),
          filled: true,
          fillColor: AppColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(RadiusTokens.sm.r),
            borderSide: BorderSide(color: AppColors.inputBorder),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: Spacing.md.w,
            vertical: Spacing.sm.h,
          ),
        ),
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurface),
        onChanged: (v) =>
            ref.read(resourceSearchProvider.notifier).set(v),
      ),
    );
  }
}

/// 内容工具栏：数量
class _ContentToolbar extends StatelessWidget {
  const _ContentToolbar({
    required this.totalCount,
    required this.accentColor,
  });

  final int totalCount;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.mid.w,
        vertical: Spacing.xs.h,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text(
            '$totalCount 个素材',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
