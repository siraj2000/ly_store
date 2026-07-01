import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../widgets/common/app_header.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final colors = context.appColors;
    return Scaffold(
      appBar: AppHeader(
        title: context.tr('Reset Password', 'إعادة تعيين كلمة المرور'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          children: [
            AuthHero(
              title: context.tr('Recover your account', 'استعادة حسابك'),
              subtitle: context.tr(
                'Enter your email or phone, verify the code, and set a new password.',
                'أدخل بريدك الإلكتروني أو هاتفك، ثم تحقق من الرمز وحدد كلمة مرور جديدة.',
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.border),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    AppTextField(
                      controller: _accountController,
                      label: context.tr(
                        'Email or phone',
                        'البريد الإلكتروني أو الهاتف',
                      ),
                      validator: Validators.emailOrPhone,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppButton.secondary(
                      text: context.tr('Send code', 'إرسال الرمز'),
                      onPressed: () async {
                        final sent = await authController.forgotPassword(
                          _accountController.text.trim(),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              sent
                                  ? context.tr(
                                      'Verification code sent if the account is valid.',
                                      'سيتم إرسال رمز التحقق إذا كان الحساب صحيحاً.',
                                    )
                                  : _localizedResetError(
                                      context,
                                      authController.errorMessage,
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _codeController,
                      label: context.tr('Verification code', 'رمز التحقق'),
                      validator: (value) => Validators.requiredField(
                        value,
                        label: context.tr('Code', 'الرمز'),
                      ),
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _passwordController,
                      label: context.tr('New password', 'كلمة المرور الجديدة'),
                      obscureText: true,
                      validator: Validators.password,
                    ),
                    const SizedBox(height: AppSizes.md),
                    AppTextField(
                      controller: _confirmPasswordController,
                      label: context.tr(
                        'Confirm password',
                        'تأكيد كلمة المرور',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return context.tr(
                            'Passwords do not match',
                            'كلمتا المرور غير متطابقتين',
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.lg),
                    AppButton(
                      text: context.tr(
                        'Reset password',
                        'إعادة تعيين كلمة المرور',
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final reset = await authController.resetPassword(
                          emailOrPhone: _accountController.text.trim(),
                          code: _codeController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                        if (!context.mounted) return;
                        if (!reset) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _localizedResetError(
                                  context,
                                  authController.errorMessage,
                                ),
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              context.tr(
                                'Password reset complete',
                                'اكتملت إعادة تعيين كلمة المرور',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _localizedResetError(BuildContext context, String? code) {
    switch (code) {
      case 'account_not_found':
        return context.tr(
          'No account found for this email or phone.',
          'لم نجد حسابا بهذا البريد أو الهاتف.',
        );
      case 'reset_code_required':
        return context.tr(
          'Please send a reset code first.',
          'يرجى إرسال رمز إعادة التعيين أولا.',
        );
      case 'reset_code_expired':
        return context.tr(
          'The reset code expired. Send a new code.',
          'انتهت صلاحية رمز إعادة التعيين. أرسل رمزا جديدا.',
        );
      case 'invalid_reset_code':
        return context.tr(
          'The verification code is not correct.',
          'رمز التحقق غير صحيح.',
        );
      case 'weak_password':
        return context.tr(
          'Password must be at least 6 characters.',
          'يجب أن تكون كلمة المرور 6 أحرف على الأقل.',
        );
      default:
        return context.tr(
          'Could not reset password. Please try again.',
          'تعذرت إعادة تعيين كلمة المرور. حاول مرة أخرى.',
        );
    }
  }
}
