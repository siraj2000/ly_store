import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/validators.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the terms to continue')),
      );
      return;
    }
    final success = await context.read<AuthController>().register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _confirmPasswordController.text.trim(),
    );
    if (!mounted) return;
    if (success) {
      final authController = context.read<AuthController>();
      Navigator.pushNamedAndRemoveUntil(
        context,
        authController.landingRoute,
        (_) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: const AppHeader(title: 'Create Account'),
      body: Consumer<AuthController>(
        builder: (context, authController, _) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            children: [
              const AuthHero(
                title: 'Create your account',
                subtitle:
                    'Unlock coupons, order tracking, and faster checkout with your StyleHub profile.',
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
                      const SizedBox(height: AppSizes.md),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surfaceSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: CheckboxListTile(
                          value: _acceptedTerms,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) =>
                              setState(() => _acceptedTerms = value ?? false),
                          title: const Text(
                            'I agree to the Terms and Privacy Policy',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      if (authController.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            authController.errorMessage!,
                            style: TextStyle(color: colors.discount),
                          ),
                        ),
                      const SizedBox(height: 14),
                      AppButton(
                        text: authController.isLoading
                            ? 'Creating...'
                            : 'Create Account',
                        onPressed: authController.isLoading ? null : _submit,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
