class AuditLogModel {
  const AuditLogModel({
    required this.id,
    required this.adminUserId,
    required this.adminName,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
    required this.result,
    this.reason = '',
    this.previousValueJson = '',
    this.newValueJson = '',
    this.approvalRequestId = '',
  });

  final String id;
  final String adminUserId;
  final String adminName;
  final String action;
  final String entityType;
  final String entityId;
  final DateTime timestamp;
  final String result;
  final String reason;
  final String previousValueJson;
  final String newValueJson;
  final String approvalRequestId;

  AuditLogModel copyWith({
    String? id,
    String? adminUserId,
    String? adminName,
    String? action,
    String? entityType,
    String? entityId,
    DateTime? timestamp,
    String? result,
    String? reason,
    String? previousValueJson,
    String? newValueJson,
    String? approvalRequestId,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      adminUserId: adminUserId ?? this.adminUserId,
      adminName: adminName ?? this.adminName,
      action: action ?? this.action,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      timestamp: timestamp ?? this.timestamp,
      result: result ?? this.result,
      reason: reason ?? this.reason,
      previousValueJson: previousValueJson ?? this.previousValueJson,
      newValueJson: newValueJson ?? this.newValueJson,
      approvalRequestId: approvalRequestId ?? this.approvalRequestId,
    );
  }

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      id: json['id'] as String? ?? '',
      adminUserId: json['adminUserId'] as String? ?? '',
      adminName: json['adminName'] as String? ?? '',
      action: json['action'] as String? ?? '',
      entityType: json['entityType'] as String? ?? '',
      entityId: json['entityId'] as String? ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      result: json['result'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      previousValueJson: json['previousValueJson'] as String? ?? '',
      newValueJson: json['newValueJson'] as String? ?? '',
      approvalRequestId: json['approvalRequestId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'adminUserId': adminUserId,
    'adminName': adminName,
    'action': action,
    'entityType': entityType,
    'entityId': entityId,
    'timestamp': timestamp.toIso8601String(),
    'result': result,
    'reason': reason,
    'previousValueJson': previousValueJson,
    'newValueJson': newValueJson,
    'approvalRequestId': approvalRequestId,
  };
}
