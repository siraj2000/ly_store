import 'package:flutter/material.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../widgets/common/app_header.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppHeader(title: 'Order Success'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 42,
                child: Icon(Icons.check_rounded, size: 44),
              ),
              const SizedBox(height: AppSizes.lg),
              Text(
                'Order confirmed',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSizes.md),
              Text('Order number: $orderId'),
              const Text('Estimated delivery: 5 to 7 business days'),
              const SizedBox(height: AppSizes.xl),
              AppButton(
                text: 'View Order',
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.orderDetails,
                  arguments: orderId,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              AppButton.secondary(
                text: 'Continue Shopping',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
