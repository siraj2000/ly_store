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
  const AddressFormScreen({super.key, this.addressId});

  final String? addressId;

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
  bool _didLoadAddress = false;
  AddressModel? _editingAddress;

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
    _loadAddressIfNeeded(context);
    final isEditing = _editingAddress != null;

    return Scaffold(
      appBar: AppHeader(
        title: isEditing
            ? context.tr('Edit Address', 'تعديل العنوان')
            : context.tr('Add Address', 'إضافة عنوان'),
      ),
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
                  validator: _requiredValidator(context),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _phone,
                  label: context.tr('Phone', 'الهاتف'),
                  keyboardType: TextInputType.phone,
                  validator: _requiredValidator(context),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _country,
                  label: context.tr('Country', 'الدولة'),
                  validator: _requiredValidator(context),
                ),
                const SizedBox(height: AppSizes.md),
                AppTextField(
                  controller: _city,
                  label: context.tr('City', 'المدينة'),
                  validator: _requiredValidator(context),
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
                  validator: _requiredValidator(context),
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
                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    final address = AddressModel(
                      id:
                          _editingAddress?.id ??
                          'address_${DateTime.now().millisecondsSinceEpoch}',
                      fullName: _fullName.text.trim(),
                      phone: _phone.text.trim(),
                      country: _country.text.trim(),
                      city: _city.text.trim(),
                      region: _region.text.trim(),
                      streetAddress: _street.text.trim(),
                      postalCode: _postal.text.trim(),
                      isDefault: _isDefault,
                    );
                    final profile = context.read<ProfileController>();
                    if (isEditing) {
                      profile.updateAddress(address);
                    } else {
                      profile.addAddress(address);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? context.tr(
                                  'Address updated',
                                  'تم تحديث العنوان',
                                )
                              : context.tr('Address added', 'تم إضافة العنوان'),
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

  String? Function(String?) _requiredValidator(BuildContext context) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return context.tr('Required field', 'حقل مطلوب');
      }
      return null;
    };
  }

  void _loadAddressIfNeeded(BuildContext context) {
    if (_didLoadAddress) {
      return;
    }
    _didLoadAddress = true;
    final addressId = widget.addressId;
    if (addressId == null || addressId.isEmpty) {
      return;
    }
    final user = context.read<ProfileController>().user;
    final matches = user?.addresses.where((item) => item.id == addressId);
    if (matches == null || matches.isEmpty) {
      return;
    }
    final address = matches.first;
    _editingAddress = address;
    _fullName.text = address.fullName;
    _phone.text = address.phone;
    _country.text = address.country;
    _city.text = address.city;
    _region.text = address.region;
    _street.text = address.streetAddress;
    _postal.text = address.postalCode;
    _isDefault = address.isDefault;
  }
}
