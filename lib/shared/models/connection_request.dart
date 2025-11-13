class ConnectionRequest {
  final String id;
  final String senderId;
  final String receiverId;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? message;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Info adicional del otro usuario (cuando viene del JOIN)
  final String? otherUserName;
  final String? otherUserUsername;
  final String? otherUserProfileImage;

  ConnectionRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.message,
    required this.createdAt,
    required this.updatedAt,
    this.otherUserName,
    this.otherUserUsername,
    this.otherUserProfileImage,
  });

  factory ConnectionRequest.fromJson(Map<String, dynamic> json) {
    return ConnectionRequest(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Info del otro usuario (puede venir de sender o receiver según el contexto)
      otherUserName: json['sender_name'] as String? ?? json['receiver_name'] as String?,
      otherUserUsername: json['sender_username'] as String? ?? json['receiver_username'] as String?,
      otherUserProfileImage: json['sender_profile_image'] as String? ?? json['receiver_profile_image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  String getOtherUserId(String currentUserId) {
    return currentUserId == senderId ? receiverId : senderId;
  }

  String getOtherUserDisplayName() {
    return otherUserName ?? otherUserUsername ?? 'Usuario';
  }
}

class Connection {
  final String id;
  final String user1Id;
  final String user2Id;
  final DateTime createdAt;
  
  // Info adicional de los usuarios (cuando viene del JOIN)
  final String? user1Name;
  final String? user1Username;
  final String? user1ProfileImage;
  final String? user2Name;
  final String? user2Username;
  final String? user2ProfileImage;

  Connection({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.createdAt,
    this.user1Name,
    this.user1Username,
    this.user1ProfileImage,
    this.user2Name,
    this.user2Username,
    this.user2ProfileImage,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      user1Id: json['user1_id'] as String,
      user2Id: json['user2_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user1Name: json['user1_name'] as String?,
      user1Username: json['user1_username'] as String?,
      user1ProfileImage: json['user1_profile_image'] as String?,
      user2Name: json['user2_name'] as String?,
      user2Username: json['user2_username'] as String?,
      user2ProfileImage: json['user2_profile_image'] as String?,
    );
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == user1Id ? user2Id : user1Id;
  }

  String getOtherUserName(String currentUserId) {
    if (currentUserId == user1Id) {
      return user2Name ?? user2Username ?? 'Usuario';
    } else {
      return user1Name ?? user1Username ?? 'Usuario';
    }
  }

  String? getOtherUserProfileImage(String currentUserId) {
    return currentUserId == user1Id ? user2ProfileImage : user1ProfileImage;
  }
}
