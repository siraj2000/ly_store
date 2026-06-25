import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authController = context.read<AuthController>();
      await authController.initializeSession();
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        authController.isFirstLaunch
            ? AppRoutes.onboarding
            : authController.landingRoute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = context.isDarkMode ? colors.primaryText : colors.surface;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: context.isDarkMode
                ? const [
                    Color(0xFF0F1722),
                    Color(0xFF1E2B3C),
                    Color(0xFF30465F),
                  ]
                : [AppColors.ink, AppColors.rose, AppColors.blush],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  color: foreground,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
