import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/module/assets/characters/providers/characters_provider.dart';

/// AI 资产提取对话框
class AssetExtractDialog extends ConsumerWidget {
  const AssetExtractDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetExtractProvider);

    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: const Text('AI 资产提取', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (state.error != null && state.result == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(state.error!,
                    style: TextStyle(color: Colors.red[400], fontSize: 13)),
              ),
            if (state.isLoading && state.result == null)
              _buildLoadingState()
            else if (state.result != null)
              _buildResultState(state, ref)
            else
              _buildIdleState(),
          ],
        ),
      ),
      actions: _buildActions(context, state, ref),
    );
  }

  Widget _buildIdleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '从剧本中自动提取角色、场景、道具设定。',
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
        const SizedBox(height: 12),
        _featureRow(AppIcons.bolt, '结构化预提取', '从已解析剧本直接提取角色名、场景列表'),
        const SizedBox(height: 6),
        _featureRow(AppIcons.sync, '并行 AI 补全', '角色/场景/道具分 3 路同时生成，速度提升 3x'),
        const SizedBox(height: 6),
        _featureRow(AppIcons.mergeType, '智能合并', '自动与已有数据去重，增量更新'),
        const SizedBox(height: 16),
        Text(
          '提取完成后可逐一审核、编辑，确认后写入项目数据。',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _featureRow(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$title  ',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: desc,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _categoryProgress('角色设定', 'pending', null),
        const SizedBox(height: 8),
        _categoryProgress('场景设定', 'pending', null),
        const SizedBox(height: 8),
        _categoryProgress('道具识别', 'pending', null),
        const SizedBox(height: 16),
        Text('3 个 AI 任务并行处理中...', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 8),
        const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildResultState(ExtractState state, WidgetRef ref) {
    final result = state.result!;
    final status = result.status;

    return SizedBox(
      height: 340,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status != null) ...[
              _categoryProgress('角色设定', status.characters, status.charError,
                  count: result.characters.length),
              const SizedBox(height: 6),
              _categoryProgress('场景设定', status.locations, status.locError,
                  count: result.locations.length),
              const SizedBox(height: 6),
              _categoryProgress('道具识别', status.props, status.propError,
                  count: result.props.length),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
            ],

            if (result.characters.isNotEmpty) ...[
              _sectionTitle('角色', result.characters.length),
              const SizedBox(height: 4),
              ...result.characters.map((c) => _itemTile(
                    icon: AppIcons.person,
                    title: c.name,
                    subtitle: c.appearance.isNotEmpty ? c.appearance : c.personality,
                  )),
              const SizedBox(height: 12),
            ],

            if (result.locations.isNotEmpty) ...[
              _sectionTitle('场景', result.locations.length),
              const SizedBox(height: 4),
              ...result.locations.map((l) => _itemTile(
                    icon: AppIcons.landscape,
                    title: '${l.name}（${l.interiorExterior}/${l.time}）',
                    subtitle: l.atmosphere,
                  )),
              const SizedBox(height: 12),
            ],

            if (result.props.isNotEmpty) ...[
              _sectionTitle('道具', result.props.length),
              const SizedBox(height: 4),
              ...result.props.map((p) => _itemTile(
                    icon: AppIcons.category,
                    title: p.name,
                    subtitle: p.appearance,
                  )),
            ],

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(state.error!,
                    style: TextStyle(color: Colors.red[400], fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _categoryProgress(String label, String status, String? error, {int count = 0}) {
    IconData icon;
    Color color;
    String text;
    Widget? trailing;

    switch (status) {
      case 'done':
        icon = AppIcons.check;
        color = Colors.green[400]!;
        text = '完成（$count 项）';
      case 'error':
        icon = AppIcons.errorOutline;
        color = Colors.red[400]!;
        text = error?.isNotEmpty == true ? '失败: $error' : '失败';
      default: // pending
        icon = AppIcons.hourglassEmpty;
        color = Colors.orange[400]!;
        text = '处理中...';
        trailing = const SizedBox(
          width: 14, height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
        const Spacer(),
        if (trailing != null) ...[trailing, const SizedBox(width: 6)],
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('$count', style: TextStyle(fontSize: 11, color: AppColors.primary)),
        ),
      ],
    );
  }

  Widget _itemTile({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.white)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ExtractState state, WidgetRef ref) {
    final hasResult = state.result != null;
    final status = state.result?.status;
    final hasErrors = status != null &&
        (status.characters == 'error' ||
            status.locations == 'error' ||
            status.props == 'error');

    return [
      TextButton(
        onPressed: state.isLoading
            ? null
            : () {
                ref.read(assetExtractProvider.notifier).reset();
                Navigator.of(context).pop();
              },
        child: Text('取消', style: TextStyle(color: Colors.grey[400])),
      ),
      if (hasResult && hasErrors)
        TextButton(
          onPressed: state.isLoading
              ? null
              : () => ref.read(assetExtractProvider.notifier).extract(),
          child: Text('重新提取', style: TextStyle(color: Colors.orange[400])),
        ),
      if (hasResult)
        FilledButton(
          onPressed: state.isLoading
              ? null
              : () async {
                  await ref.read(assetExtractProvider.notifier).confirmAndApply();
                  if (context.mounted) Navigator.of(context).pop();
                },
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('确认导入'),
        )
      else
        FilledButton(
          onPressed: state.isLoading
              ? null
              : () => ref.read(assetExtractProvider.notifier).extract(),
          style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
          child: const Text('开始提取'),
        ),
    ];
  }
}
