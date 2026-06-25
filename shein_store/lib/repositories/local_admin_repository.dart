import '../models/admin/admin_user_model.dart';
import '../models/admin/audit_log_model.dart';
import '../models/admin/permission_model.dart';
import '../models/admin/platform_setting_model.dart';
import '../models/admin/role_model.dart';
import '../services/local_storage_service.dart';
import 'admin_repository.dart';

// Local repository is used for demo only. Replace with secure backend API repository for production and multi-device synchronization.
class LocalAdminRepository implements AdminRepository {
  LocalAdminRepository({required LocalStorageService localStorageService})
    : _localStorageService = localStorageService;

  static const String _adminUsersKey = 'marketplace_admin_users';
  static const String _rolesKey = 'marketplace_roles';
  static const String _permissionsKey = 'marketplace_permissions';
  static const String _platformSettingsKey = 'marketplace_platform_settings';
  static const String _auditLogsKey = 'marketplace_audit_logs';

  final LocalStorageService _localStorageService;

  @override
  Future<void> appendAuditLog(AuditLogModel log) async {
    final logs = await getAuditLogs();
    await _localStorageService.saveJsonList(_auditLogsKey, [
      log.toJson(),
      ...logs.map((item) => item.toJson()),
    ]);
  }

  @override
  Future<List<AdminUserModel>> getAdminUsers() async {
    final raw = _localStorageService.getJsonList(_adminUsersKey);
    if (raw.isEmpty) {
      final seeded = _seedAdminUsers();
      await saveAdminUsers(seeded);
      return seeded;
    }
    return raw.map(AdminUserModel.fromJson).toList();
  }

  @override
  Future<List<AuditLogModel>> getAuditLogs() async {
    final raw = _localStorageService.getJsonList(_auditLogsKey);
    if (raw.isEmpty) {
      final seeded = _seedAuditLogs();
      await _localStorageService.saveJsonList(
        _auditLogsKey,
        seeded.map((item) => item.toJson()).toList(),
      );
      return seeded;
    }
    return raw.map(AuditLogModel.fromJson).toList();
  }

  @override
  Future<List<PermissionModel>> getPermissions() async {
    final raw = _localStorageService.getJsonList(_permissionsKey);
    if (raw.isEmpty) {
      final seeded = _seedPermissions();
      await savePermissions(seeded);
      return seeded;
    }
    return raw.map(PermissionModel.fromJson).toList();
  }

  @override
  Future<PlatformSettingModel> getPlatformSettings() async {
    final raw = _localStorageService.getJson(_platformSettingsKey);
    if (raw == null) {
      final seeded = const PlatformSettingModel(
        platformName: 'StyleHub',
        defaultLanguageCode: 'en',
        defaultCurrencyCode: 'USD',
        requiresProductApproval: false,
        defaultCommissionRate: 0.12,
        minimumPayoutAmount: 50,
        refundMakerCheckerThreshold: 150,
      );
      await savePlatformSettings(seeded);
      return seeded;
    }
    return PlatformSettingModel.fromJson(raw);
  }

  @override
  Future<List<RoleModel>> getRoles() async {
    final raw = _localStorageService.getJsonList(_rolesKey);
    if (raw.isEmpty) {
      final seeded = _seedRoles();
      await saveRoles(seeded);
      return seeded;
    }
    return raw.map(RoleModel.fromJson).toList();
  }

  @override
  Future<void> saveAdminUsers(List<AdminUserModel> users) async {
    await _localStorageService.saveJsonList(
      _adminUsersKey,
      users.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<void> savePermissions(List<PermissionModel> permissions) async {
    await _localStorageService.saveJsonList(
      _permissionsKey,
      permissions.map((item) => item.toJson()).toList(),
    );
  }

  @override
  Future<void> savePlatformSettings(PlatformSettingModel settings) async {
    await _localStorageService.saveJson(
      _platformSettingsKey,
      settings.toJson(),
    );
  }

  @override
  Future<void> saveRoles(List<RoleModel> roles) async {
    await _localStorageService.saveJsonList(
      _rolesKey,
      roles.map((item) => item.toJson()).toList(),
    );
  }

  List<PermissionModel> _seedPermissions() {
    const permissionIds = [
      'dashboard.view',
      'sellers.view',
      'sellers.create',
      'sellers.edit',
      'sellers.activate',
      'sellers.approve',
      'sellers.suspend',
      'sellers.resetPassword',
      'stores.view',
      'stores.create',
      'stores.edit',
      'stores.activate',
      'stores.suspend',
      'products.view',
      'products.approve',
      'products.reject',
      'orders.view',
      'orders.update',
      'refunds.approve',
      'promotions.manage',
      'support.manage',
      'compliance.manage',
      'risk.manage',
      'reports.view',
      'settings.manage',
      'audit.view',
      '*',
    ];
    return permissionIds
        .map(
          (id) => PermissionModel(
            id: id,
            name: id,
            moduleKey: id.split('.').first,
            description: 'Demo permission for $id',
          ),
        )
        .toList();
  }

  List<RoleModel> _seedRoles() {
    return const [
      RoleModel(
        id: 'super_admin',
        name: 'Super Admin',
        description: 'Full marketplace access.',
        permissionIds: ['*'],
      ),
      RoleModel(
        id: 'marketplace_manager',
        name: 'Marketplace Manager',
        description: 'Oversees sellers, products, and orders.',
        permissionIds: [
          'dashboard.view',
          'sellers.view',
          'sellers.create',
          'sellers.edit',
          'sellers.activate',
          'sellers.approve',
          'sellers.suspend',
          'sellers.resetPassword',
          'stores.view',
          'stores.create',
          'stores.edit',
          'stores.activate',
          'stores.suspend',
          'products.view',
          'products.approve',
          'products.reject',
          'orders.view',
          'orders.update',
          'reports.view',
        ],
      ),
      RoleModel(
        id: 'catalog_moderator',
        name: 'Catalog Moderator',
        description: 'Moderates seller catalog content.',
        permissionIds: [
          'dashboard.view',
          'sellers.view',
          'stores.view',
          'products.view',
          'products.approve',
          'products.reject',
        ],
      ),
      RoleModel(
        id: 'finance_officer',
        name: 'Finance Officer',
        description: 'Handles payouts and refund review.',
        permissionIds: [
          'dashboard.view',
          'orders.view',
          'refunds.approve',
          'reports.view',
          'audit.view',
        ],
      ),
      RoleModel(
        id: 'customer_support_agent',
        name: 'Customer Support Agent',
        description: 'Handles customer support and disputes.',
        permissionIds: [
          'dashboard.view',
          'support.manage',
          'orders.view',
          'sellers.view',
          'stores.view',
        ],
      ),
      RoleModel(
        id: 'compliance_officer',
        name: 'Compliance Officer',
        description: 'Handles compliance and product safety.',
        permissionIds: [
          'dashboard.view',
          'products.view',
          'compliance.manage',
          'audit.view',
        ],
      ),
      RoleModel(
        id: 'risk_analyst',
        name: 'Risk Analyst',
        description: 'Monitors marketplace risk.',
        permissionIds: [
          'dashboard.view',
          'orders.view',
          'risk.manage',
          'reports.view',
          'audit.view',
        ],
      ),
      RoleModel(
        id: 'read_only',
        name: 'Read Only',
        description: 'Can view permitted modules but cannot mutate data.',
        permissionIds: ['dashboard.view', 'reports.view', 'audit.view'],
        isReadOnly: true,
      ),
    ];
  }

  List<AdminUserModel> _seedAdminUsers() {
    return const [
      AdminUserModel(
        id: 'admin_user_super_admin',
        userId: 'admin_super_1',
        name: 'StyleHub Super Admin',
        email: 'superadmin@stylehub.com',
        roleName: 'Super Admin',
        permissionIds: ['*'],
        isActive: true,
      ),
      AdminUserModel(
        id: 'admin_user_manager',
        userId: 'admin_manager_1',
        name: 'Marketplace Manager',
        email: 'manager@stylehub.com',
        roleName: 'Marketplace Manager',
        permissionIds: [
          'dashboard.view',
          'sellers.view',
          'sellers.approve',
          'products.view',
          'products.approve',
          'orders.view',
          'orders.update',
          'reports.view',
        ],
        isActive: true,
      ),
      AdminUserModel(
        id: 'admin_user_catalog',
        userId: 'admin_catalog_1',
        name: 'Catalog Moderator',
        email: 'catalog@stylehub.com',
        roleName: 'Catalog Moderator',
        permissionIds: [
          'dashboard.view',
          'products.view',
          'products.approve',
          'products.reject',
          'sellers.view',
        ],
        isActive: true,
      ),
      AdminUserModel(
        id: 'admin_user_finance',
        userId: 'admin_finance_1',
        name: 'Finance Officer',
        email: 'finance@stylehub.com',
        roleName: 'Finance Officer',
        permissionIds: [
          'dashboard.view',
          'orders.view',
          'refunds.approve',
          'reports.view',
          'audit.view',
        ],
        isActive: true,
      ),
      AdminUserModel(
        id: 'admin_user_support',
        userId: 'admin_support_1',
        name: 'Support Agent',
        email: 'support@stylehub.com',
        roleName: 'Customer Support Agent',
        permissionIds: [
          'dashboard.view',
          'support.manage',
          'orders.view',
          'sellers.view',
        ],
        isActive: true,
      ),
      AdminUserModel(
        id: 'admin_user_compliance',
        userId: 'admin_compliance_1',
        name: 'Compliance Officer',
        email: 'compliance@stylehub.com',
        roleName: 'Compliance Officer',
        permissionIds: [
          'dashboard.view',
          'products.view',
          'compliance.manage',
          'audit.view',
        ],
        isActive: true,
      ),
      AdminUserModel(
        id: 'admin_user_risk',
        userId: 'admin_risk_1',
        name: 'Risk Analyst',
        email: 'risk@stylehub.com',
        roleName: 'Risk Analyst',
        permissionIds: [
          'dashboard.view',
          'orders.view',
          'risk.manage',
          'reports.view',
          'audit.view',
        ],
        isActive: true,
      ),
    ];
  }

  List<AuditLogModel> _seedAuditLogs() {
    final now = DateTime.now();
    return [
      AuditLogModel(
        id: 'audit_seed_1',
        adminUserId: 'admin_user_super_admin',
        adminName: 'StyleHub Super Admin',
        action: 'review_platform_settings',
        entityType: 'platform_setting',
        entityId: 'stylehub_platform',
        timestamp: now.subtract(const Duration(hours: 6)),
        result: 'success',
      ),
      AuditLogModel(
        id: 'audit_seed_2',
        adminUserId: 'admin_user_manager',
        adminName: 'Marketplace Manager',
        action: 'approve_product_batch',
        entityType: 'product',
        entityId: 'batch_june_catalog',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        result: 'success',
      ),
      AuditLogModel(
        id: 'audit_seed_3',
        adminUserId: 'admin_user_finance',
        adminName: 'Finance Officer',
        action: 'review_refund_queue',
        entityType: 'refund',
        entityId: 'refund_queue_daily',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        result: 'success',
      ),
    ];
  }
}
