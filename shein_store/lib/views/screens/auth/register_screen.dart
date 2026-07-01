import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/auth_error_localization_helper.dart';
import '../../../core/helpers/phone_number_normalizer.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../widgets/common/app_header.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context
        .read<AuthController>()
        .startCustomerRegistration(
          _fullNameController.text,
          _phoneController.text,
        );
    if (!mounted) return;
    if (success) {
      Navigator.pushNamed(context, AppRoutes.otpVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(title: context.tr('Create account', 'إنشاء حساب')),
      body: Consumer<AuthController>(
        builder: (context, authController, _) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                AuthHero(
                  title: context.tr('Start with your phone', 'ابدأ برقم هاتفك'),
                  subtitle: context.tr(
                    'We will verify your phone first, then you can create a password for secure login.',
                    'سنتحقق من رقم هاتفك أولاً، ثم يمكنك إنشاء رمز سري لتسجيل الدخول بأمان.',
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
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
                        AppTextField(
                          controller: _fullNameController,
                          label: context.tr('Full name', 'الاسم الكامل'),
                          hint: context.tr(
                            'Enter your full name',
                            'أدخل الاسم الكامل',
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            final clean = (value ?? '').trim().replaceAll(
                              RegExp(r'\s+'),
                              ' ',
                            );
                            if (clean.isEmpty) {
                              return context.tr(
                                'Full name is required',
                                'الاسم الكامل مطلوب',
                              );
                            }
                            if (clean
                                    .split(' ')
                                    .where((part) => part.isNotEmpty)
                                    .length <
                                2) {
                              return context.tr(
                                'Please enter your first and last name',
                                'الرجاء إدخال الاسم الأول واسم العائلة',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSizes.md),
                        AppTextField(
                          controller: _phoneController,
                          label: context.tr('Phone number', 'رقم الهاتف'),
                          hint: context.tr(
                            'Example: 0912345678',
                            'مثال: 0912345678',
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if ((value ?? '').trim().isEmpty) {
                              return context.tr(
                                'Phone number is required',
                                'رقم الهاتف مطلوب',
                              );
                            }
                            if (!PhoneNumberNormalizer.isValid(value ?? '')) {
                              return context.tr(
                                'Invalid phone number',
                                'رقم الهاتف غير صحيح',
                              );
                            }
                            return null;
                          },
                        ),
                        if (authController.errorMessage != null) ...[
                          const SizedBox(height: 12),
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
                          if (authController.errorMessage ==
                              'phone_already_registered')
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                onPressed: () => Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                ),
                                child: Text(
                                  context.tr(
                                    'Login instead',
                                    'تسجيل الدخول بدلاً من ذلك',
                                  ),
                                ),
                              ),
                            ),
                        ],
                        const SizedBox(height: AppSizes.lg),
                        AppButton(
                          text: authController.isSendingOtp
                              ? context.tr(
                                  'Preparing code...',
                                  'جارٍ تجهيز الرمز...',
                                )
                              : context.tr('Continue', 'متابعة'),
                          onPressed: authController.isSendingOtp
                              ? null
                              : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      context.tr('Already have an account?', 'لديك حساب؟'),
                      style: TextStyle(color: colors.secondaryText),
                    ),
                    TextButton(
                      onPressed: authController.isLoading
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                      child: Text(context.tr('Login', 'تسجيل الدخول')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
