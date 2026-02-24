import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/notification.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();

    final notifications = storeProvider.notifications
        .where((n) => n.userId == authProvider.currentUser?.id)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (storeProvider.unreadNotificationsCount > 0)
            TextButton(
              onPressed: storeProvider.markAllNotificationsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmpty(context)
          : ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final notif = notifications[i];
                return _NotificationTile(
                  notification: notif,
                  onTap: () =>
                      storeProvider.markNotificationRead(notif.id),
                );
              },
            ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      tileColor: notification.isRead
          ? null
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      leading: CircleAvatar(
        backgroundColor: _bgColor(theme),
        child: Icon(_icon, color: _iconColor(theme), size: 22),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight:
              notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
            timeago.format(notification.createdAt),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      trailing: notification.isRead
          ? null
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
      onTap: onTap,
    );
  }

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.message:
        return Icons.chat_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.newStore:
        return Icons.storefront_rounded;
      case NotificationType.review:
        return Icons.star_rounded;
      case NotificationType.system:
        return Icons.notifications_rounded;
    }
  }

  Color _bgColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.message:
        return theme.colorScheme.primaryContainer;
      case NotificationType.promotion:
        return Colors.orange.shade100;
      case NotificationType.newStore:
        return Colors.green.shade100;
      case NotificationType.review:
        return Colors.amber.shade100;
      case NotificationType.system:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _iconColor(ThemeData theme) {
    switch (notification.type) {
      case NotificationType.message:
        return theme.colorScheme.primary;
      case NotificationType.promotion:
        return Colors.orange.shade700;
      case NotificationType.newStore:
        return Colors.green.shade700;
      case NotificationType.review:
        return Colors.amber.shade700;
      case NotificationType.system:
        return theme.colorScheme.onSurfaceVariant;
    }
  }
}
