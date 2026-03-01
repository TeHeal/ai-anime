import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../const/routes.dart';
import '../theme/app_icons.dart';
import '../providers/notification_provider.dart';
import 'package:anime_ui/pub/theme/design_tokens.dart';

/// 通知抽屉：从右侧滑出，显示站内通知列表（README 2.6）
class NotificationDrawer extends ConsumerWidget {
  const NotificationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 380.w,
      backgroundColor: AppColors.surfaceContainerHigh,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.mid.w,
                Spacing.mid.h,
                Spacing.mid.w,
                Spacing.md.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '站内通知',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.onSurface.withValues(alpha: 0.9),
                    ),
                  ),
                  IconButton(
                    icon: Icon(AppIcons.close, size: 20.r),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: '关闭',
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Spacing.mid.w),
              child: TextButton(
                onPressed: () async {
                  try {
                    await ref.read(notificationServiceProvider).markAllAsRead();
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
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Divider(height: 1.h),
            const Expanded(child: _NotificationList()),
            Divider(height: 1.h),
            ListTile(
              leading: Icon(
                AppIcons.list,
                size: 20.r,
                color: AppColors.onSurface.withValues(alpha: 0.55),
              ),
              title: Text(
                '任务中心',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                ),
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
            padding: EdgeInsets.all(Spacing.xxl.r),
            child: Center(
              child: Text(
                '暂无通知',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: Spacing.sm.h),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final n = list[i];
            return ListTile(
              title: Text(
                n.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: n.isRead ? FontWeight.normal : FontWeight.w500,
                  color: n.isRead
                      ? AppColors.onSurface.withValues(alpha: 0.6)
                      : AppColors.onSurface.withValues(alpha: 0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: n.body.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: Spacing.xs.h),
                      child: Text(
                        n.body,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.onSurface.withValues(alpha: 0.55),
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
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.all(Spacing.xxl.r),
          child: CircularProgressIndicator(strokeWidth: 2.r),
        ),
      ),
      error: (e, st) => Padding(
        padding: EdgeInsets.all(Spacing.xxl.r),
        child: Center(
          child: Text(
            '加载失败',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
