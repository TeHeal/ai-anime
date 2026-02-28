import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/models/asset_version.dart';
import 'package:anime_ui/pub/providers/lock.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';

import 'characters/providers/characters.dart';
import 'locations/providers/locations.dart';
import 'pending_changes_card.dart';
import 'props/providers/props.dart';
import 'versions_provider.dart';

/// 资产版本管理页：冻结、解冻、版本历史、待发布变更
class AssetsVersionsPage extends ConsumerStatefulWidget {
  const AssetsVersionsPage({super.key});

  @override
  ConsumerState<AssetsVersionsPage> createState() => _AssetsVersionsPageState();
}

class _AssetsVersionsPageState extends ConsumerState<AssetsVersionsPage> {
  bool _freezing = false;
  bool _showUnfreezeWarning = false;
  List<Map<String, dynamic>> _impactItems = [];
  bool _loadingImpact = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(assetVersionsProvider.notifier).load();
      ref.read(assetCharactersProvider.notifier).load();
      ref.read(assetLocationsProvider.notifier).load();
      ref.read(assetPropsProvider.notifier).load();
    });
  }

  Future<void> _freezeAssets() async {
    if (_freezing) return;
    setState(() => _freezing = true);
    try {
      final chars = ref.read(assetCharactersProvider).value ?? [];
      final locs = ref.read(assetLocationsProvider).value ?? [];

      // 冻结前自动确认未确认的角色
      final draftIds = chars
          .where((c) => c.status != 'confirmed' && c.id != null)
          .map((c) => c.id!)
          .toList();
      if (draftIds.isNotEmpty) {
        await ref
            .read(assetCharactersProvider.notifier)
            .batchConfirm(draftIds);
      }
      for (final loc in locs) {
        if (loc.status != 'confirmed' && loc.id != null) {
          await ref.read(assetLocationsProvider.notifier).confirm(loc.id!);
        }
      }

      final version = await ref.read(assetVersionsProvider.notifier).freeze();
      if (!mounted) return;

      if (version != null) {
        await ref.read(lockProvider.notifier).lockPhase('assets');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('资产已冻结 — 版本 v${version.version}'),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        ref.read(assetVersionsProvider.notifier).load();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('冻结失败，请重试'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _freezing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chars = ref.watch(assetCharactersProvider).value ?? [];
    final locs = ref.watch(assetLocationsProvider).value ?? [];
    final props = ref.watch(assetPropsProvider).value ?? [];
    final lock = ref.watch(lockProvider);
    final isLocked = lock.assetsLocked;
    final versions = ref.watch(assetVersionsProvider).value ?? [];

    final pendingChars = chars.where((c) => !c.isConfirmed).toList();
    final pendingLocs = locs.where((l) => l.status != 'confirmed').toList();
    final pendingProps = props.where((p) => !p.isConfirmed).toList();
    final hasPendingChanges =
        pendingChars.isNotEmpty || pendingLocs.isNotEmpty || pendingProps.isNotEmpty;

    final confirmedChars = chars.where((c) => c.isConfirmed).length;
    final confirmedLocs = locs.where((l) => l.status == 'confirmed').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusHeader(isLocked, lock.assetsLockedAt, versions),
              const SizedBox(height: 24),
              if (hasPendingChanges) ...[
                PendingChangesCard(
                  pendingChars: pendingChars,
                  pendingLocs: pendingLocs,
                  pendingProps: pendingProps,
                ),
                const SizedBox(height: 24),
              ],
              _buildFreezeCheck(
                chars.length,
                confirmedChars,
                locs.length,
                confirmedLocs,
                props.length,
                isLocked,
              ),
              if (_showUnfreezeWarning) ...[
                const SizedBox(height: 16),
                _buildUnfreezeWarning(),
              ],
              const SizedBox(height: 24),
              _buildActions(isLocked, chars.isEmpty && locs.isEmpty),
              if (versions.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildVersionHistory(versions),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(
      bool isLocked, DateTime? lockedAt, List<AssetVersion> versions) {
    final latestVersion =
        versions.isNotEmpty ? 'v${versions.first.version}' : '—';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isLocked
            ? const Color(0xFF22C55E).withValues(alpha: 0.08)
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLocked
              ? const Color(0xFF22C55E).withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLocked
                  ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLocked ? AppIcons.lock : AppIcons.history,
              size: 24,
              color: isLocked ? const Color(0xFF22C55E) : AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isLocked ? '已冻结' : '未冻结',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isLocked
                            ? const Color(0xFF22C55E)
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        latestVersion,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isLocked
                      ? '冻结于 ${_formatTime(lockedAt)}，资产已锁定为生产基线'
                      : '确认资产后冻结，创建生产基线版本',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreezeCheck(
    int charTotal,
    int charConfirmed,
    int locTotal,
    int locConfirmed,
    int propCount,
    bool isLocked,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.checkOutline, size: 18, color: Colors.grey[400]),
              const SizedBox(width: 8),
              Text(
                isLocked ? '冻结时资产状态' : '冻结前检查',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _checkRow(
            AppIcons.person,
            '角色',
            '$charConfirmed / $charTotal 已确认',
            charTotal > 0 && charConfirmed == charTotal,
            charTotal > 0 && charConfirmed < charTotal
                ? '${charTotal - charConfirmed} 个待确认'
                : null,
          ),
          Divider(color: Colors.grey[800], height: 20),
          _checkRow(
            AppIcons.landscape,
            '场景',
            '$locConfirmed / $locTotal 已确认',
            locTotal > 0 && locConfirmed == locTotal,
            locTotal > 0 && locConfirmed < locTotal
                ? '${locTotal - locConfirmed} 个待确认'
                : null,
          ),
          Divider(color: Colors.grey[800], height: 20),
          _checkRow(
            AppIcons.category,
            '道具',
            '$propCount 个',
            propCount > 0,
            null,
          ),
          Divider(color: Colors.grey[800], height: 20),
          _checkRow(
            AppIcons.brush,
            '风格',
            '已设定',
            true,
            null,
          ),
        ],
      ),
    );
  }

  Widget _checkRow(
    IconData icon,
    String label,
    String value,
    bool ok,
    String? warning,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            ok ? AppIcons.check : AppIcons.warning,
            size: 16,
            color: ok ? const Color(0xFF22C55E) : Colors.orange,
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 16, color: Colors.grey[500]),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(fontSize: 14, color: Colors.grey[400])),
          const Spacer(),
          if (warning != null) ...[
            Text(warning,
                style: TextStyle(fontSize: 12, color: Colors.orange[300])),
            const SizedBox(width: 10),
          ],
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _loadImpact() async {
    setState(() => _loadingImpact = true);
    try {
      final data = await ref.read(assetVersionsProvider.notifier).impact();
      final impacts =
          (data['impacts'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      if (mounted) setState(() => _impactItems = impacts);
    } finally {
      if (mounted) setState(() => _loadingImpact = false);
    }
  }

  Widget _buildUnfreezeWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.warning, size: 18, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                '解冻影响分析',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '解冻将允许修改当前版本基线资产，以下下游内容可能受影响：',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          if (_loadingImpact)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_impactItems.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Text('暂无下游内容引用当前版本',
                  style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            )
          else
            ..._impactItems.map((item) => _impactRow(
                  item['module'] as String? ?? '',
                  item['detail'] as String? ?? '',
                )),
          const SizedBox(height: 12),
          Text(
            '受影响内容不会被自动删除，但可能与修改后的资产不一致。修改完成后建议重新冻结。',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() {
                  _showUnfreezeWarning = false;
                  _impactItems = [];
                }),
                child: Text('取消', style: TextStyle(color: Colors.grey[400])),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  await ref.read(assetVersionsProvider.notifier).unfreeze();
                  await ref.read(lockProvider.notifier).unlockPhase('assets');
                  if (mounted) {
                    setState(() {
                      _showUnfreezeWarning = false;
                      _impactItems = [];
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('已解冻，资产可编辑'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('确认解冻'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactRow(String module, String desc) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(color: Colors.orange)),
          Text(module,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(desc,
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isLocked, bool isEmpty) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: (isEmpty || _freezing)
                ? null
                : isLocked
                    ? () {
                        setState(() => _showUnfreezeWarning = true);
                        _loadImpact();
                      }
                    : _freezeAssets,
            icon: _freezing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(
                    isLocked ? AppIcons.lockUnlocked : AppIcons.lock,
                    size: 18,
                  ),
            label: Text(
              _freezing
                  ? '冻结中...'
                  : isLocked
                      ? '解冻当前版本'
                      : '创建冻结版本',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: isLocked ? Colors.orange : AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionHistory(List<AssetVersion> versions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(AppIcons.history, size: 18, color: Colors.grey[500]),
            const SizedBox(width: 8),
            const Text('版本历史',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        ...versions.map((v) => _versionTile(v)),
      ],
    );
  }

  Widget _versionTile(AssetVersion v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'v${v.version}',
              style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  v.actionLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
                if (v.note.isNotEmpty)
                  Text(v.note,
                      style:
                          TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          if (v.createdAt != null)
            Text(
              _formatTime(v.createdAt),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    return '${t.month}/${t.day} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
