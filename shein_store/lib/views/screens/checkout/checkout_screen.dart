import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/auth_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../controllers/profile_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/helpers/app_action_feedback.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/address_model.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/payment_method_model.dart';
import '../../widgets/common/app_header.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  String? _seededAddressId;
  bool _isSyncingForm = false;
  bool _hasManualDeliveryEdits = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _zoneController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    if (authController.isGuest) {
      return Scaffold(
        appBar: AppHeader(title: context.tr('Review & Pay', 'مراجعة ودفع')),
        body: AppEmptyState(
          title: context.tr('Sign in required', 'تسجيل الدخول مطلوب'),
          message: context.tr(
            'Sign in to add delivery details and place your order.',
            'سجل الدخول لإضافة بيانات التوصيل وإتمام الطلب.',
          ),
          action: AppButton(
            text: context.tr('Sign In', 'تسجيل الدخول'),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
            isExpanded: false,
          ),
        ),
      );
    }

    return Consumer3<CheckoutController, ProfileController, CartController>(
      builder: (context, checkoutController, profileController, cartController, _) {
        final user = profileController.user!;
        final colors = context.appColors;
        final selectedItems = cartController.selectedItems;
        final selectedAddress =
            checkoutController.selectedAddress ??
            (user.addresses.isNotEmpty ? user.addresses.first : null);
        final paymentOptions = _checkoutPaymentMethods(context);
        final paymentIds = paymentOptions.map((item) => item.id).toSet();
        final selectedPayment = checkoutController.paymentMethod;
        final totalPieces = selectedItems.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );

        _scheduleSeedFormFromAddress(selectedAddress, user.name);

        if (selectedPayment == null ||
            !paymentIds.contains(selectedPayment.id)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) {
              return;
            }
            context.read<CheckoutController>().setPaymentMethod(
              paymentOptions.first,
            );
          });
        }

        final previewAddress = _buildDeliveryAddress(
          user.name,
          selectedAddress,
        );

        return Scaffold(
          appBar: AppHeader(title: context.tr('Review & Pay', 'مراجعة ودفع')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.lg,
              AppSizes.md,
              AppSizes.lg,
              AppSizes.xl,
            ),
            children: [
              _CheckoutHeroCard(
                itemCount: selectedItems.length,
                totalPieces: totalPieces,
                total: cartController.calculateTotal(),
                address: previewAddress,
                paymentLabel: selectedPayment?.brand,
              ),
              _Section(
                icon: Icons.verified_user_outlined,
                title: context.tr(
                  'Delivery verification',
                  'التحقق من بيانات التوصيل',
                ),
                subtitle: context.tr(
                  'Enter the phone number that will receive the order and the home address for delivery.',
                  'أدخل رقم الهاتف الذي سيستلم الطلب وعنوان المنزل للتوصيل.',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.addresses.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colors.surfaceSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.bookmark_outline_rounded,
                                    color: colors.icon,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        context.tr(
                                          'Saved address available',
                                          'العنوان المحفوظ متاح',
                                        ),
                                        style: TextStyle(
                                          color: colors.primaryText,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        context.tr(
                                          'Use your saved details instantly, or edit the fields below.',
                                          'استخدم بياناتك المحفوظة مباشرة أو عدّل الحقول بالأسفل.',
                                        ),
                                        style: TextStyle(
                                          color: colors.secondaryText,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  checkoutController.setAddress(
                                    user.addresses.first,
                                  );
                                  _applyAddressToForm(
                                    user.addresses.first,
                                    user.name,
                                    seedId: user.addresses.first.id,
                                  );
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text(
                                  context.tr(
                                    'Use saved address',
                                    'استخدم العنوان المحفوظ',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    _DeliveryFormCard(
                      recipientController: _recipientController,
                      phoneController: _phoneController,
                      cityController: _cityController,
                      zoneController: _zoneController,
                      streetController: _streetController,
                      onChanged: _handleFormChanged,
                    ),
                  ],
                ),
              ),
              _Section(
                icon: Icons.payments_outlined,
                title: context.tr('Payment method', 'طريقة الدفع'),
                subtitle: context.tr(
                  'Choose the payment option the customer will use to complete the order.',
                  'اختر وسيلة الدفع التي سيستخدمها العميل لإكمال الطلب.',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.surfaceSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        context.tr(
                          'Cash is the fastest option. If you choose Pay Me, we will ask for the payment phone number before placing the order.',
                          'الدفع النقدي هو الخيار الأسرع. وإذا اخترت ادفع لي فسنطلب رقم هاتف الدفع قبل تنفيذ الطلب.',
                        ),
                        style: TextStyle(
                          color: colors.secondaryText,
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _PaymentMethodSelect(
                      selectedId:
                          selectedPayment?.id ?? paymentOptions.first.id,
                      methods: paymentOptions,
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        final method = paymentOptions.firstWhere(
                          (item) => item.id == value,
                        );
                        _handlePaymentSelection(
                          context,
                          checkoutController,
                          method,
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _SelectedPaymentPreview(
                      method: selectedPayment ?? paymentOptions.first,
                    ),
                    if (selectedPayment?.id == 'pay-me') ...[
                      const SizedBox(height: 12),
                      _PaymentInfoNote(
                        title: context.tr(
                          'Pay Me request ready',
                          'طلب Pay Me جاهز',
                        ),
                        subtitle: selectedPayment!.maskedNumber.trim().isEmpty
                            ? context.tr(
                                'Add the payment phone number from the Pay Me dialog.',
                                'أضف رقم هاتف الدفع من نافذة Pay Me.',
                              )
                            : context.tr(
                                'Payment request will be sent to ${selectedPayment.maskedNumber}.',
                                'سيتم إرسال طلب الدفع إلى ${selectedPayment.maskedNumber}.',
                              ),
                      ),
                    ],
                  ],
                ),
              ),
              _Section(
                icon: Icons.shopping_bag_outlined,
                title: context.tr('Selected products', 'المنتجات المختارة'),
                subtitle: context.tr(
                  'Review the exact products the customer selected before confirming the order.',
                  'راجع المنتجات التي اختارها العميل قبل تأكيد الطلب.',
                ),
                child: selectedItems.isEmpty
                    ? _EmptyCheckoutHint(
                        title: context.tr(
                          'No selected products',
                          'لا توجد منتجات محددة',
                        ),
                        subtitle: context.tr(
                          'Choose products from the bag first to continue.',
                          'اختر منتجات من السلة أولاً للمتابعة.',
                        ),
                      )
                    : Column(
                        children: selectedItems
                            .map((item) => _CheckoutItemCard(item: item))
                            .toList(),
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: colors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('Final review', 'المراجعة النهائية'),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.tr(
                                  'A clean summary of the delivery details and payment before placing the order.',
                                  'ملخص واضح لبيانات التوصيل والدفع قبل تنفيذ الطلب.',
                                ),
                                style: TextStyle(
                                  color: colors.secondaryText,
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceSoft,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${selectedItems.length} ${context.tr('products', 'منتجات')}',
                            style: TextStyle(
                              color: colors.primaryText,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colors.primaryText.withValues(alpha: 0.96),
                            const Color(0xFF344E6B),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        children: [
                          _SummaryLine(
                            label: context.tr('Recipient', 'المستلم'),
                            value: _recipientController.text.trim().isEmpty
                                ? user.name
                                : _recipientController.text.trim(),
                            emphasized: true,
                            inverted: true,
                          ),
                          _SummaryLine(
                            label: context.tr('Phone', 'الهاتف'),
                            value: _phoneController.text.trim().isEmpty
                                ? context.tr('Not entered', 'غير مُدخل')
                                : _phoneController.text.trim(),
                            inverted: true,
                          ),
                          _SummaryLine(
                            label: context.tr('Zone', 'المنطقة'),
                            value: _zoneController.text.trim().isEmpty
                                ? context.tr('Not entered', 'غير مُدخل')
                                : _zoneController.text.trim(),
                            inverted: true,
                          ),
                          _SummaryLine(
                            label: context.tr('Payment', 'الدفع'),
                            value:
                                selectedPayment?.brand ??
                                context.tr(
                                  'Choose payment method',
                                  'اختر طريقة الدفع',
                                ),
                            inverted: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SummaryLine(
                      label: context.tr('Products total', 'إجمالي المنتجات'),
                      value: formatCurrency(cartController.calculateSubtotal()),
                    ),
                    _SummaryLine(
                      label: context.tr('Delivery', 'التوصيل'),
                      value: context.tr(
                        'Confirmed with entered address',
                        'مؤكد بالعنوان المُدخل',
                      ),
                    ),
                    const Divider(height: 28),
                    _SummaryLine(
                      label: context.tr('Total to pay', 'إجمالي الدفع'),
                      value: formatCurrency(cartController.calculateTotal()),
                      emphasized: true,
                    ),
                    const SizedBox(height: 14),
                    _PaymentInfoNote(
                      title: context.tr('Ready to place', 'جاهز للتنفيذ'),
                      subtitle: context.tr(
                        'Once you confirm, the order will move directly into processing.',
                        'بمجرد التأكيد، سينتقل الطلب مباشرة إلى مرحلة المعالجة.',
                      ),
                    ),
                    if (checkoutController.errorMessage != null) ...[
                      const SizedBox(height: AppSizes.md),
                      Text(
                        _localizedCheckoutError(
                          context,
                          checkoutController.errorMessage!,
                        ),
                        style: TextStyle(
                          color: colors.discount,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.lg),
                    AppButton(
                      text: checkoutController.isPlacingOrder
                          ? context.tr(
                              'Placing Order...',
                              'جارٍ تنفيذ الطلب...',
                            )
                          : context.tr('Place Order', 'تنفيذ الطلب'),
                      onPressed: checkoutController.isPlacingOrder
                          ? null
                          : () => _submitOrder(
                              context,
                              checkoutController,
                              selectedAddress,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleFormChanged() {
    if (!mounted || _isSyncingForm) {
      return;
    }
    _hasManualDeliveryEdits = true;
    setState(() {});
  }

  void _scheduleSeedFormFromAddress(
    AddressModel? address,
    String fallbackName, {
    bool force = false,
  }) {
    if (_hasManualDeliveryEdits && !force) {
      return;
    }
    final nextSeedId = address?.id ?? 'manual_default';
    if (!force && _seededAddressId == nextSeedId) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _applyAddressToForm(address, fallbackName, seedId: nextSeedId);
    });
  }

  void _applyAddressToForm(
    AddressModel? address,
    String fallbackName, {
    required String seedId,
  }) {
    _isSyncingForm = true;
    _recipientController.text = address == null
        ? fallbackName
        : (address.fullName.isEmpty ? fallbackName : address.fullName);
    _phoneController.text = address?.phone ?? '';
    _cityController.text = address?.city ?? '';
    _zoneController.text = address?.region ?? '';
    _streetController.text = address?.streetAddress ?? '';
    _seededAddressId = seedId;
    _hasManualDeliveryEdits = false;
    _isSyncingForm = false;
    if (mounted) {
      setState(() {});
    }
  }

  AddressModel _buildDeliveryAddress(
    String fallbackName,
    AddressModel? baseAddress,
  ) {
    return AddressModel(
      id: baseAddress?.id ?? 'checkout_delivery_address',
      fullName: _recipientController.text.trim().isEmpty
          ? fallbackName
          : _recipientController.text.trim(),
      phone: _phoneController.text.trim(),
      country: (baseAddress?.country.isNotEmpty ?? false)
          ? baseAddress!.country
          : context.tr('Libya', 'ليبيا'),
      city: _cityController.text.trim(),
      region: _zoneController.text.trim(),
      streetAddress: _streetController.text.trim(),
      postalCode: baseAddress?.postalCode ?? '',
      isDefault: true,
    );
  }

  String? _validateDeliveryForm(BuildContext context) {
    if (_phoneController.text.trim().isEmpty) {
      return context.tr(
        'Please enter the delivery phone number',
        'يرجى إدخال رقم هاتف التوصيل',
      );
    }
    if (_cityController.text.trim().isEmpty) {
      return context.tr(
        'Please enter the delivery city',
        'يرجى إدخال مدينة التوصيل',
      );
    }
    if (_zoneController.text.trim().isEmpty) {
      return context.tr(
        'Please enter the zone or area',
        'يرجى إدخال المنطقة أو الحي',
      );
    }
    if (_streetController.text.trim().isEmpty) {
      return context.tr(
        'Please enter the home address',
        'يرجى إدخال عنوان المنزل',
      );
    }
    return null;
  }

  Future<void> _handlePaymentSelection(
    BuildContext context,
    CheckoutController checkoutController,
    PaymentMethodModel method,
  ) async {
    if (method.id == 'cash') {
      checkoutController.setPaymentMethod(method);
      return;
    }

    if (method.id == 'pay-me') {
      final currentPhone = checkoutController.paymentMethod?.id == 'pay-me'
          ? checkoutController.paymentMethod?.maskedNumber
          : _phoneController.text.trim();
      final phone = await _showPayMeDialog(context, currentPhone ?? '');
      if (!context.mounted || phone == null) {
        return;
      }
      checkoutController.setPaymentMethod(
        PaymentMethodModel(
          id: method.id,
          brand: method.brand,
          maskedNumber: phone,
          token: method.token,
          isDefault: method.isDefault,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.tr(
              'Pay Me request prepared successfully',
              'تم تجهيز طلب Pay Me بنجاح',
            ),
          ),
        ),
      );
      return;
    }

    checkoutController.setPaymentMethod(method);
  }

  Future<String?> _showPayMeDialog(
    BuildContext context,
    String initialPhone,
  ) async {
    var phoneValue = initialPhone;
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final colors = dialogContext.appColors;
        return AlertDialog(
          title: Text(dialogContext.tr('Pay Me', 'ادفع لي')),
          scrollable: true,
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dialogContext.tr(
                    'Enter the phone number that should receive the payment request.',
                    'أدخل رقم الهاتف الذي سيستقبل طلب الدفع.',
                  ),
                  style: TextStyle(color: colors.secondaryText, height: 1.45),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  initialValue: initialPhone,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) => phoneValue = value,
                  decoration: InputDecoration(
                    labelText: dialogContext.tr('Phone number', 'رقم الهاتف'),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.tr('Cancel', 'إلغاء')),
            ),
            FilledButton(
              onPressed: () {
                final phone = phoneValue.trim();
                if (phone.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text(
                        dialogContext.tr(
                          'Please enter a phone number',
                          'يرجى إدخال رقم الهاتف',
                        ),
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, phone);
              },
              child: Text(dialogContext.tr('Send', 'إرسال')),
            ),
          ],
        );
      },
    );
    return result;
  }

  Future<void> _submitOrder(
    BuildContext context,
    CheckoutController checkoutController,
    AddressModel? selectedAddress,
  ) async {
    final validationMessage = _validateDeliveryForm(context);
    if (validationMessage != null) {
      AppActionFeedback.error(context, validationMessage);
      return;
    }

    var paymentMethod = checkoutController.paymentMethod;
    if (paymentMethod?.id == 'pay-me' &&
        paymentMethod!.maskedNumber.trim().isEmpty) {
      final phone = await _showPayMeDialog(
        context,
        _phoneController.text.trim(),
      );
      if (!context.mounted || phone == null) {
        return;
      }
      checkoutController.setPaymentMethod(
        PaymentMethodModel(
          id: paymentMethod.id,
          brand: paymentMethod.brand,
          maskedNumber: phone,
          token: paymentMethod.token,
          isDefault: paymentMethod.isDefault,
        ),
      );
      paymentMethod = checkoutController.paymentMethod;
    }

    final profileController = context.read<ProfileController>();
    final cartController = context.read<CartController>();
    final address = _buildDeliveryAddress(
      profileController.user!.name,
      selectedAddress,
    );
    checkoutController.setAddress(address);

    final confirmed = await AppConfirmationDialog.show(
      context,
      title: context.tr('Confirm your order', 'تأكيد تنفيذ الطلب'),
      message: context.tr(
        'Review the order details before continuing. Confirming will create the order and apply the selected stock, coupon, wallet, and points deductions.',
        'راجع بيانات الطلب قبل التأكيد. بعد المتابعة سيتم إنشاء الطلب وخصم الكمية والمبالغ المستخدمة.',
      ),
      cancelLabel: context.tr('Review Again', 'العودة للمراجعة'),
      confirmLabel: paymentMethod?.id == 'cash'
          ? context.tr('Confirm Order', 'تأكيد الطلب')
          : context.tr('Confirm and Pay', 'تأكيد والدفع'),
      icon: Icons.shopping_bag_outlined,
      tone: AppConfirmationTone.purchase,
      barrierDismissible: false,
      details: AppConfirmationDetails(
        children: [
          AppConfirmationDetailRow(
            label: context.tr('Selected products', 'المنتجات المختارة'),
            value: '${cartController.selectedItems.length}',
          ),
          AppConfirmationDetailRow(
            label: context.tr('Total pieces', 'إجمالي القطع'),
            value:
                '${cartController.selectedItems.fold<int>(0, (sum, item) => sum + item.quantity)}',
          ),
          AppConfirmationDetailRow(
            label: context.tr('Final total', 'الإجمالي النهائي'),
            value: formatCurrency(cartController.calculateTotal()),
            emphasized: true,
          ),
          AppConfirmationDetailRow(
            label: context.tr('Address', 'العنوان'),
            value: '${address.city}, ${address.region}',
          ),
          AppConfirmationDetailRow(
            label: context.tr('Phone', 'الهاتف'),
            value: address.phone,
          ),
          AppConfirmationDetailRow(
            label: context.tr('Payment', 'الدفع'),
            value: paymentMethod?.brand ?? '-',
          ),
          if (cartController.calculateDiscount() > 0)
            AppConfirmationDetailRow(
              label: context.tr('Discount', 'الخصم'),
              value: formatCurrency(cartController.calculateDiscount()),
            ),
        ],
      ),
    );
    if (!context.mounted || !confirmed) {
      return;
    }

    final order = await checkoutController.placeOrder();
    if (!context.mounted) {
      return;
    }
    if (order == null) {
      if (checkoutController.errorMessage != null) {
        AppActionFeedback.error(
          context,
          _localizedCheckoutError(context, checkoutController.errorMessage!),
        );
      }
      return;
    }

    AppActionFeedback.success(
      context,
      context.tr('Order placed', 'تم تنفيذ الطلب'),
    );
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.orderSuccess,
      arguments: order.id,
    );
  }
}

List<PaymentMethodModel> _checkoutPaymentMethods(BuildContext context) => [
  PaymentMethodModel(
    id: 'cash',
    brand: context.tr('Cash', 'نقداً'),
    maskedNumber: context.tr(
      'Pay when the order arrives',
      'ادفع عند وصول الطلب',
    ),
    token: 'cash',
    isDefault: true,
  ),
  PaymentMethodModel(
    id: 'pay-me',
    brand: context.tr('Pay Me', 'ادفع لي'),
    maskedNumber: '',
    token: 'pay-me',
  ),
  const PaymentMethodModel(
    id: 'one-pay',
    brand: 'One Pay',
    maskedNumber: 'One Pay Wallet',
    token: 'one-pay',
  ),
  const PaymentMethodModel(
    id: 'ly-pay',
    brand: 'LY Pay',
    maskedNumber: 'Libya Digital Pay',
    token: 'ly-pay',
  ),
];

class _CheckoutHeroCard extends StatelessWidget {
  const _CheckoutHeroCard({
    required this.itemCount,
    required this.totalPieces,
    required this.total,
    required this.address,
    required this.paymentLabel,
  });

  final int itemCount;
  final int totalPieces;
  final double total;
  final AddressModel address;
  final String? paymentLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryText.withValues(alpha: 0.97),
            const Color(0xFF304A63),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('Order Verification', 'التحقق من الطلب'),
            style: TextStyle(
              color: colors.surface,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              'Confirm delivery details and choose the right payment method before placing the order.',
              'أكد بيانات التوصيل واختر طريقة الدفع المناسبة قبل تنفيذ الطلب.',
            ),
            style: TextStyle(
              color: colors.surface.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeroMetric(
                  label: context.tr('Products', 'المنتجات'),
                  value: '$itemCount',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: context.tr('Pieces', 'القطع'),
                  value: '$totalPieces',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMetric(
                  label: context.tr('Total', 'الإجمالي'),
                  value: formatCurrency(total),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroInfoLine(
                  icon: Icons.phone_outlined,
                  label: context.tr('Delivery phone', 'هاتف التوصيل'),
                  value: address.phone.isEmpty
                      ? context.tr('Not entered yet', 'لم يتم إدخاله بعد')
                      : address.phone,
                ),
                const SizedBox(height: 8),
                _HeroInfoLine(
                  icon: Icons.location_on_outlined,
                  label: context.tr('Home address', 'عنوان المنزل'),
                  value:
                      '${address.streetAddress}, ${address.city}, ${address.region}',
                ),
                const SizedBox(height: 8),
                _HeroInfoLine(
                  icon: Icons.payments_outlined,
                  label: context.tr('Payment', 'الدفع'),
                  value:
                      paymentLabel ??
                      context.tr('Choose payment method', 'اختر طريقة الدفع'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.surface.withValues(alpha: 0.74),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: colors.surface,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroInfoLine extends StatelessWidget {
  const _HeroInfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.surface, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: colors.surface.withValues(alpha: 0.9),
                height: 1.45,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: colors.icon),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: colors.primaryText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: colors.secondaryText,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DeliveryFormCard extends StatelessWidget {
  const _DeliveryFormCard({
    required this.recipientController,
    required this.phoneController,
    required this.cityController,
    required this.zoneController,
    required this.streetController,
    required this.onChanged,
  });

  final TextEditingController recipientController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController zoneController;
  final TextEditingController streetController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    InputDecoration decoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surfaceSoft,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          TextField(
            controller: recipientController,
            onChanged: (_) => onChanged(),
            decoration: decoration(
              context.tr('Recipient name', 'اسم المستلم'),
              Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            onChanged: (_) => onChanged(),
            decoration: decoration(
              context.tr('Phone number', 'رقم الهاتف'),
              Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: cityController,
            onChanged: (_) => onChanged(),
            decoration: decoration(
              context.tr('City', 'المدينة'),
              Icons.location_city_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: zoneController,
            onChanged: (_) => onChanged(),
            decoration: decoration(
              context.tr('Zone / Area', 'المنطقة / الحي'),
              Icons.map_outlined,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: streetController,
            maxLines: 3,
            onChanged: (_) => onChanged(),
            decoration: decoration(
              context.tr('Home address', 'عنوان المنزل'),
              Icons.home_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSelect extends StatelessWidget {
  const _PaymentMethodSelect({
    required this.selectedId,
    required this.methods,
    required this.onChanged,
  });

  final String selectedId;
  final List<PaymentMethodModel> methods;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.icon),
      decoration: InputDecoration(
        labelText: context.tr('Select payment method', 'اختر طريقة الدفع'),
        prefixIcon: Icon(Icons.tune_rounded, color: colors.icon),
        filled: true,
        fillColor: colors.surfaceSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: colors.primaryText),
        ),
      ),
      items: methods
          .map(
            (method) => DropdownMenuItem<String>(
              value: method.id,
              child: Text(method.brand),
            ),
          )
          .toList(),
    );
  }
}

class _SelectedPaymentPreview extends StatelessWidget {
  const _SelectedPaymentPreview({required this.method});

  final PaymentMethodModel method;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              _paymentShortLabel(method.brand),
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        method.brand,
                        style: TextStyle(
                          color: colors.primaryText,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Icon(Icons.check_circle_rounded, color: colors.primaryText),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  method.id == 'pay-me' && method.maskedNumber.trim().isNotEmpty
                      ? method.maskedNumber
                      : _paymentDescription(context, method.id),
                  style: TextStyle(
                    color: colors.secondaryText,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoNote extends StatelessWidget {
  const _PaymentInfoNote({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.info_outline_rounded, color: colors.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.secondaryText, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutItemCard extends StatelessWidget {
  const _CheckoutItemCard({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context);
    final localizedTitle = item.product.resolvedTitle(locale);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImage(
            imageUrl: item.product.imageUrl,
            imageUrls: item.product.imageUrls,
            width: 92,
            height: 118,
            radius: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _ItemMetaPill(
                      label:
                          '${context.tr('Color', 'اللون')}: ${item.selectedColor}',
                    ),
                    _ItemMetaPill(
                      label:
                          '${context.tr('Size', 'المقاس')}: ${item.selectedSize}',
                    ),
                    _ItemMetaPill(
                      label: '${context.tr('Qty', 'الكمية')}: ${item.quantity}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      formatCurrency(item.product.price),
                      style: TextStyle(
                        color: colors.price,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formatCurrency(item.product.price * item.quantity),
                      style: TextStyle(
                        color: colors.primaryText,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemMetaPill extends StatelessWidget {
  const _ItemMetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.primaryText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyCheckoutHint extends StatelessWidget {
  const _EmptyCheckoutHint({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: colors.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colors.primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colors.secondaryText, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.label,
    required this.value,
    this.emphasized = false,
    this.inverted = false,
  });

  final String label;
  final String value;
  final bool emphasized;
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = TextStyle(
      fontSize: emphasized ? 16 : 13,
      fontWeight: emphasized ? FontWeight.w900 : FontWeight.w600,
      color: inverted
          ? colors.surface
          : (emphasized ? colors.primaryText : colors.secondaryText),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: style,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Text(value, style: style, textAlign: TextAlign.end),
            ),
          ),
        ],
      ),
    );
  }
}

String _paymentShortLabel(String label) {
  if (label.trim().isEmpty) {
    return '?';
  }
  if (label.contains(' ')) {
    return label
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();
  }
  return label.characters.take(2).toString().toUpperCase();
}

String _paymentDescription(BuildContext context, String id) {
  switch (id) {
    case 'cash':
      return context.tr(
        'No extra step, pay when the order arrives.',
        'لا توجد خطوة إضافية، ادفع عند وصول الطلب.',
      );
    case 'pay-me':
      return context.tr(
        'Open a dialog and send the request to a phone number.',
        'افتح نافذة وأرسل الطلب إلى رقم هاتف.',
      );
    case 'one-pay':
      return context.tr(
        'Use your One Pay wallet in one step.',
        'استخدم محفظة One Pay بخطوة واحدة.',
      );
    case 'ly-pay':
      return context.tr(
        'Digital payment through LY Pay.',
        'دفع رقمي عبر LY Pay.',
      );
    default:
      return '';
  }
}

String _localizedCheckoutError(BuildContext context, String value) {
  switch (value) {
    case 'Only customers can place orders':
      return context.tr(
        'Only customers can place orders',
        'يمكن للعملاء فقط تنفيذ الطلبات',
      );
    case 'Please add a shipping address':
      return context.tr(
        'Please add a shipping address',
        'يرجى إضافة عنوان للشحن',
      );
    case 'Please choose a payment method':
      return context.tr(
        'Please choose a payment method',
        'يرجى اختيار طريقة الدفع',
      );
    case 'Please select at least one item':
      return context.tr(
        'Please select at least one item',
        'يرجى اختيار منتج واحد على الأقل',
      );
    default:
      return value;
  }
}
