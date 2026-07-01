import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/auth_error_localization_helper.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../widgets/common/app_header.dart';
import 'login_screen.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authController = context.read<AuthController>();
    final success = await authController.createPasswordAndCompleteRegistration(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (!mounted) return;
    if (success) {
      _passwordController.clear();
      _confirmPasswordController.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        authController.landingRoute,
        (_) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Account created successfully', 'تم إنشاء الحساب بنجاح'),
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

    if (session == null || !session.otpVerified) {
      return Scaffold(
        appBar: AppHeader(
          title: context.tr('Create password', 'إنشاء رمز سري'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_clock_outlined, size: 52),
                const SizedBox(height: 12),
                Text(
                  context.tr(
                    'Verify your phone before creating a password.',
                    'تحقق من رقم الهاتف قبل إنشاء الرمز السري.',
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
      appBar: AppHeader(title: context.tr('Create password', 'إنشاء رمز سري')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              AuthHero(
                title: context.tr('Create password', 'إنشاء رمز سري'),
                subtitle: context.tr(
                  'One final step. Choose a secure password for your LY STORE account.',
                  'خطوة أخيرة. اختر رمزاً سرياً آمناً لحسابك في LY STORE.',
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
                        controller: _passwordController,
                        label: context.tr('Password', 'الرمز السري'),
                        obscureText: _obscurePassword,
                        suffix: IconButton(
                          tooltip: context.tr(
                            'Show password',
                            'إظهار الرمز السري',
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim().isEmpty) {
                            return context.tr(
                              'Password is required',
                              'الرمز السري مطلوب',
                            );
                          }
                          if ((value ?? '').trim().length < 6) {
                            return context.tr(
                              'Password must be at least 6 characters',
                              'يجب أن يكون الرمز السري 6 أحرف على الأقل',
                            );
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: context.tr(
                          'Confirm password',
                          'تأكيد الرمز السري',
                        ),
                        obscureText: _obscureConfirm,
                        suffix: IconButton(
                          tooltip: context.tr(
                            'Show password',
                            'إظهار الرمز السري',
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if ((value ?? '').trim() !=
                              _passwordController.text.trim()) {
                            return context.tr(
                              'Passwords do not match',
                              'الرمزان غير متطابقين',
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
                      ],
                      const SizedBox(height: AppSizes.lg),
                      AppButton(
                        text: authController.isCreatingPassword
                            ? context.tr(
                                'Creating account...',
                                'جارٍ إنشاء الحساب...',
                              )
                            : context.tr('Create account', 'إنشاء الحساب'),
                        onPressed: authController.isCreatingPassword
                            ? null
                            : _submit,
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
