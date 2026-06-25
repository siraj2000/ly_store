import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../controllers/admin_seller_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/admin_seller_localization_helper.dart';
import '../../../core/helpers/business_activity_helper.dart';
import '../../../core/helpers/catalog_localization_helper.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../widgets/common/app_header.dart';

class AdminSellerFormScreen extends StatefulWidget {
  const AdminSellerFormScreen({super.key, this.sellerId});

  final String? sellerId;

  @override
  State<AdminSellerFormScreen> createState() => _AdminSellerFormScreenState();
}

class _AdminSellerFormScreenState extends State<AdminSellerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sellerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _storeNameArController = TextEditingController();
  final _storeNameEnController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeAddressArController = TextEditingController();
  final _storeAddressEnController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _storeDescriptionArController = TextEditingController();
  final _storeDescriptionEnController = TextEditingController();

  SellerAccountStatus _accountStatus = SellerAccountStatus.active;
  String _businessActivityType = businessActivityTypeIds.first;
  bool _storeActive = true;
  bool _verifiedStore = false;
  bool _featuredStore = false;
  bool _vacationMode = false;
  double _commissionPercentage = 12;
  final Set<String> _allowedCategoryIds = <String>{};
  bool _didPrefill = false;

  bool get _isEditing => widget.sellerId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrefill || !_isEditing) {
      return;
    }
    final seller = context.read<AdminSellerController>().getSellerDetails(
      widget.sellerId!,
    );
    if (seller != null) {
      _prefillSeller(seller);
      _didPrefill = true;
    }
  }

  @override
  void dispose() {
    _sellerNameController.dispose();
    _emailController.dispose();
    _sellerPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _storeNameArController.dispose();
    _storeNameEnController.dispose();
    _storePhoneController.dispose();
    _storeAddressArController.dispose();
    _storeAddressEnController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _storeDescriptionArController.dispose();
    _storeDescriptionEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminSellerController>(
      builder: (context, controller, _) {
        if (_isEditing && !_didPrefill) {
          final seller = controller.getSellerDetails(widget.sellerId!);
          if (seller != null) {
            _prefillSeller(seller);
            _didPrefill = true;
          }
        }
        final colors = context.appColors;
        final l10n = context.l10n;
        final layoutWide = MediaQuery.sizeOf(context).width >= 920;

        return Scaffold(
          appBar: AppHeader(
            title: _isEditing ? l10n.adminEditSeller : l10n.adminAddSeller,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 32),
              children: [
                if (controller.errorMessage != null)
                  _InlineMessage(
                    message: localizedAdminSellerMessage(
                      context,
                      controller.errorMessage!,
                    ),
                    color: colors.discount,
                  ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (!layoutWide) {
                      return Column(
                        children: _buildSections(context, controller),
                      );
                    }
                    final sections = _buildSections(context, controller);
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: sections
                          .map(
                            (section) => SizedBox(
                              width: (constraints.maxWidth - 16) / 2,
                              child: section,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => _submit(viewDetailsAfter: false),
                      child: Text(
                        _isEditing ? l10n.commonSave : l10n.adminCreateSeller,
                      ),
                    ),
                    if (!_isEditing)
                      FilledButton.tonal(
                        onPressed: controller.isLoading
                            ? null
                            : () => _submit(viewDetailsAfter: true),
                        child: Text(l10n.adminCreateSellerAndView),
                      ),
                    OutlinedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(l10n.commonCancel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildSections(
    BuildContext context,
    AdminSellerController controller,
  ) {
    return [
      _SectionCard(
        title: context.l10n.adminSellerAccountInformation,
        child: Column(
          children: [
            AppTextField(
              controller: _sellerNameController,
              label: context.l10n.adminSellerFullName,
            ),
            _ErrorText(_fieldError(controller, 'sellerName')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _emailController,
              label: context.l10n.adminSellerEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            _ErrorText(_fieldError(controller, 'email')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _sellerPhoneController,
              label: context.l10n.adminSellerPhone,
              keyboardType: TextInputType.phone,
            ),
            _ErrorText(_fieldError(controller, 'sellerPhone')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _passwordController,
                    label: context.l10n.adminPassword,
                    obscureText: true,
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    final generated = controller.generatePassword();
                    _passwordController.text = generated;
                    _confirmPasswordController.text = generated;
                    setState(() {});
                  },
                  child: Text(context.l10n.adminGeneratePassword),
                ),
              ],
            ),
            _ErrorText(_fieldError(controller, 'password')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _confirmPasswordController,
              label: context.l10n.adminConfirmPassword,
              obscureText: true,
            ),
            _ErrorText(_fieldError(controller, 'confirmPassword')),
            const SizedBox(height: 12),
            DropdownButtonFormField<SellerAccountStatus>(
              initialValue: _accountStatus,
              decoration: InputDecoration(
                labelText: context.l10n.adminAccountStatus,
              ),
              items: SellerAccountStatus.values
                  .map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        localizedSellerAccountStatus(context, status),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _accountStatus = value);
              },
            ),
          ],
        ),
      ),
      _SectionCard(
        title: context.l10n.adminStoreInformation,
        child: Column(
          children: [
            AppTextField(
              controller: _storeNameArController,
              label: context.l10n.adminStoreNameAr,
              textDirection: TextDirection.rtl,
            ),
            _ErrorText(_fieldError(controller, 'storeNameAr')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _storeNameEnController,
              label: context.l10n.adminStoreNameEn,
            ),
            _ErrorText(_fieldError(controller, 'storeNameEn')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _storePhoneController,
              label: context.l10n.adminStorePhone,
              keyboardType: TextInputType.phone,
            ),
            _ErrorText(_fieldError(controller, 'storePhone')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _storeAddressArController,
              label: context.l10n.adminStoreAddressAr,
              textDirection: TextDirection.rtl,
              maxLines: 2,
            ),
            _ErrorText(_fieldError(controller, 'storeAddressAr')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _storeAddressEnController,
              label: context.l10n.adminStoreAddressEn,
              maxLines: 2,
            ),
            _ErrorText(_fieldError(controller, 'storeAddressEn')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _cityController,
              label: context.l10n.adminCity,
            ),
            _ErrorText(_fieldError(controller, 'city')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _countryController,
              label: context.l10n.adminCountry,
            ),
            _ErrorText(_fieldError(controller, 'countryCode')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _businessActivityType,
              decoration: InputDecoration(
                labelText: context.l10n.adminBusinessActivity,
              ),
              items: businessActivityTypeIds
                  .map(
                    (id) => DropdownMenuItem(
                      value: id,
                      child: Text(localizedBusinessActivity(context, id)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _businessActivityType = value);
              },
            ),
            _ErrorText(_fieldError(controller, 'businessActivityType')),
            const SizedBox(height: 12),
            AppTextField(
              controller: _storeDescriptionArController,
              label: context.l10n.adminStoreDescriptionAr,
              textDirection: TextDirection.rtl,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _storeDescriptionEnController,
              label: context.l10n.adminStoreDescriptionEn,
              maxLines: 3,
            ),
          ],
        ),
      ),
      _SectionCard(
        title: context.l10n.adminStoreSettings,
        child: Column(
          children: [
            SwitchListTile.adaptive(
              value: _storeActive,
              onChanged: (value) => setState(() => _storeActive = value),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.adminStoreActive),
            ),
            SwitchListTile.adaptive(
              value: _verifiedStore,
              onChanged: (value) => setState(() => _verifiedStore = value),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.adminVerifiedStore),
            ),
            SwitchListTile.adaptive(
              value: _featuredStore,
              onChanged: (value) => setState(() => _featuredStore = value),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.adminFeaturedStore),
            ),
            SwitchListTile.adaptive(
              value: _vacationMode,
              onChanged: (value) => setState(() => _vacationMode = value),
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.adminVacationMode),
            ),
            const SizedBox(height: 12),
            Slider(
              value: _commissionPercentage,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${_commissionPercentage.round()}%',
              onChanged: (value) =>
                  setState(() => _commissionPercentage = value),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${context.l10n.adminCommissionPercentage}: ${_commissionPercentage.toStringAsFixed(0)}%',
              ),
            ),
            _ErrorText(_fieldError(controller, 'commissionPercentage')),
            const SizedBox(height: 12),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                context.l10n.adminAllowedCategories,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.categories
                  .map(
                    (category) => FilterChip(
                      selected: _allowedCategoryIds.contains(category.id),
                      label: Text(
                        localizedCategoryName(context, category.name),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _allowedCategoryIds.add(category.id);
                          } else {
                            _allowedCategoryIds.remove(category.id);
                          }
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    ];
  }

  Future<void> _submit({required bool viewDetailsAfter}) async {
    final controller = context.read<AdminSellerController>();
    final data = AdminSellerFormData(
      sellerName: _sellerNameController.text,
      email: _emailController.text,
      sellerPhone: _sellerPhoneController.text,
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      accountStatus: _accountStatus,
      storeNameAr: _storeNameArController.text,
      storeNameEn: _storeNameEnController.text,
      storePhone: _storePhoneController.text,
      storeAddressAr: _storeAddressArController.text,
      storeAddressEn: _storeAddressEnController.text,
      city: _cityController.text,
      countryCode: _countryController.text,
      businessActivityType: _businessActivityType,
      storeDescriptionAr: _storeDescriptionArController.text,
      storeDescriptionEn: _storeDescriptionEnController.text,
      storeActive: _storeActive,
      verifiedStore: _verifiedStore,
      featuredStore: _featuredStore,
      vacationMode: _vacationMode,
      commissionPercentage: _commissionPercentage,
      allowedCategoryIds: _allowedCategoryIds.toList(),
      suspensionReason: _accountStatus == SellerAccountStatus.suspended
          ? context.l10n.adminSellerSuspended
          : '',
    );

    if (_isEditing) {
      final success = await controller.updateSeller(widget.sellerId!, data);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizedAdminSellerMessage(
                context,
                controller.successMessage ?? 'adminSellerUpdatedSuccessfully',
              ),
            ),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    final created = await controller.createSellerWithStore(data);
    if (!mounted || created == null) {
      return;
    }
    final openDetails = await _showCreatedDialog(created);
    if (!mounted) return;
    if (viewDetailsAfter || openDetails) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.adminSellerDetails,
        arguments: created.user.id,
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<bool> _showCreatedDialog(AdminSellerCredentialsResult created) async {
    final l10n = context.l10n;
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.adminSellerCreatedSuccessfully),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l10n.adminSellerFullName}: ${created.user.name}'),
              Text(
                '${l10n.adminStoreLabel}: ${created.store.nameText.valueFor(Localizations.localeOf(context))}',
              ),
              Text('${l10n.adminSellerEmail}: ${created.user.email}'),
              Text('${l10n.adminPassword}: ${created.password}'),
              Text('${l10n.adminRoleLabel}: ${l10n.adminRoleSeller}'),
              const SizedBox(height: 12),
              Text(
                l10n.adminDemoPasswordNotice,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text:
                        '${created.user.email}\n${created.password}\n${l10n.adminRoleSeller}',
                  ),
                );
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(l10n.adminCredentialsCopied)),
                );
              },
              child: Text(l10n.adminCopyCredentials),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(l10n.adminOpenSellerDetails),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.commonClose),
            ),
          ],
        );
      },
    );
    return shouldOpen ?? false;
  }

  String? _fieldError(AdminSellerController controller, String key) {
    final errorKey = controller.validationErrors[key];
    if (errorKey == null) {
      return null;
    }
    return localizedAdminSellerMessage(context, errorKey);
  }

  void _prefillSeller(AdminSellerSummary seller) {
    final store = seller.store;
    _sellerNameController.text = seller.user.name;
    _emailController.text = seller.user.email;
    _sellerPhoneController.text = seller.user.phone;
    _passwordController.text = seller.user.mockPassword;
    _confirmPasswordController.text = seller.user.mockPassword;
    _storeNameArController.text =
        store?.nameText.ar ?? seller.user.storeNameText.ar;
    _storeNameEnController.text =
        store?.nameText.en ?? seller.user.storeNameText.en;
    _storePhoneController.text = store?.storePhone ?? seller.user.phone;
    _storeAddressArController.text = store?.addressText.ar ?? '';
    _storeAddressEnController.text = store?.addressText.en ?? '';
    _cityController.text = store?.city ?? '';
    _countryController.text = store?.countryCode ?? '';
    _storeDescriptionArController.text =
        store?.descriptionText.ar ?? seller.user.storeDescriptionText.ar;
    _storeDescriptionEnController.text =
        store?.descriptionText.en ?? seller.user.storeDescriptionText.en;
    _accountStatus = SellerAccountStatusX.fromId(seller.user.sellerStatus);
    _businessActivityType = store?.businessActivityType ?? 'mixed';
    _storeActive = store?.isActive ?? seller.user.isActive;
    _verifiedStore = store?.isVerified ?? false;
    _featuredStore = store?.isFeatured ?? false;
    _vacationMode = store?.vacationMode ?? false;
    _commissionPercentage = store?.commissionPercentage ?? 12;
    _allowedCategoryIds
      ..clear()
      ..addAll(store?.allowedCategoryIds ?? const []);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          message!,
          style: TextStyle(color: context.appColors.discount, fontSize: 12),
        ),
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.color});

  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
