import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_motion.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _wordmarkOpacity;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppMotion.slow,
    )..forward();
    _logoOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0, 0.75, curve: AppMotion.standard),
    );
    _logoScale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.85, curve: AppMotion.standard),
      ),
    );
    _wordmarkOpacity = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.35, 1, curve: AppMotion.standard),
    );
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: foreground.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: foreground,
                      size: 42,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: _wordmarkOpacity,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.16),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(
                            0.35,
                            1,
                            curve: AppMotion.standard,
                          ),
                        ),
                      ),
                  child: Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              CircularProgressIndicator(color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
