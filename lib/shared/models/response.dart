/// Respuesta a un post tipo pregunta (request)
class Response {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final bool isBestAnswer;
  final bool isEdited;
  final int editCount;
  final int likesCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Para respuestas anidadas
  final String? parentResponseId;

  // Información del autor
  final String? authorName;
  final String? authorUsername;
  final String? authorProfileImage;

  // Si el usuario actual le dio like
  final bool userHasLiked;

  const Response({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.isBestAnswer = false,
    this.isEdited = false,
    this.editCount = 0,
    this.likesCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.parentResponseId,
    this.authorName,
    this.authorUsername,
    this.authorProfileImage,
    this.userHasLiked = false,
  });

  Response copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? content,
    bool? isBestAnswer,
    bool? isEdited,
    int? editCount,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? parentResponseId,
    String? authorName,
    String? authorUsername,
    String? authorProfileImage,
    bool? userHasLiked,
  }) {
    return Response(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      isBestAnswer: isBestAnswer ?? this.isBestAnswer,
      isEdited: isEdited ?? this.isEdited,
      editCount: editCount ?? this.editCount,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parentResponseId: parentResponseId ?? this.parentResponseId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorProfileImage: authorProfileImage ?? this.authorProfileImage,
      userHasLiked: userHasLiked ?? this.userHasLiked,
    );
  }

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      isBestAnswer: json['is_best_answer'] as bool? ?? false,
      isEdited: json['is_edited'] as bool? ?? false,
      editCount: json['edit_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      parentResponseId: json['parent_response_id'] as String?,
      authorName: json['author_name'] as String?,
      authorUsername: json['author_username'] as String?,
      authorProfileImage: json['author_profile_image'] as String?,
      userHasLiked: json['user_has_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'is_best_answer': isBestAnswer,
      'is_edited': isEdited,
      'edit_count': editCount,
      'likes_count': likesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'parent_response_id': parentResponseId,
      'author_name': authorName,
      'author_username': authorUsername,
      'author_profile_image': authorProfileImage,
      'user_has_liked': userHasLiked,
    };
  }
}
