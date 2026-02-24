class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? referenceId;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.referenceId,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? referenceId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
    );
  }

  String get iconName {
    switch (type) {
      case NotificationType.message:
        return 'chat';
      case NotificationType.promotion:
        return 'local_offer';
      case NotificationType.newStore:
        return 'store';
      case NotificationType.review:
        return 'star';
      case NotificationType.system:
        return 'notifications';
    }
  }
}

enum NotificationType { message, promotion, newStore, review, system }
