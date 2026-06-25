class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.roleName,
    required this.permissionIds,
    required this.isActive,
    this.lastLoginAt,
  });

  final String id;
  final String userId;
  final String name;
  final String email;
  final String roleName;
  final List<String> permissionIds;
  final bool isActive;
  final DateTime? lastLoginAt;

  AdminUserModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? roleName,
    List<String>? permissionIds,
    bool? isActive,
    DateTime? lastLoginAt,
  }) {
    return AdminUserModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      roleName: roleName ?? this.roleName,
      permissionIds: permissionIds ?? this.permissionIds,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      roleName: json['roleName'] as String? ?? '',
      permissionIds: (json['permissionIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.tryParse(json['lastLoginAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'name': name,
    'email': email,
    'roleName': roleName,
    'permissionIds': permissionIds,
    'isActive': isActive,
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };
}
