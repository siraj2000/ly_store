import 'dart:math';

enum OtpVerificationStatus { verified, invalid, expired, tooManyAttempts }

class OtpSendResult {
  const OtpSendResult({
    required this.otpId,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final String otpId;
  final DateTime expiresAt;
  final DateTime resendAvailableAt;
}

class OtpVerificationResult {
  const OtpVerificationResult(this.status);

  final OtpVerificationStatus status;

  bool get isVerified => status == OtpVerificationStatus.verified;
}

class AuthOtpService {
  AuthOtpService({Random? random}) : _random = random ?? Random.secure();

  static const Duration otpLifetime = Duration(minutes: 5);
  static const Duration resendCooldown = Duration(seconds: 60);
  static const int maxAttempts = 5;

  final Random _random;
  final Map<String, _LocalOtpRecord> _records = {};

  Future<OtpSendResult> sendOtp(String normalizedPhoneNumber) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();
    final otpId = 'otp_${now.microsecondsSinceEpoch}';
    final code = (_random.nextInt(900000) + 100000).toString();
    final record = _LocalOtpRecord(
      otpId: otpId,
      normalizedPhoneNumber: normalizedPhoneNumber,
      code: code,
      expiresAt: now.add(otpLifetime),
      resendAvailableAt: now.add(resendCooldown),
    );
    _records[otpId] = record;
    return OtpSendResult(
      otpId: otpId,
      expiresAt: record.expiresAt,
      resendAvailableAt: record.resendAvailableAt,
    );
  }

  Future<OtpVerificationResult> verifyOtp({
    required String otpId,
    required String code,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final record = _records[otpId];
    if (record == null || DateTime.now().isAfter(record.expiresAt)) {
      _records.remove(otpId);
      return const OtpVerificationResult(OtpVerificationStatus.expired);
    }
    if (record.attemptCount >= maxAttempts) {
      return const OtpVerificationResult(OtpVerificationStatus.tooManyAttempts);
    }
    record.attemptCount++;
    if (record.code != code.trim()) {
      return const OtpVerificationResult(OtpVerificationStatus.invalid);
    }
    record.verifiedAt = DateTime.now();
    return const OtpVerificationResult(OtpVerificationStatus.verified);
  }

  Future<OtpSendResult> resendOtp(String normalizedPhoneNumber) {
    clearOtpForPhone(normalizedPhoneNumber);
    return sendOtp(normalizedPhoneNumber);
  }

  void clearOtp(String otpId) {
    _records.remove(otpId);
  }

  void clearOtpForPhone(String normalizedPhoneNumber) {
    _records.removeWhere(
      (_, record) => record.normalizedPhoneNumber == normalizedPhoneNumber,
    );
  }

  String? debugCodeForOtp(String otpId) => _records[otpId]?.code;

  void expireOtpForTesting(String otpId) {
    final record = _records[otpId];
    if (record != null) {
      record.expiresAt = DateTime.now().subtract(const Duration(seconds: 1));
    }
  }
}

class _LocalOtpRecord {
  _LocalOtpRecord({
    required this.otpId,
    required this.normalizedPhoneNumber,
    required this.code,
    required this.expiresAt,
    required this.resendAvailableAt,
  });

  final String otpId;
  final String normalizedPhoneNumber;
  final String code;
  DateTime expiresAt;
  final DateTime resendAvailableAt;
  int attemptCount = 0;
  DateTime? verifiedAt;
}
