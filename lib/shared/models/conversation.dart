class Conversation {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime lastMessageAt;
  final int unreadCountUser1;
  final int unreadCountUser2;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Información de usuarios para mostrar nombres
  final String? user1Name;
  final String? user2Name;
  final String? user1ProfileImage;
  final String? user2ProfileImage;

  Conversation({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    DateTime? lastMessageAt,
    this.unreadCountUser1 = 0,
    this.unreadCountUser2 = 0,
    DateTime? createdAt,
    this.updatedAt,
    this.user1Name,
    this.user2Name,
    this.user1ProfileImage,
    this.user2ProfileImage,
  }) : lastMessageAt = lastMessageAt ?? DateTime.now(),
       createdAt = createdAt ?? DateTime.now();

  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }
  
  String getOtherUserName(String currentUserId) {
    if (currentUserId == user1Id) {
      return user2Name ?? 'Usuario ${user2Id.substring(0, 8)}';
    } else {
      return user1Name ?? 'Usuario ${user1Id.substring(0, 8)}';
    }
  }
  
  String? getOtherUserProfileImage(String currentUserId) {
    return currentUserId == user1Id ? user2ProfileImage : user1ProfileImage;
  }

  int getUnreadCount(String currentUserId) {
    return currentUserId == user1Id ? unreadCountUser1 : unreadCountUser2;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      unreadCountUser1: json['unread_count_user1'] as int? ?? 0,
      unreadCountUser2: json['unread_count_user2'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      // Parsear información de usuarios del join
      user1Name: json['user1']?['name'] as String?,
      user2Name: json['user2']?['name'] as String?,
      user1ProfileImage: json['user1']?['profile_image_url'] as String?,
      user2ProfileImage: json['user2']?['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'last_message_at': lastMessageAt.toIso8601String(),
      'unread_count_user1': unreadCountUser1,
      'unread_count_user2': unreadCountUser2,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static Map<String, dynamic> toInsert(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return {
      'user1_id': sortedIds[0],
      'user2_id': sortedIds[1],
    };
  }
}
