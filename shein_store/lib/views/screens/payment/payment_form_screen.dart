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
  const PaymentFormScreen({super.key, this.paymentMethodId});

  final String? paymentMethodId;

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _brand = TextEditingController();
  final _lastFour = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _didLoadMethod = false;
  PaymentMethodModel? _editingMethod;

  @override
  void dispose() {
    _brand.dispose();
    _lastFour.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    _loadMethodIfNeeded(context);
    final isEditing = _editingMethod != null;

    return Scaffold(
      appBar: AppHeader(
        title: isEditing
            ? context.tr('Edit Card', 'تعديل البطاقة')
            : context.tr('Add Card', 'إضافة بطاقة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: _brand,
                  label: context.tr('Card brand', 'نوع البطاقة'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.tr('Required field', 'حقل مطلوب');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _lastFour,
                  label: context.tr('Last 4 digits', 'آخر 4 أرقام'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (!RegExp(r'^\d{4}$').hasMatch(text)) {
                      return context.tr(
                        'Enter exactly 4 digits',
                        'أدخل 4 أرقام بالضبط',
                      );
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.lg),
                AppButton(
                  text: context.tr('Save Card', 'حفظ البطاقة'),
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    final method = PaymentMethodModel(
                      id:
                          _editingMethod?.id ??
                          'pay_${DateTime.now().millisecondsSinceEpoch}',
                      brand: _brand.text.trim(),
                      maskedNumber: '**** ${_lastFour.text.trim()}',
                      token:
                          _editingMethod?.token ??
                          'tok_${DateTime.now().millisecondsSinceEpoch}',
                      isDefault: _editingMethod?.isDefault ?? false,
                    );
                    final profile = context.read<ProfileController>();
                    if (isEditing) {
                      profile.updatePaymentMethod(method);
                    } else {
                      profile.addPaymentMethod(method);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? context.tr('Card updated', 'تم تحديث البطاقة')
                              : context.tr('Card added', 'تم إضافة البطاقة'),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadMethodIfNeeded(BuildContext context) {
    if (_didLoadMethod) {
      return;
    }
    _didLoadMethod = true;
    final methodId = widget.paymentMethodId;
    if (methodId == null || methodId.isEmpty) {
      return;
    }
    final user = context.read<ProfileController>().user;
    final matches = user?.paymentMethods.where((item) => item.id == methodId);
    if (matches == null || matches.isEmpty) {
      return;
    }
    final method = matches.first;
    _editingMethod = method;
    _brand.text = method.brand;
    _lastFour.text = method.maskedNumber.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
