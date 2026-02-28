import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/notification_svc.dart';

final notificationServiceProvider = Provider((_) => NotificationService());

/// 未读通知数量（红点，README 2.6）
final unreadNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final svc = ref.watch(notificationServiceProvider);
  return svc.getUnreadCount();
});

/// 通知列表
final notificationListProvider =
    FutureProvider.autoDispose<List<NotificationItem>>((ref) async {
  final svc = ref.watch(notificationServiceProvider);
  return svc.list(limit: 20, offset: 0);
});
