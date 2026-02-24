import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storeProvider = context.watch<StoreProvider>();
    final authProvider = context.watch<AuthProvider>();

    final myChats = storeProvider.chats
        .where((c) => c.customerId == authProvider.currentUser?.id)
        .toList()
      ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: myChats.isEmpty
          ? _buildEmpty(context)
          : ListView.separated(
              itemCount: myChats.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final chat = myChats[i];
                final lastMsg = chat.lastMessage;
                final unread = chat.unreadCount;

                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.storefront_outlined,
                        color: theme.colorScheme.primary),
                  ),
                  title: Text(
                    chat.storeName,
                    style: TextStyle(
                      fontWeight:
                          unread > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: lastMsg != null
                      ? Text(
                          lastMsg.content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: unread > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                            color: unread > 0
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : const Text('No messages yet'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        lastMsg != null
                            ? timeago.format(lastMsg.timestamp,
                                locale: 'en_short')
                            : '',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: unread > 0
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (unread > 0) ...[
                        const SizedBox(height: 4),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            '$unread',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id,
                        storeName: chat.storeName,
                      ),
                    ));
                  },
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
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visit a store to start chatting with vendors',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
