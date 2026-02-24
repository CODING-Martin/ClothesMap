class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
  });

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageType? type,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

enum MessageType { text, image, promotion }

class ChatModel {
  final String id;
  final String customerId;
  final String customerName;
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final List<MessageModel> messages;
  final DateTime lastActivity;

  const ChatModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl,
    this.messages = const [],
    required this.lastActivity,
  });

  MessageModel? get lastMessage =>
      messages.isNotEmpty ? messages.last : null;

  int get unreadCount =>
      messages.where((m) => !m.isRead && m.senderId != customerId).length;
}
