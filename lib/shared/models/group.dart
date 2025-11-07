class Group {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String ownerId;
  final Set<String> memberIds;
  final Set<String> tags;
  
  final List<String> keywords;
  final List<String> interests;
  final bool isPrivate;
  final int? maxMembers;
  final int membersCount;
  final int postsCount;
  final DateTime? updatedAt;

  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.ownerId,
    Set<String>? memberIds,
    Set<String>? tags,
    List<String>? keywords,
    List<String>? interests,
    this.isPrivate = false,
    this.maxMembers,
    this.membersCount = 0,
    this.postsCount = 0,
    this.updatedAt,
  })  : memberIds = memberIds ?? <String>{},
        tags = tags ?? <String>{},
        keywords = keywords ?? [],
        interests = interests ?? [];

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      ownerId: json['creator_id'] as String,
      keywords: json['keywords'] != null 
          ? List<String>.from(json['keywords']) 
          : [],
      interests: json['interests'] != null 
          ? List<String>.from(json['interests']) 
          : [],
      isPrivate: json['is_private'] as bool? ?? false,
      maxMembers: json['max_members'] as int?,
      membersCount: json['members_count'] as int? ?? 0,
      postsCount: json['posts_count'] as int? ?? 0,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
      tags: json['keywords'] != null 
          ? Set<String>.from(json['keywords']) 
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': ownerId,
      'name': name,
      'description': description,
      'keywords': keywords,
      'interests': interests,
      'is_private': isPrivate,
      'max_members': maxMembers,
      'members_count': membersCount,
      'posts_count': postsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    String? ownerId,
    Set<String>? memberIds,
    Set<String>? tags,
    List<String>? keywords,
    List<String>? interests,
    bool? isPrivate,
    int? maxMembers,
    int? membersCount,
    int? postsCount,
    DateTime? updatedAt,
  }) =>
      Group(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        ownerId: ownerId ?? this.ownerId,
        memberIds: memberIds ?? this.memberIds,
        tags: tags ?? this.tags,
        keywords: keywords ?? this.keywords,
        interests: interests ?? this.interests,
        isPrivate: isPrivate ?? this.isPrivate,
        maxMembers: maxMembers ?? this.maxMembers,
        membersCount: membersCount ?? this.membersCount,
        postsCount: postsCount ?? this.postsCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  bool get isEmpty => id.isEmpty;
}
