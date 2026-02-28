import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/services/api.dart';
import 'package:anime_ui/module/assets/locations/providers/selection.dart';

/// 场景列表面板
class LocationListPanel extends ConsumerWidget {
  const LocationListPanel({super.key, required this.locations});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedLocIdProvider);
    final confirmed = locations.where((l) => l.isConfirmed).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Row(
            children: [
              Text(
                '${locations.length} 个场景',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(width: 6),
              const Icon(AppIcons.check, size: 12, color: Color(0xFF22C55E)),
              Text(
                ' $confirmed',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final loc = locations[index];
              final isSelected = loc.id == selectedId;
              return _LocationListItem(
                location: loc,
                isSelected: isSelected,
                onTap: () =>
                    ref.read(selectedLocIdProvider.notifier).set(loc.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LocationListItem extends StatelessWidget {
  const _LocationListItem({
    required this.location,
    required this.isSelected,
    required this.onTap,
  });

  final Location location;
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
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
        color: location.hasImage
            ? Colors.transparent
            : const Color(0xFF3B82F6).withValues(alpha: 0.12),
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
          : const Icon(AppIcons.landscape,
              size: 18, color: Color(0xFF3B82F6)),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                location.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (location.interiorExterior.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  location.interiorExterior,
                  style: TextStyle(fontSize: 9, color: Colors.grey[500]),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            _statusChip(location.status),
            if (location.time.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                location.time,
                style: TextStyle(fontSize: 9, color: Colors.grey[600]),
              ),
            ],
            if (location.hasImage) ...[
              const SizedBox(width: 6),
              Icon(AppIcons.image, size: 10, color: Colors.grey[600]),
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
