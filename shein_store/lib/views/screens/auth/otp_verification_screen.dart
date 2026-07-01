import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/auth_error_localization_helper.dart';
import '../../../core/helpers/phone_number_normalizer.dart';
import '../../../core/widgets/app_button.dart';
import '../../widgets/common/app_header.dart';
import 'login_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  Timer? _timer;
  int _secondsUntilResend = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsUntilResend = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsUntilResend <= 1) {
        timer.cancel();
        setState(() => _secondsUntilResend = 0);
        return;
      }
      setState(() => _secondsUntilResend--);
    });
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthController>().verifyOtp(
      _otpController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.createPassword);
    }
  }

  Future<void> _resend() async {
    final success = await context.read<AuthController>().resendOtp();
    if (!mounted) return;
    if (success) {
      _otpController.clear();
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Verification code sent if the number is valid',
              'سيتم إرسال رمز التحقق إذا كان الرقم صحيحاً',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final authController = context.watch<AuthController>();
    final session = authController.pendingRegistrationSession;

    if (session == null) {
      return Scaffold(
        appBar: AppHeader(
          title: context.tr('Verify your phone', 'تحقق من رقم الهاتف'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sms_failed_outlined, size: 52),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    'Registration session expired. Please start again.',
                    'انتهت جلسة التسجيل. الرجاء البدء من جديد.',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: context.tr('Create account', 'إنشاء حساب'),
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.register,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        title: context.tr('Verify your phone', 'تحقق من رقم الهاتف'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              AuthHero(
                title: context.tr('Verify your phone', 'تحقق من رقم الهاتف'),
                subtitle: context.tr(
                  'Enter the 6-digit verification code to activate your customer account.',
                  'أدخل رمز التحقق المكون من 6 أرقام لتفعيل حساب العميل.',
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: colors.border),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.tr(
                          'We sent a verification code to',
                          'أرسلنا رمز التحقق إلى',
                        ),
                        style: TextStyle(color: colors.secondaryText),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceSoft,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.phone_iphone, color: colors.primaryText),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                PhoneNumberNormalizer.mask(
                                  session.normalizedPhoneNumber,
                                ),
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: colors.primaryText,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 8,
                          color: colors.primaryText,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          labelText: context.tr('Enter OTP', 'أدخل رمز التحقق'),
                          hintText: '000000',
                        ),
                        validator: (value) {
                          final code = (value ?? '').trim();
                          if (code.isEmpty) {
                            return context.tr(
                              'OTP is required',
                              'رمز التحقق مطلوب',
                            );
                          }
                          if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                            return context.tr(
                              'OTP must be 6 digits',
                              'رمز التحقق يجب أن يتكون من 6 أرقام',
                            );
                          }
                          return null;
                        },
                      ),
                      if (authController.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          localizedAuthError(
                            context,
                            authController.errorMessage,
                          ),
                          style: TextStyle(
                            color: colors.discount,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      AppButton(
                        text: authController.isVerifyingOtp
                            ? context.tr('Verifying...', 'جارٍ التحقق...')
                            : context.tr('Verify', 'تحقق'),
                        onPressed: authController.isVerifyingOtp
                            ? null
                            : _verify,
                      ),
                      const SizedBox(height: 10),
                      AppButton.secondary(
                        text: _secondsUntilResend == 0
                            ? context.tr('Resend code', 'إعادة إرسال الرمز')
                            : context.tr(
                                'Resend available in $_secondsUntilResend s',
                                'إعادة الإرسال متاحة خلال $_secondsUntilResend ث',
                              ),
                        onPressed:
                            _secondsUntilResend == 0 &&
                                !authController.isSendingOtp
                            ? _resend
                            : null,
                      ),
                      TextButton(
                        onPressed: authController.isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.register,
                              ),
                        child: Text(
                          context.tr('Change phone number', 'تغيير رقم الهاتف'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
