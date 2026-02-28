import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:anime_ui/pub/theme/app_icons.dart';
import 'package:anime_ui/pub/theme/colors.dart';
import 'package:anime_ui/pub/providers/lock.dart';
import 'package:anime_ui/pub/providers/project.dart';

/// 剧本锁定/解锁页
class StoryConfirmPage extends ConsumerStatefulWidget {
  const StoryConfirmPage({super.key});

  @override
  ConsumerState<StoryConfirmPage> createState() => _StoryConfirmPageState();
}

class _StoryConfirmPageState extends ConsumerState<StoryConfirmPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lockProvider.notifier).load();
    });
  }

  Future<void> _toggleLock() async {
    final lock = ref.read(lockProvider);
    final isLocked = lock.storyLocked;
    final action = isLocked ? '解锁' : '锁定';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('确认$action剧本',
            style: const TextStyle(color: Colors.white)),
        content: Text(
          isLocked
              ? '解锁后可以重新编辑和导入剧本。确定解锁？'
              : '锁定后将无法编辑和重新导入剧本，但仍可预览。确定锁定？',
          style: TextStyle(color: Colors.grey[400], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消', style: TextStyle(color: Colors.grey[400])),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor:
                  isLocked ? AppColors.primary : const Color(0xFFEF4444),
            ),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    final success = isLocked
        ? await ref.read(lockProvider.notifier).unlockPhase('story')
        : await ref.read(lockProvider.notifier).lockPhase('story');
    if (mounted) {
      setState(() => _loading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('剧本已$action')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$action失败，请重试')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lock = ref.watch(lockProvider);
    final project = ref.watch(currentProjectProvider).value;
    final isLocked = lock.storyLocked;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isLocked
                    ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked ? AppIcons.check : AppIcons.lock,
                size: 36,
                color: isLocked
                    ? const Color(0xFF22C55E)
                    : AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isLocked ? '剧本已锁定' : '锁定剧本',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              isLocked
                  ? '锁定于 ${_formatTime(lock.storyLockedAt)}'
                  : '锁定后将无法编辑和重新导入，但可预览',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            if (project != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.grey[800]!.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _infoRow('项目', project.name),
                    const SizedBox(height: 8),
                    _infoRow('状态',
                        isLocked ? '已锁定' : '未锁定',
                        valueColor: isLocked
                            ? const Color(0xFF22C55E)
                            : Colors.grey[500]),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 44,
              child: FilledButton.icon(
                onPressed: _loading ? null : _toggleLock,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Icon(isLocked ? AppIcons.lockUnlocked : AppIcons.lock,
                        size: 18),
                label: Text(isLocked ? '解锁剧本' : '锁定剧本',
                    style: const TextStyle(fontSize: 15)),
                style: FilledButton.styleFrom(
                  backgroundColor: isLocked
                      ? AppColors.primary
                      : const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(color: Colors.grey[500], fontSize: 13)),
        const Spacer(),
        Text(value,
            style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '--';
    return '${dt.year}/${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
