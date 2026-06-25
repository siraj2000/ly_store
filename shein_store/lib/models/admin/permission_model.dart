class PermissionModel {
  const PermissionModel({
    required this.id,
    required this.name,
    required this.moduleKey,
    required this.description,
  });

  final String id;
  final String name;
  final String moduleKey;
  final String description;

  PermissionModel copyWith({
    String? id,
    String? name,
    String? moduleKey,
    String? description,
  }) {
    return PermissionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      moduleKey: moduleKey ?? this.moduleKey,
      description: description ?? this.description,
    );
  }

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      moduleKey: json['moduleKey'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'moduleKey': moduleKey,
    'description': description,
  };
}
