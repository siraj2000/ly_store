class PendingRegistrationSession {
  const PendingRegistrationSession({
    required this.sessionId,
    required this.fullName,
    required this.normalizedPhoneNumber,
    required this.otpId,
    required this.expiresAt,
    required this.createdAt,
    this.attemptCount = 0,
    this.otpVerified = false,
  });

  final String sessionId;
  final String fullName;
  final String normalizedPhoneNumber;
  final String otpId;
  final DateTime expiresAt;
  final DateTime createdAt;
  final int attemptCount;
  final bool otpVerified;

  PendingRegistrationSession copyWith({
    String? sessionId,
    String? fullName,
    String? normalizedPhoneNumber,
    String? otpId,
    DateTime? expiresAt,
    DateTime? createdAt,
    int? attemptCount,
    bool? otpVerified,
  }) {
    return PendingRegistrationSession(
      sessionId: sessionId ?? this.sessionId,
      fullName: fullName ?? this.fullName,
      normalizedPhoneNumber:
          normalizedPhoneNumber ?? this.normalizedPhoneNumber,
      otpId: otpId ?? this.otpId,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      otpVerified: otpVerified ?? this.otpVerified,
    );
  }
}
