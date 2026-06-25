import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/admin/admin_user_model.dart';
import '../models/admin/audit_log_model.dart';
import '../models/admin/permission_model.dart';
import '../models/admin/role_model.dart';
import '../models/user_model.dart';
import '../repositories/admin_repository.dart';
import '../repositories/marketplace_repository.dart';
import 'auth_controller.dart';

enum AdminAccountFilter { all, active, inactive }

enum AdminAccountActionResult { success, forbidden, notFound, protectedAccount }

class AdminAccountController extends ChangeNotifier {
  AdminAccountController({
    required AdminRepository adminRepository,
    required MarketplaceRepository marketplaceRepository,
  }) : _adminRepository = adminRepository,
       _marketplaceRepository = marketplaceRepository;

  final AdminRepository _adminRepository;
  final MarketplaceRepository _marketplaceRepository;

  AuthController? _authController;

  bool isLoading = false;
  String searchQuery = '';
  AdminAccountFilter filter = AdminAccountFilter.all;

  List<AdminUserModel> _adminUsers = const [];
  List<RoleModel> _roles = const [];
  List<PermissionModel> _permissions = const [];
  List<AuditLogModel> _auditLogs = const [];
  List<UserModel> _marketplaceUsers = const [];

  List<AdminUserModel> get adminUsers {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final filtered = _adminUsers.where((account) {
      final matchesFilter = switch (filter) {
        AdminAccountFilter.all => true,
        AdminAccountFilter.active => account.isActive,
        AdminAccountFilter.inactive => !account.isActive,
      };
      if (!matchesFilter) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      return account.name.toLowerCase().contains(normalizedQuery) ||
          account.email.toLowerCase().contains(normalizedQuery) ||
          account.roleName.toLowerCase().contains(normalizedQuery);
    }).toList();
    filtered.sort((left, right) {
      final statusCompare = (right.isActive ? 1 : 0).compareTo(
        left.isActive ? 1 : 0,
      );
      if (statusCompare != 0) {
        return statusCompare;
      }
      return left.name.toLowerCase().compareTo(right.name.toLowerCase());
    });
    return filtered;
  }

  List<RoleModel> get roles => _roles;
  List<PermissionModel> get permissions => _permissions;
  int get totalCount => _adminUsers.length;
  int get activeCount =>
      _adminUsers.where((account) => account.isActive).length;
  int get inactiveCount =>
      _adminUsers.where((account) => !account.isActive).length;
  bool get canManageAccounts =>
      _authController?.hasPermission('settings.manage') ?? false;

  void bind({required AuthController authController}) {
    _authController = authController;
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _adminRepository.getAdminUsers(),
        _adminRepository.getRoles(),
        _adminRepository.getPermissions(),
        _adminRepository.getAuditLogs(),
        _marketplaceRepository.getUsers(),
      ]);
      _adminUsers = results[0] as List<AdminUserModel>;
      _roles = results[1] as List<RoleModel>;
      _permissions = results[2] as List<PermissionModel>;
      _auditLogs = results[3] as List<AuditLogModel>;
      _marketplaceUsers = results[4] as List<UserModel>;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String value) {
    if (searchQuery == value) {
      return;
    }
    searchQuery = value;
    notifyListeners();
  }

  void setFilter(AdminAccountFilter value) {
    if (filter == value) {
      return;
    }
    filter = value;
    notifyListeners();
  }

  AdminUserModel? adminUserById(String id) {
    for (final account in _adminUsers) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  RoleModel? roleFor(AdminUserModel account) {
    for (final role in _roles) {
      if (role.name == account.roleName) {
        return role;
      }
    }
    return null;
  }

  UserModel? linkedMarketplaceUser(AdminUserModel account) {
    for (final user in _marketplaceUsers) {
      if (user.id == account.userId) {
        return user;
      }
    }
    return null;
  }

  List<PermissionModel> permissionsFor(AdminUserModel account) {
    final permissionIds = account.permissionIds.toSet();
    final matched = _permissions
        .where((permission) => permissionIds.contains(permission.id))
        .toList();
    matched.sort((left, right) => left.name.compareTo(right.name));
    return matched;
  }

  List<AuditLogModel> auditLogsFor(AdminUserModel account) {
    final logs = _auditLogs
        .where(
          (log) => log.entityId == account.id || log.adminUserId == account.id,
        )
        .toList();
    logs.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return logs;
  }

  bool isCurrentAccount(AdminUserModel account) {
    return _authController?.currentUser?.id == account.userId;
  }

  Future<AdminAccountActionResult> toggleAccountStatus(
    AdminUserModel account,
  ) async {
    if (!canManageAccounts) {
      return AdminAccountActionResult.forbidden;
    }
    final index = _adminUsers.indexWhere((item) => item.id == account.id);
    if (index == -1) {
      return AdminAccountActionResult.notFound;
    }
    final activeSuperAdminCount = _adminUsers
        .where((item) => item.roleName == 'Super Admin' && item.isActive)
        .length;
    if (account.roleName == 'Super Admin' &&
        account.isActive &&
        activeSuperAdminCount <= 1) {
      return AdminAccountActionResult.protectedAccount;
    }

    final updatedAccount = account.copyWith(isActive: !account.isActive);
    final updatedAccounts = List<AdminUserModel>.from(_adminUsers);
    updatedAccounts[index] = updatedAccount;
    _adminUsers = updatedAccounts;
    await _adminRepository.saveAdminUsers(_adminUsers);

    final linkedUser = linkedMarketplaceUser(account);
    if (linkedUser != null) {
      final updatedUser = linkedUser.copyWith(
        adminRoleName: updatedAccount.roleName,
        adminPermissionIds: updatedAccount.permissionIds,
        adminIsActive: updatedAccount.isActive,
      );
      await _marketplaceRepository.saveUser(updatedUser);
      final marketplaceIndex = _marketplaceUsers.indexWhere(
        (item) => item.id == updatedUser.id,
      );
      if (marketplaceIndex != -1) {
        final updatedMarketplaceUsers = List<UserModel>.from(_marketplaceUsers);
        updatedMarketplaceUsers[marketplaceIndex] = updatedUser;
        _marketplaceUsers = updatedMarketplaceUsers;
      }
      if (_authController?.currentUser?.id == updatedUser.id) {
        _authController?.replaceUser(updatedUser);
      }
    }

    await _adminRepository.appendAuditLog(
      AuditLogModel(
        id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
        adminUserId: _authController?.currentUser?.id ?? 'system',
        adminName: _authController?.currentUser?.name ?? 'System',
        action: updatedAccount.isActive
            ? 'activate_admin_account'
            : 'deactivate_admin_account',
        entityType: 'admin_user',
        entityId: updatedAccount.id,
        timestamp: DateTime.now(),
        result: 'success',
        previousValueJson: jsonEncode(account.toJson()),
        newValueJson: jsonEncode(updatedAccount.toJson()),
      ),
    );

    unawaited(load());
    notifyListeners();
    return AdminAccountActionResult.success;
  }
}
