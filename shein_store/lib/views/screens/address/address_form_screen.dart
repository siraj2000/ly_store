import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../models/address_model.dart';
import '../../widgets/common/app_header.dart';

class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({super.key});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController(text: 'United States');
  final _city = TextEditingController();
  final _region = TextEditingController();
  final _street = TextEditingController();
  final _postal = TextEditingController();
  bool _isDefault = false;

  @override
  void dispose() {
    _fullName.dispose();
    _phone.dispose();
    _country.dispose();
    _city.dispose();
    _region.dispose();
    _street.dispose();
    _postal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      appBar: AppHeader(title: context.tr('Address Form', 'نموذج العنوان')),
      body: SingleChildScrollView(
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
              children: [
                AppTextField(
                  controller: _fullName,
                  label: context.tr('Full name', 'الاسم الكامل'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _phone,
                  label: context.tr('Phone', 'الهاتف'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _country,
                  label: context.tr('Country', 'الدولة'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _city,
                  label: context.tr('City', 'المدينة'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _region,
                  label: context.tr('Region', 'المنطقة'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _street,
                  label: context.tr('Street address', 'عنوان الشارع'),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _postal,
                  label: context.tr('Postal code', 'الرمز البريدي'),
                ),
                const SizedBox(height: AppSizes.sm),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: SwitchListTile(
                    value: _isDefault,
                    title: Text(context.tr('Set as default', 'تعيين كافتراضي')),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    onChanged: (value) => setState(() => _isDefault = value),
                  ),
                ),
                const SizedBox(height: AppSizes.lg),
                AppButton(
                  text: context.tr('Save Address', 'حفظ العنوان'),
                  onPressed: () {
                    context.read<ProfileController>().addAddress(
                      AddressModel(
                        id: 'address_${DateTime.now().millisecondsSinceEpoch}',
                        fullName: _fullName.text.trim(),
                        phone: _phone.text.trim(),
                        country: _country.text.trim(),
                        city: _city.text.trim(),
                        region: _region.text.trim(),
                        streetAddress: _street.text.trim(),
                        postalCode: _postal.text.trim(),
                        isDefault: _isDefault,
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
}
