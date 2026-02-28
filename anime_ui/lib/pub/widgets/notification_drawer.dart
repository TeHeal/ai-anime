import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const/routes.dart';
import '../theme/app_icons.dart';
import '../theme/colors.dart';
import '../providers/notification_provider.dart';

/// 通知抽屉：从右侧滑出，显示站内通知列表（README 2.6）
class NotificationDrawer extends ConsumerWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 380,
      backgroundColor: AppColors.surfaceContainerHigh,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '站内通知',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[200],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(AppIcons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextButton(
                onPressed: () async {
                  try {
                    await ref
                        .read(notificationServiceProvider)
                        .markAllAsRead();
                    ref.invalidate(unreadNotificationCountProvider);
                    ref.invalidate(notificationListProvider);
                    if (context.mounted) Navigator.of(context).pop();
                  } catch (e, st) {
                    debugPrint('全部已读失败: $e\n$st');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('全部已读失败，请稍后重试')),
                      );
                    }
                  }
                },
                child: Text(
                  '全部已读',
                  style: TextStyle(fontSize: 13, color: AppColors.primary),
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _NotificationList(),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(AppIcons.list, size: 20, color: Colors.grey[500]),
              title: Text(
                '任务中心',
                style: TextStyle(fontSize: 14, color: Colors.grey[400]),
              ),
              onTap: () {
                context.go(Routes.tasks);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationList extends ConsumerWidget {
  const _NotificationList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(notificationListProvider);

    return listAsync.when(
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                '暂无通知',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final n = list[i];
            return ListTile(
              title: Text(
                n.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.w500,
                  color: n.isRead ? Colors.grey[400] : Colors.grey[200],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: n.body.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        n.body,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : null,
              onTap: () async {
                if (!n.isRead) {
                  try {
                    await ref
                        .read(notificationServiceProvider)
                        .markAsRead(n.id);
                    ref.invalidate(unreadNotificationCountProvider);
                    ref.invalidate(notificationListProvider);
                  } catch (e, st) {
                    debugPrint('标记已读失败: $e\n$st');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('标记已读失败，请稍后重试')),
                      );
                    }
                  }
                }
                if (n.linkUrl.isNotEmpty && context.mounted) {
                  context.go(n.linkUrl);
                  Navigator.of(context).pop();
                }
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (e, st) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Text(
            '加载失败',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ),
      ),
    );
  }
}
