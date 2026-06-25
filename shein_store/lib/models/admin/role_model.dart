class RoleModel {
  const RoleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.permissionIds,
    this.isSystem = true,
    this.isReadOnly = false,
  });

  final String id;
  final String name;
  final String description;
  final List<String> permissionIds;
  final bool isSystem;
  final bool isReadOnly;

  RoleModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? permissionIds,
    bool? isSystem,
    bool? isReadOnly,
  }) {
    return RoleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissionIds: permissionIds ?? this.permissionIds,
      isSystem: isSystem ?? this.isSystem,
      isReadOnly: isReadOnly ?? this.isReadOnly,
    );
  }

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      permissionIds: (json['permissionIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      isSystem: json['isSystem'] as bool? ?? true,
      isReadOnly: json['isReadOnly'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'permissionIds': permissionIds,
    'isSystem': isSystem,
    'isReadOnly': isReadOnly,
  };
}
