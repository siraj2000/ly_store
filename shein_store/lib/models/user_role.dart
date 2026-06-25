enum UserRole { guest, customer, seller, admin }

extension UserRoleJson on UserRole {
  String toJsonValue() => name;

  static UserRole fromJsonValue(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.guest,
    );
  }
}
