enum MessageType {
  text,
  image,
  file;

  String toJson() {
    return name;
  }

  static MessageType fromString(String type) {
    return MessageType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => MessageType.text,
    );
  }
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final MessageType messageType;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.messageType = MessageType.text,
    this.isRead = false,
    this.readAt,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      messageType: MessageType.fromString(json['message_type'] as String? ?? 'text'),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType.toJson(),
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsert() {
    return {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType.toJson(),
    };
  }
}
