import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'package:anime_ui/module/assets/shared/asset_detail_shell.dart';

/// 道具详情面板
class PropDetailPanel extends StatelessWidget {
  const PropDetailPanel({
    super.key,
    required this.prop,
    this.onConfirm,
    required this.onDelete,
    required this.onEdit,
  });

  final Prop prop;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AssetDetailShell(
      bottomBar: _buildBottomBar(),
      children: [
        _buildImageCard(),
        const SizedBox(height: 16),
        _buildInfoCard(),
      ],
    );
  }

  Widget _buildImageCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        image: prop.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(resolveFileUrl(prop.imageUrl)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: prop.imageUrl.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.category, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text('暂无参考图', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                prop.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 8),
              _statusChip(prop.status),
              if (prop.isKeyProp) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('关键', style: TextStyle(color: Colors.orange[300], fontSize: 11)),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(AppIcons.edit, size: 16),
                tooltip: '编辑',
              ),
            ],
          ),
          if (prop.appearance.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('外观描述', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 4),
            Text(prop.appearance, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final (String label, Color color) = switch (status) {
      'confirmed' => ('已确认', const Color(0xFF22C55E)),
      'skeleton' => ('骨架', Colors.grey),
      _ => ('待确认', AppColors.newTag),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11)),
    );
  }

  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(AppIcons.delete, size: 14),
          label: const Text('删除'),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
        ),
        const SizedBox(width: 8),
        if (onConfirm != null && !prop.isConfirmed)
          FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(AppIcons.check, size: 14),
            label: const Text('确认'),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
          ),
      ],
    );
  }
}
