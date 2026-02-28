import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'package:anime_ui/module/assets/props/providers/props_providers.dart';

/// 道具列表面板
class PropListPanel extends ConsumerWidget {
  const PropListPanel({super.key, required this.props});

  final List<Prop> props;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedPropIdProvider);
    final confirmed = props.where((p) => p.isConfirmed).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                '${props.length} 个道具',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(width: 6),
              const Icon(AppIcons.check, size: 12, color: Color(0xFF22C55E)),
              Text(' $confirmed', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: props.length,
            itemBuilder: (context, index) {
              final prop = props[index];
              final isSelected = prop.id == selectedId;
              return _PropListItem(
                prop: prop,
                isSelected: isSelected,
                onTap: () => ref.read(selectedPropIdProvider.notifier).set(prop.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PropListItem extends StatelessWidget {
  const _PropListItem({
    required this.prop,
    required this.isSelected,
    required this.onTap,
  });

  final Prop prop;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 4),
        child: IntrinsicHeight(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 3,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      _buildThumb(),
                      const SizedBox(width: 10),
                      Expanded(child: _buildInfo()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumb() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: prop.imageUrl.isNotEmpty
            ? Colors.transparent
            : const Color(0xFFF97316).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        image: prop.imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(resolveFileUrl(prop.imageUrl)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: prop.imageUrl.isEmpty
          ? const Icon(AppIcons.category, size: 18, color: Color(0xFFF97316))
          : null,
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prop.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            _statusChip(prop.status),
            if (prop.isKeyProp) ...[
              const SizedBox(width: 6),
              Icon(AppIcons.bolt, size: 10, color: Colors.orange[300]),
            ],
          ],
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
    return Text(label, style: TextStyle(color: color, fontSize: 10));
  }
}
