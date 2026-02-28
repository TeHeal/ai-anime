import 'package:flutter/material.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'package:anime_ui/module/assets/shared/asset_detail_shell.dart';

/// 场景详情面板
class LocationDetailPanel extends StatelessWidget {
  const LocationDetailPanel({
    super.key,
    required this.location,
    this.onConfirm,
    required this.onDelete,
    this.onGenerateImage,
    required this.onEdit,
  });

  final Location location;
  final VoidCallback? onConfirm;
  final VoidCallback onDelete;
  final VoidCallback? onGenerateImage;
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
        image: location.hasImage
            ? DecorationImage(
                image: NetworkImage(resolveFileUrl(location.imageUrl)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: location.hasImage
          ? null
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(AppIcons.landscape, size: 48, color: Colors.grey[600]),
                  const SizedBox(height: 8),
                  Text(
                    '暂无参考图',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  if (onGenerateImage != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: onGenerateImage,
                      icon: const Icon(AppIcons.autoAwesome, size: 14),
                      label: const Text('AI 生成'),
                    ),
                  ],
                ],
              ),
            ),
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
                location.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              _statusChip(location.status),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(AppIcons.edit, size: 16),
                tooltip: '编辑',
              ),
            ],
          ),
          if (location.time.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow('时间', location.time),
          ],
          if (location.interiorExterior.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('内外景', location.interiorExterior),
          ],
          if (location.atmosphere.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('氛围', location.atmosphere),
          ],
          if (location.colorTone.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('色调', location.colorTone),
          ],
          if (location.styleNote.isNotEmpty) ...[
            const SizedBox(height: 4),
            _infoRow('风格备注', location.styleNote),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            '$label：',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
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
        if (onConfirm != null && !location.isConfirmed)
          FilledButton.icon(
            onPressed: onConfirm,
            icon: const Icon(AppIcons.check, size: 14),
            label: const Text('确认'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
          ),
      ],
    );
  }
}
