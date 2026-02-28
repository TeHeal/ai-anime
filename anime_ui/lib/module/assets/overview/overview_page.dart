import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anime_ui/pub/const/routes.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/module/assets/characters/providers/characters_provider.dart';
import 'package:anime_ui/module/assets/locations/providers/locations_provider.dart';
import 'package:anime_ui/module/assets/props/providers/props_provider.dart';
import 'package:anime_ui/module/assets/overview/providers/overview_provider.dart';
import 'package:anime_ui/module/assets/overview/providers/styles_provider.dart';
import 'package:anime_ui/module/assets/resources/providers/provider.dart';
import 'package:anime_ui/module/assets/overview/widgets/asset_category_card.dart';
import 'package:anime_ui/module/assets/overview/widgets/key_issues_list.dart';
import 'package:anime_ui/module/assets/overview/widgets/readiness_bar.dart';

/// 资产总览页
class AssetOverviewPage extends ConsumerStatefulWidget {
  const AssetOverviewPage({super.key});

  @override
  ConsumerState<AssetOverviewPage> createState() => _AssetOverviewPageState();
}

class _AssetOverviewPageState extends ConsumerState<AssetOverviewPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(assetCharactersProvider.notifier).load();
      ref.read(assetLocationsProvider.notifier).load();
      ref.read(assetPropsProvider.notifier).load();
      ref.read(assetStylesProvider.notifier).load();
      ref.read(resourceListProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(assetOverviewProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ReadinessBar(data: data),
        const SizedBox(height: 20),
        _buildCategoryGrid(data),
        const SizedBox(height: 24),
        KeyIssuesList(issues: data.keyIssues),
      ],
    );
  }

  Widget _buildCategoryGrid(AssetOverviewData data) {
    final cards = [
      AssetCategoryCard(
        icon: AppIcons.person,
        iconColor: const Color(0xFF8B5CF6),
        label: '角色',
        confirmed: data.charConfirmed,
        total: data.charTotal,
        pending: data.charSkeleton,
        isLoading: data.isLoading,
        nextAction: data.charSkeleton > 0
            ? '${data.charSkeleton} 个骨架待补充'
            : null,
        onTap: () => context.go(Routes.assetsCharacters),
      ),
      AssetCategoryCard(
        icon: AppIcons.landscape,
        iconColor: const Color(0xFF3B82F6),
        label: '场景',
        confirmed: data.locConfirmed,
        total: data.locTotal,
        pending: data.locSkeleton,
        isLoading: data.isLoading,
        nextAction: data.locSkeleton > 0
            ? '${data.locSkeleton} 个骨架待补充'
            : null,
        onTap: () => context.go(Routes.assetsEnvironments),
      ),
      AssetCategoryCard(
        icon: AppIcons.category,
        iconColor: const Color(0xFFF97316),
        label: '道具',
        confirmed: data.propConfirmed,
        total: data.propTotal,
        isLoading: data.isLoading,
        onTap: () => context.go(Routes.assetsProps),
      ),
      AssetCategoryCard(
        icon: AppIcons.brush,
        iconColor: const Color(0xFFEC4899),
        label: '风格',
        confirmed: data.hasDefaultStyle ? 1 : 0,
        total: data.styleTotal > 0 ? data.styleTotal : 1,
        isLoading: data.isLoading,
        nextAction:
            !data.hasDefaultStyle ? '设定默认风格' : null,
        onTap: () => context.go(Routes.assetsResources),
      ),
      AssetCategoryCard(
        icon: AppIcons.gallery,
        iconColor: const Color(0xFF14B8A6),
        label: '素材库',
        confirmed: data.resourceTotal,
        total: data.resourceTotal,
        isLoading: data.isLoading,
        onTap: () => context.go(Routes.assetsResources),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 3
            : constraints.maxWidth > 500
                ? 2
                : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 2.6,
          children: cards,
        );
      },
    );
  }
}
