import 'package:flutter/material.dart';

import 'package:anime_ui/pub/models/character.dart';
import 'package:anime_ui/pub/models/location.dart';
import 'package:anime_ui/pub/models/prop.dart';
import 'package:anime_ui/pub/theme/app_icons.dart';

/// 待发布变更项
class PendingItem {
  final String name;
  final String status;
  final String statusLabel;

  const PendingItem({
    required this.name,
    required this.status,
    required this.statusLabel,
  });
}

/// 待发布变更卡片：展示尚未确认的角色、场景、道具
class PendingChangesCard extends StatelessWidget {
  final List<Character> pendingChars;
  final List<Location> pendingLocs;
  final List<Prop> pendingProps;

  const PendingChangesCard({
    super.key,
    required this.pendingChars,
    required this.pendingLocs,
    required this.pendingProps,
  });

  @override
  Widget build(BuildContext context) {
    final totalPending =
        pendingChars.length + pendingLocs.length + pendingProps.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.edit, size: 20, color: Colors.orange),
              const SizedBox(width: 8),
              const Text(
                '待发布变更',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$totalPending',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(
                '以下资产尚未确认，冻结时将自动确认',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (pendingChars.isNotEmpty) ...[
            _pendingSection(
              AppIcons.person,
              const Color(0xFF8B5CF6),
              '角色',
              pendingChars.map((c) => PendingItem(
                    name: c.name,
                    status: c.status,
                    statusLabel: c.status == 'skeleton' ? '骨架' : '待确认',
                  )),
            ),
          ],
          if (pendingLocs.isNotEmpty) ...[
            if (pendingChars.isNotEmpty)
              Divider(color: Colors.grey[800], height: 20),
            _pendingSection(
              AppIcons.landscape,
              const Color(0xFF3B82F6),
              '场景',
              pendingLocs.map((l) => PendingItem(
                    name: l.name,
                    status: l.status,
                    statusLabel: l.status == 'skeleton' ? '骨架' : '待确认',
                  )),
            ),
          ],
          if (pendingProps.isNotEmpty) ...[
            if (pendingChars.isNotEmpty || pendingLocs.isNotEmpty)
              Divider(color: Colors.grey[800], height: 20),
            _pendingSection(
              AppIcons.category,
              const Color(0xFFF97316),
              '道具',
              pendingProps.map((p) => PendingItem(
                    name: p.name,
                    status: p.status,
                    statusLabel: p.status == 'skeleton' ? '骨架' : '待确认',
                  )),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pendingSection(
    IconData icon,
    Color color,
    String label,
    Iterable<PendingItem> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text('$label (${items.length})',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: items.map((item) => _pendingChip(item, color)).toList(),
        ),
      ],
    );
  }

  Widget _pendingChip(PendingItem item, Color color) {
    final isSkeleton = item.status == 'skeleton';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.name.isEmpty ? '未命名' : item.name,
            style: TextStyle(fontSize: 12, color: Colors.grey[300]),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: isSkeleton
                  ? Colors.red.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              item.statusLabel,
              style: TextStyle(
                fontSize: 10,
                color: isSkeleton ? Colors.red[300] : Colors.orange[300],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
