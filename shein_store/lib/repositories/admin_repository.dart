import '../models/admin/admin_user_model.dart';
import '../models/admin/audit_log_model.dart';
import '../models/admin/permission_model.dart';
import '../models/admin/platform_setting_model.dart';
import '../models/admin/role_model.dart';

abstract class AdminRepository {
  Future<List<AdminUserModel>> getAdminUsers();
  Future<List<RoleModel>> getRoles();
  Future<List<PermissionModel>> getPermissions();
  Future<PlatformSettingModel> getPlatformSettings();
  Future<List<AuditLogModel>> getAuditLogs();

  Future<void> saveAdminUsers(List<AdminUserModel> users);
  Future<void> saveRoles(List<RoleModel> roles);
  Future<void> savePermissions(List<PermissionModel> permissions);
  Future<void> savePlatformSettings(PlatformSettingModel settings);
  Future<void> appendAuditLog(AuditLogModel log);
}
