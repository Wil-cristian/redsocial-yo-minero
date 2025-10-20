enum AccountType {
  individual,
  group, 
  company
}

class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final AccountType accountType;
  final String? companyName;
  final String? groupName;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.accountType,
    this.companyName,
    this.groupName,
    required this.createdAt,
  });

  String get displayName {
    switch (accountType) {
      case AccountType.company:
        return companyName ?? name;
      case AccountType.group:
        return groupName ?? name;
      case AccountType.individual:
        return name;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'accountType': accountType.name,
      'companyName': companyName,
      'groupName': groupName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      name: json['name'],
      accountType: AccountType.values.firstWhere(
        (type) => type.name == json['accountType'],
        orElse: () => AccountType.individual,
      ),
      companyName: json['companyName'],
      groupName: json['groupName'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
