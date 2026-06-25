import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/payment_method_model.dart';
import '../../widgets/common/app_header.dart';

class PaymentFormScreen extends StatefulWidget {
  const PaymentFormScreen({super.key});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _brand = TextEditingController();
  final _lastFour = TextEditingController();

  @override
  void dispose() {
    _brand.dispose();
    _lastFour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(title: context.tr('Payment Form', 'نموذج الدفع')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _brand,
                label: context.tr('Card brand', 'نوع البطاقة'),
              ),
              const SizedBox(height: AppSizes.md),
              AppTextField(
                controller: _lastFour,
                label: context.tr('Last 4 digits', 'آخر 4 أرقام'),
              ),
              const SizedBox(height: AppSizes.lg),
              AppButton(
                text: context.tr('Save Card', 'حفظ البطاقة'),
                onPressed: () {
                  context.read<ProfileController>().addPaymentMethod(
                    PaymentMethodModel(
                      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
                      brand: _brand.text.trim(),
                      maskedNumber: '**** ${_lastFour.text.trim()}',
                      token: 'tok_${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
