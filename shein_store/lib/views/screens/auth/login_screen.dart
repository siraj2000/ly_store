import 'package:flutter/foundation.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authController = context.read<AuthController>();
    final success = await authController.loginWithPhonePassword(
      _phoneController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        authController.landingRoute,
        (_) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr('Signed in successfully', 'تم تسجيل الدخول بنجاح'),
          ),
        ),
      );
    }
  }

  Future<void> _signInWithDemo(String phone) async {
    _phoneController.text = phone;
    _passwordController.text = '123456';
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(title: context.tr('Login', 'تسجيل الدخول')),
      body: Consumer<AuthController>(
        builder: (context, authController, _) => SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Column(
              children: [
                AuthHero(
                  title: context.tr('Welcome back', 'مرحباً بعودتك'),
                  subtitle: context.tr(
                    'Use your phone number to continue shopping, track orders, or manage your seller store.',
                    'استخدم رقم هاتفك لمتابعة التسوق أو تتبع الطلبات أو إدارة متجر البائع.',
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: colors.border),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primaryText.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _phoneController,
                          label: context.tr('Phone number', 'رقم الهاتف'),
                          hint: context.tr(
                            'Enter your phone number',
                            'أدخل رقم الهاتف',
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
                        const SizedBox(height: AppSizes.md),
                        AppTextField(
                          controller: _passwordController,
                          label: context.tr('Password', 'الرمز السري'),
                          hint: context.tr(
                            'Enter your password',
                            'أدخل الرمز السري',
                          ),
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
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            onPressed: authController.isLoading
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.forgotPassword,
                                  ),
                            child: Text(
                              context.tr(
                                'Forgot password?',
                                'نسيت الرمز السري؟',
                              ),
                            ),
                          ),
                        ),
                        if (authController.errorMessage != null) ...[
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
                              'phone_not_registered')
                            TextButton(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              ),
                              child: Text(
                                context.tr('Create account', 'إنشاء حساب'),
                              ),
                            ),
                          const SizedBox(height: 12),
                        ],
                        AppButton(
                          text: authController.isSubmitting
                              ? context.tr('Signing in...', 'جارٍ الدخول...')
                              : context.tr('Login', 'تسجيل الدخول'),
                          onPressed: authController.isSubmitting
                              ? null
                              : _submit,
                        ),
                        const SizedBox(height: 10),
                        AppButton.secondary(
                          text: context.tr(
                            'Continue as guest',
                            'المتابعة كزائر',
                          ),
                          icon: Icons.storefront_outlined,
                          onPressed: authController.isLoading
                              ? null
                              : () {
                                  authController.continueAsGuest();
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    AppRoutes.main,
                                    (_) => false,
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (kDebugMode) ...[
                  _DemoAccountPanel(
                    onCustomer: authController.isLoading
                        ? null
                        : () => _signInWithDemo('+1 555 0100'),
                    onSeller: authController.isLoading
                        ? null
                        : () => _signInWithDemo('+1 555 0111'),
                  ),
                  const SizedBox(height: 14),
                ],
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      context.tr('Do not have an account?', 'ليس لديك حساب؟'),
                      style: TextStyle(color: colors.secondaryText),
                    ),
                    TextButton(
                      onPressed: authController.isLoading
                          ? null
                          : () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                      child: Text(context.tr('Create account', 'إنشاء حساب')),
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

class AuthHero extends StatelessWidget {
  const AuthHero({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final headlineColor = context.isDarkMode
        ? colors.primaryText
        : colors.surface;
    final supportingColor = context.isDarkMode
        ? colors.secondaryText
        : colors.surface.withValues(alpha: 0.76);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [const Color(0xFF12202E), const Color(0xFF263B4F)]
              : [const Color(0xFF0F172A), const Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.storefront, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                'LY STORE',
                style: TextStyle(
                  color: supportingColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: TextStyle(
              color: headlineColor,
              fontSize: 27,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: supportingColor,
              height: 1.45,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoAccountPanel extends StatelessWidget {
  const _DemoAccountPanel({this.onCustomer, this.onSeller});

  final VoidCallback? onCustomer;
  final VoidCallback? onSeller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Local demo accounts', 'حسابات تجربة محلية'),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: colors.primaryText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DemoAccountButton(
                label: context.tr('Customer demo', 'تجربة العميل'),
                onPressed: onCustomer,
              ),
              _DemoAccountButton(
                label: context.tr('Seller demo', 'تجربة البائع'),
                onPressed: onSeller,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoAccountButton extends StatelessWidget {
  const _DemoAccountButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primaryText,
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label),
    );
  }
}
