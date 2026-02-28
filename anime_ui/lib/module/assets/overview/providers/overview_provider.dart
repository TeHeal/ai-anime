import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/module/assets/characters/providers/characters_provider.dart';
import 'package:anime_ui/module/assets/locations/providers/locations_provider.dart';
import 'package:anime_ui/module/assets/props/providers/props_provider.dart';
import 'package:anime_ui/module/assets/resources/providers/resource_state.dart';
import 'package:anime_ui/module/assets/overview/providers/styles_provider.dart';

/// 资产总览数据
class AssetOverviewData {
  final int charTotal;
  final int charConfirmed;
  final int charSkeleton;
  final int charNoImage;
  final int charNoVoice;

  final int locTotal;
  final int locConfirmed;
  final int locSkeleton;

  final int propTotal;
  final int propConfirmed;

  final int styleTotal;
  final bool hasDefaultStyle;

  final int voiceConfigured;
  final int voiceNeeded;

  final int resourceTotal;

  final int totalAssets;
  final int totalConfirmed;
  final int readinessPct;
  final bool isLoading;

  final List<KeyIssue> keyIssues;

  const AssetOverviewData({
    this.charTotal = 0,
    this.charConfirmed = 0,
    this.charSkeleton = 0,
    this.charNoImage = 0,
    this.charNoVoice = 0,
    this.locTotal = 0,
    this.locConfirmed = 0,
    this.locSkeleton = 0,
    this.propTotal = 0,
    this.propConfirmed = 0,
    this.styleTotal = 0,
    this.hasDefaultStyle = false,
    this.voiceConfigured = 0,
    this.voiceNeeded = 0,
    this.resourceTotal = 0,
    this.totalAssets = 0,
    this.totalConfirmed = 0,
    this.readinessPct = 0,
    this.isLoading = true,
    this.keyIssues = const [],
  });
}

/// 关键问题项
class KeyIssue {
  final String icon;
  final String text;
  final String route;
  final int count;
  final KeyIssueSeverity severity;

  const KeyIssue({
    required this.icon,
    required this.text,
    required this.route,
    this.count = 0,
    this.severity = KeyIssueSeverity.warning,
  });
}

enum KeyIssueSeverity { error, warning, info }

final assetOverviewProvider = Provider<AssetOverviewData>((ref) {
  final charsAsync = ref.watch(assetCharactersProvider);
  final locsAsync = ref.watch(assetLocationsProvider);
  final propsAsync = ref.watch(assetPropsProvider);
  final stylesAsync = ref.watch(assetStylesProvider);
  final resourcesAsync = ref.watch(resourceListProvider);

  final isLoading = charsAsync.isLoading ||
      locsAsync.isLoading ||
      propsAsync.isLoading ||
      stylesAsync.isLoading;

  final chars = charsAsync.value ?? [];
  final locs = locsAsync.value ?? [];
  final props = propsAsync.value ?? [];
  final styles = stylesAsync.value ?? [];
  final resources = resourcesAsync.value ?? [];

  final charConfirmed = chars.where((c) => c.isConfirmed).length;
  final charSkeleton = chars.where((c) => c.status == 'skeleton').length;
  final charNoImage =
      chars.where((c) => !c.hasImage && c.referenceImages.isEmpty).length;
  final charNoVoice =
      chars.where((c) => c.voiceName.isEmpty && c.roleType != 'narrator').length;

  final locConfirmed = locs.where((l) => l.status == 'confirmed').length;
  final locSkeleton = locs.where((l) => l.status == 'skeleton').length;

  final propConfirmed = props.where((p) => p.isConfirmed).length;

  final voiceNeeded =
      chars.where((c) => c.roleType != 'narrator').length;
  final voiceConfigured =
      chars.where((c) => c.voiceName.isNotEmpty && c.roleType != 'narrator').length;

  final totalAssets = chars.length + locs.length + props.length;
  final totalConfirmed = charConfirmed + locConfirmed + propConfirmed;
  final readinessPct =
      totalAssets > 0 ? (totalConfirmed * 100 / totalAssets).round() : 0;

  final issues = <KeyIssue>[];

  if (charSkeleton > 0) {
    issues.add(KeyIssue(
      icon: 'person',
      text: '$charSkeleton 个角色为骨架状态，需补充信息',
      route: '/assets/characters',
      count: charSkeleton,
      severity: KeyIssueSeverity.error,
    ));
  }
  if (charNoImage > 0) {
    issues.add(KeyIssue(
      icon: 'person',
      text: '$charNoImage 个角色缺少形象图',
      route: '/assets/characters',
      count: charNoImage,
      severity: KeyIssueSeverity.error,
    ));
  }
  if (charNoVoice > 0) {
    issues.add(KeyIssue(
      icon: 'mic',
      text: '$charNoVoice 个角色缺少声音设定',
      route: '/assets/characters',
      count: charNoVoice,
      severity: KeyIssueSeverity.warning,
    ));
  }
  if (locSkeleton > 0) {
    issues.add(KeyIssue(
      icon: 'landscape',
      text: '$locSkeleton 个场景为骨架，需补充信息',
      route: '/assets/environments',
      count: locSkeleton,
      severity: KeyIssueSeverity.error,
    ));
  }
  if (!styles.any((s) => s.isProjectDefault) && styles.isNotEmpty) {
    issues.add(KeyIssue(
      icon: 'style',
      text: '默认风格未设定',
      route: '/assets/resources',
      count: 1,
      severity: KeyIssueSeverity.warning,
    ));
  }

  return AssetOverviewData(
    charTotal: chars.length,
    charConfirmed: charConfirmed,
    charSkeleton: charSkeleton,
    charNoImage: charNoImage,
    charNoVoice: charNoVoice,
    locTotal: locs.length,
    locConfirmed: locConfirmed,
    locSkeleton: locSkeleton,
    propTotal: props.length,
    propConfirmed: propConfirmed,
    styleTotal: styles.length,
    hasDefaultStyle: styles.any((s) => s.isProjectDefault),
    voiceConfigured: voiceConfigured,
    voiceNeeded: voiceNeeded,
    resourceTotal: resources.length,
    totalAssets: totalAssets,
    totalConfirmed: totalConfirmed,
    readinessPct: readinessPct,
    isLoading: isLoading,
    keyIssues: issues,
  );
});
