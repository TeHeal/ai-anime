import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'package:anime_ui/module/assets/shared/asset_status_chip.dart';
import 'package:anime_ui/module/assets/characters/providers/characters_provider.dart';

/// 角色列表页：展示项目角色、支持筛选与新增
class AssetsCharactersPage extends ConsumerStatefulWidget {
  const AssetsCharactersPage({super.key});

  @override
  ConsumerState<AssetsCharactersPage> createState() =>
      _AssetsCharactersPageState();
}

class _AssetsCharactersPageState extends ConsumerState<AssetsCharactersPage> {
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(assetCharactersProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final asyncChars = ref.watch(assetCharactersProvider);
    final toolbar = _buildToolbar();

    return asyncChars.when(
      loading: () => Column(
        children: [
          toolbar,
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
      error: (e, _) => Column(
        children: [
          toolbar,
          Expanded(
            child: Center(
              child: Text(
                '加载失败: $e',
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ),
        ],
      ),
      data: (allChars) {
        var chars = allChars.toList();
        if (_statusFilter != null) {
          chars = chars.where((c) => c.status == _statusFilter).toList();
        }
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          chars = chars.where((c) => c.name.toLowerCase().contains(q)).toList();
        }
        if (chars.isEmpty && allChars.isEmpty) return _emptyState(toolbar);

        return Column(
          children: [toolbar, Expanded(child: _buildGrid(chars))],
        );
      },
    );
  }

  /// 顶部工具栏：搜索、筛选、新增按钮
  Widget _buildToolbar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 220,
            height: 34,
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: InputDecoration(
                hintText: '搜索角色...',
                hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
                prefixIcon: Icon(
                  AppIcons.search,
                  size: 16,
                  color: Colors.grey[600],
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterChip('全部', null),
          const SizedBox(width: 6),
          _buildFilterChip('草稿', 'draft'),
          const SizedBox(width: 6),
          _buildFilterChip('已确认', 'confirmed'),
          const Spacer(),
          FilledButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(AppIcons.add, size: 16),
            label: const Text('新增角色'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value) {
    final active = _statusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? AppColors.primary : Colors.grey[400],
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// 角色网格卡片
  Widget _buildGrid(List<Character> chars) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: chars.length,
      itemBuilder: (context, i) => _CharacterCard(
        character: chars[i],
        onDelete: () => _confirmDelete(chars[i]),
        onConfirm: chars[i].isConfirmed
            ? null
            : () => ref
                .read(assetCharactersProvider.notifier)
                .confirm(chars[i].id!),
      ),
    );
  }

  Widget _emptyState(Widget toolbar) {
    return Column(
      children: [
        toolbar,
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.person, size: 64, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  '暂无角色',
                  style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Text(
                  '点击 AI 提取资产，或手动添加角色',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('手动添加'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 新增角色对话框
  void _showAddDialog() {
    final nameCtrl = TextEditingController();
    final appearCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('新增角色', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '角色名称',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: appearCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: '外貌描述',
                  labelStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              ref.read(assetCharactersProvider.notifier).add(
                    Character(name: nameCtrl.text.trim(),
                        appearance: appearCtrl.text.trim()),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Character c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: const Text('确认删除', style: TextStyle(color: Colors.white)),
        content: Text(
          '确定要删除角色「${c.name}」吗？',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(assetCharactersProvider.notifier).remove(c.id!);
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

/// 角色卡片：头像、名称、状态、操作
class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    this.onDelete,
    this.onConfirm,
  });

  final Character character;
  final VoidCallback? onDelete;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 角色头像区域
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: character.hasImage
                  ? Image.network(
                      resolveFileUrl(character.imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderAvatar(),
                    )
                  : _placeholderAvatar(),
            ),
          ),
          // 角色信息区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AssetStatusChip.fromStatus(character.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (character.importanceLabel.isNotEmpty ||
                      character.gender.isNotEmpty)
                    Text(
                      [character.gender, character.importanceLabel]
                          .where((s) => s.isNotEmpty)
                          .join(' · '),
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onConfirm != null)
                        _MiniIconBtn(
                          icon: AppIcons.check,
                          color: const Color(0xFF22C55E),
                          tooltip: '确认',
                          onTap: onConfirm!,
                        ),
                      if (onDelete != null) ...[
                        const SizedBox(width: 4),
                        _MiniIconBtn(
                          icon: AppIcons.delete,
                          color: AppColors.error,
                          tooltip: '删除',
                          onTap: onDelete!,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderAvatar() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(AppIcons.person, size: 40, color: Colors.grey[700]),
      ),
    );
  }
}

/// 小型图标按钮
class _MiniIconBtn extends StatelessWidget {
  const _MiniIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
