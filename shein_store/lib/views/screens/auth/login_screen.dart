import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/helpers/admin_seller_localization_helper.dart';
import '../../../core/utils/validators.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthController>().loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final authController = context.read<AuthController>();
      Navigator.pushNamedAndRemoveUntil(
        context,
        authController.landingRoute,
        (_) => false,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signed in successfully')));
    }
  }

  Future<void> _signInWithDemo(String email) async {
    _emailController.text = email;
    _passwordController.text = '123456';
    await _submit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: const AppHeader(title: 'Sign In'),
      body: Consumer<AuthController>(
        builder: (context, authController, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const AuthHero(
                title: 'Welcome back',
                subtitle:
                    'Track your orders, save favorites, and continue your shopping in one place.',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: 'Email or phone',
                        validator: Validators.emailOrPhone,
                      ),
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _passwordController,
                        label: 'Password',
                        obscureText: true,
                        validator: Validators.password,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.forgotPassword,
                          ),
                          child: const Text('Forgot password?'),
                        ),
                      ),
                      if (authController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: Text(
                            localizedAdminSellerMessage(
                              context,
                              authController.errorMessage!,
                            ),
                            style: TextStyle(color: colors.discount),
                          ),
                        ),
                      AppButton(
                        text: authController.isLoading
                            ? 'Signing In...'
                            : 'Sign In',
                        onPressed: authController.isLoading ? null : _submit,
                      ),
                      const SizedBox(height: 10),
                      AppButton.secondary(
                        text: 'Continue with Google',
                        icon: Icons.g_mobiledata,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Google mock sign-in'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      AppButton.secondary(
                        text: 'Continue with Facebook',
                        icon: Icons.facebook,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Facebook mock sign-in'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (kDebugMode) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MockRoleTitle(),
                      const SizedBox(height: 10),
                      const _MockAccountLine(
                        label: 'Customer',
                        value: 'customer@stylehub.com / 123456',
                      ),
                      const _MockAccountLine(
                        label: 'Seller',
                        value: 'seller@stylehub.com / 123456',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _DemoAccountButton(
                            label: 'Customer Demo',
                            onPressed: authController.isLoading
                                ? null
                                : () =>
                                      _signInWithDemo('customer@stylehub.com'),
                          ),
                          _DemoAccountButton(
                            label: 'Seller Demo',
                            onPressed: authController.isLoading
                                ? null
                                : () => _signInWithDemo('seller@stylehub.com'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.register),
                child: const Text('Create an account'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  'By continuing, you agree to the Terms and Privacy Policy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.secondaryText, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockRoleTitle extends StatelessWidget {
  const _MockRoleTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Mock role accounts',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: context.appColors.primaryText,
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
        : colors.surface.withValues(alpha: 0.74);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [const Color(0xFF1A2431), const Color(0xFF243446)]
              : [const Color(0xFF151515), const Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LY STORE',
            style: TextStyle(
              color: supportingColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: headlineColor,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: supportingColor,
              height: 1.35,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MockAccountLine extends StatelessWidget {
  const _MockAccountLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: colors.primaryText,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: colors.secondaryText)),
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
      ),
      child: Text(label),
    );
  }
}
