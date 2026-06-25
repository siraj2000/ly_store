import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/shop/guest_sign_in_banner.dart';
import '../cart/cart_screen.dart';
import '../category/category_screen.dart';
import '../profile/profile_screen.dart';
import '../shop/shop_screen.dart';
import '../trends/trends_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = const [
    ShopScreen(),
    CategoryScreen(),
    TrendsScreen(),
    CartScreen(isTabRoot: true),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) => Scaffold(
        body: IndexedStack(index: _currentIndex, children: _tabs),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentIndex == 0 && authController.isGuest)
              const GuestSignInBanner(),
            BottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          ],
        ),
      ),
    );
  }
}
