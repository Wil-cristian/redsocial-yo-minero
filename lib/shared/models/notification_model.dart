import 'package:flutter/material.dart';

enum NotificationType {
  message,
  groupInvite,
  productLiked,
  serviceRequest,
  newFollower,
  comment,
  mention,
}

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final String? actionUrl;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.actionUrl,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: _parseNotificationType(json['type'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      data: (json['data'] as Map<String, dynamic>?) ?? {},
      actionUrl: json['action_url'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type) {
      case 'message':
        return NotificationType.message;
      case 'group_invite':
        return NotificationType.groupInvite;
      case 'product_liked':
        return NotificationType.productLiked;
      case 'service_request':
        return NotificationType.serviceRequest;
      case 'new_follower':
        return NotificationType.newFollower;
      case 'comment':
        return NotificationType.comment;
      case 'mention':
        return NotificationType.mention;
      default:
        return NotificationType.message;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.message:
        return Icons.message;
      case NotificationType.groupInvite:
        return Icons.group_add;
      case NotificationType.productLiked:
        return Icons.favorite;
      case NotificationType.serviceRequest:
        return Icons.handyman;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.mention:
        return Icons.alternate_email;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.groupInvite:
        return Colors.purple;
      case NotificationType.productLiked:
        return Colors.red;
      case NotificationType.serviceRequest:
        return Colors.orange;
      case NotificationType.newFollower:
        return Colors.green;
      case NotificationType.comment:
        return Colors.teal;
      case NotificationType.mention:
        return Colors.indigo;
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} d';
    } else {
      return 'Hace ${(difference.inDays / 7).floor()} sem';
    }
  }
}
