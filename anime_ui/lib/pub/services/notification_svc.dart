import 'api.dart';

/// 通知模型（站内通知，README 2.6）
class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.title,
    this.body = '',
    this.linkUrl = '',
    this.readAt,
  });

  final String id;
  final String createdAt;
  final String type;
  final String title;
  final String body;
  final String linkUrl;
  final String? readAt;

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      type: json['type'] as String? ?? 'task_complete',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      linkUrl: json['link_url'] as String? ?? '',
      readAt: json['read_at'] as String?,
    );
  }

  bool get isRead => readAt != null && readAt!.isNotEmpty;
}

class NotificationService {
  /// 分页获取通知列表
  Future<List<NotificationItem>> list({
    int limit = 50,
    int offset = 0,
  }) async {
    final resp = await dio.get(
      '/notifications',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    final data = extractData<Map<String, dynamic>>(resp);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) =>
            NotificationItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// 获取未读数量（红点）
  Future<int> getUnreadCount() async {
    final resp = await dio.get('/notifications/unread-count');
    final data = extractData<Map<String, dynamic>>(resp);
    return data['count'] as int? ?? 0;
  }

  /// 标记单条已读
  Future<void> markAsRead(String id) async {
    await dio.put('/notifications/$id/read');
  }

  /// 全部已读
  Future<void> markAllAsRead() async {
    await dio.put('/notifications/read-all');
  }
}
