import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controllers/seller_product_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/helpers/catalog_localization_helper.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/product_image.dart';
import '../../../models/product_model.dart';
import '../../widgets/common/app_header.dart';

class SellerProductFormScreen extends StatefulWidget {
  const SellerProductFormScreen({super.key, this.product});

  final ProductModel? product;

  @override
  State<SellerProductFormScreen> createState() =>
      _SellerProductFormScreenState();
}

class _SellerProductFormScreenState extends State<SellerProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleEn;
  late final TextEditingController _titleAr;
  late final TextEditingController _descriptionEn;
  late final TextEditingController _descriptionAr;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _stock;
  late final TextEditingController _sku;
  late final TextEditingController _materialEn;
  late final TextEditingController _materialAr;
  late final TextEditingController _compositionEn;
  late final TextEditingController _compositionAr;
  late final TextEditingController _careEn;
  late final TextEditingController _careAr;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _titleEn = TextEditingController(text: product?.titleText.en ?? '');
    _titleAr = TextEditingController(text: product?.titleText.ar ?? '');
    _descriptionEn = TextEditingController(
      text: product?.descriptionText.en ?? '',
    );
    _descriptionAr = TextEditingController(
      text: product?.descriptionText.ar ?? '',
    );
    _price = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(2) : '',
    );
    _oldPrice = TextEditingController(
      text: product != null ? product.oldPrice.toStringAsFixed(2) : '',
    );
    _stock = TextEditingController(text: product?.stock.toString() ?? '');
    _sku = TextEditingController(text: product?.sku ?? '');
    _materialEn = TextEditingController(text: product?.materialText.en ?? '');
    _materialAr = TextEditingController(text: product?.materialText.ar ?? '');
    _compositionEn = TextEditingController(
      text: product?.compositionText.en ?? '',
    );
    _compositionAr = TextEditingController(
      text: product?.compositionText.ar ?? '',
    );
    _careEn = TextEditingController(
      text: product?.careInstructionsText.en ?? '',
    );
    _careAr = TextEditingController(
      text: product?.careInstructionsText.ar ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<SellerProductController>().initializeForm(product: product);
    });
  }

  @override
  void dispose() {
    for (final controller in [
      _titleEn,
      _titleAr,
      _descriptionEn,
      _descriptionAr,
      _price,
      _oldPrice,
      _stock,
      _sku,
      _materialEn,
      _materialAr,
      _compositionEn,
      _compositionAr,
      _careEn,
      _careAr,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SellerProductController>(
      builder: (context, controller, _) {
        final colors = context.appColors;
        final l10n = context.l10n;
        final primaryButtonText = controller.isSubmitting
            ? l10n.sellerSaving
            : (controller.saveAsDraft
                  ? l10n.sellerSaveDraft
                  : (_isEditing
                        ? l10n.sellerEditProduct
                        : l10n.sellerSubmitApproval));

        return Scaffold(
          appBar: AppHeader(
            title: _isEditing ? l10n.sellerEditProduct : l10n.sellerAddProduct,
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: AppButton(
                text: primaryButtonText,
                onPressed: controller.isSubmitting
                    ? null
                    : () => _submitForm(controller),
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
              children: [
                _HeroIntro(isEditing: _isEditing),
                const SizedBox(height: 16),
                _SectionCard(
                  title: l10n.sellerEnglishContent,
                  subtitle: l10n.sellerEnglishContentSubtitle,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _titleEn,
                        label: l10n.sellerProductTitleEn,
                        textDirection: TextDirection.ltr,
                        validator: (value) =>
                            controller.validationErrors['titleEn'],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _descriptionEn,
                        label: l10n.sellerProductDescriptionEn,
                        textDirection: TextDirection.ltr,
                        maxLines: 4,
                        validator: (value) =>
                            controller.validationErrors['descriptionEn'],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _materialEn,
                        label: l10n.sellerMaterialEn,
                        textDirection: TextDirection.ltr,
                        validator: (value) =>
                            controller.validationErrors['material'],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _compositionEn,
                        label: l10n.sellerCompositionEn,
                        textDirection: TextDirection.ltr,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _careEn,
                        label: l10n.sellerCareInstructionsEn,
                        textDirection: TextDirection.ltr,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: l10n.sellerArabicContent,
                  subtitle: l10n.sellerArabicContentSubtitle,
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _titleAr,
                        label: l10n.sellerProductTitleAr,
                        textDirection: TextDirection.rtl,
                        validator: (value) =>
                            controller.validationErrors['titleAr'],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _descriptionAr,
                        label: l10n.sellerProductDescriptionAr,
                        textDirection: TextDirection.rtl,
                        maxLines: 4,
                        validator: (value) =>
                            controller.validationErrors['descriptionAr'],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _materialAr,
                        label: l10n.sellerMaterialAr,
                        textDirection: TextDirection.rtl,
                        validator: (value) =>
                            controller.validationErrors['material'],
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _compositionAr,
                        label: l10n.sellerCompositionAr,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _careAr,
                        label: l10n.sellerCareInstructionsAr,
                        textDirection: TextDirection.rtl,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: l10n.sellerClassificationTitle,
                  subtitle: l10n.sellerClassificationSubtitle,
                  child: Column(
                    children: [
                      _LabeledDropdown(
                        label: l10n.sellerDepartment,
                        value: controller.selectedDepartment.isEmpty
                            ? null
                            : controller.selectedDepartment,
                        items: controller.departments,
                        displayValue: (value) =>
                            controller.labelForDepartmentId(
                              value,
                              Localizations.localeOf(context),
                            ),
                        errorText: controller.validationErrors['department'],
                        onChanged: (value) =>
                            controller.setDepartment(value ?? ''),
                      ),
                      const SizedBox(height: 14),
                      _LabeledDropdown(
                        label: l10n.sellerCategory,
                        value: controller.selectedCategory.isEmpty
                            ? null
                            : controller.selectedCategory,
                        items: controller.categoriesForSelectedDepartment,
                        displayValue: (value) => controller.labelForCategoryId(
                          value,
                          Localizations.localeOf(context),
                        ),
                        enabled: controller
                            .categoriesForSelectedDepartment
                            .isNotEmpty,
                        errorText: controller.validationErrors['category'],
                        onChanged: (value) =>
                            controller.setCategory(value ?? ''),
                      ),
                      const SizedBox(height: 14),
                      _LabeledDropdown(
                        label: l10n.sellerSubcategory,
                        value: controller.selectedSubcategory.isEmpty
                            ? null
                            : controller.selectedSubcategory,
                        items: controller.subcategoriesForSelectedCategory,
                        displayValue: (value) =>
                            localizedSubcategoryName(context, value),
                        enabled: controller
                            .subcategoriesForSelectedCategory
                            .isNotEmpty,
                        errorText: controller.validationErrors['subcategory'],
                        onChanged: (value) =>
                            controller.setSubcategory(value ?? ''),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: l10n.sellerPricingInventoryTitle,
                  subtitle: l10n.sellerPricingInventorySubtitle,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _price,
                              label: l10n.sellerPrice,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) =>
                                  controller.validationErrors['price'],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _oldPrice,
                              label: l10n.sellerOldPrice,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              validator: (value) =>
                                  controller.validationErrors['oldPrice'],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _stock,
                              label: l10n.sellerStockQuantity,
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  controller.validationErrors['stock'],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _sku,
                              label: l10n.sellerSku,
                              textDirection: TextDirection.ltr,
                              validator: (value) =>
                                  controller.validationErrors['sku'],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: l10n.sellerVariantsTitle,
                  subtitle: l10n.sellerVariantsSubtitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SelectorHeader(
                        title: l10n.sellerColors,
                        buttonLabel: l10n.sellerAddColors,
                        onTap: () => _showMultiSelectSheet(
                          context,
                          title: l10n.sellerSelectColors,
                          options: SellerProductController.availableColors,
                          selected: controller.selectedColors,
                          onToggle: controller.toggleColor,
                          displayValue: (value) =>
                              localizedColorName(context, value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SelectionWrap(
                        items: controller.selectedColors,
                        emptyLabel: l10n.sellerNoColorsSelected,
                        errorText: controller.validationErrors['colors'],
                        displayValue: (value) =>
                            localizedColorName(context, value),
                        onRemove: controller.removeColor,
                      ),
                      const SizedBox(height: 16),
                      _SelectorHeader(
                        title: l10n.sellerSizes,
                        buttonLabel: l10n.sellerAddSizes,
                        onTap: () => _showMultiSelectSheet(
                          context,
                          title: l10n.sellerSelectSizes,
                          options: SellerProductController.availableSizes,
                          selected: controller.selectedSizes,
                          onToggle: controller.toggleSize,
                          displayValue: (value) =>
                              localizedSizeName(context, value),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _SelectionWrap(
                        items: controller.selectedSizes,
                        emptyLabel: l10n.sellerNoSizesSelected,
                        errorText: controller.validationErrors['sizes'],
                        displayValue: (value) =>
                            localizedSizeName(context, value),
                        onRemove: controller.removeSize,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: l10n.sellerProductImages,
                  subtitle: l10n.sellerProductImagesSubtitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.sellerProductImagesHint,
                        style: TextStyle(
                          color: colors.secondaryText,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount:
                            controller.selectedImages.length +
                            (controller.selectedImages.length < 9 ? 1 : 0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.84,
                            ),
                        itemBuilder: (context, index) {
                          if (index == controller.selectedImages.length &&
                              controller.selectedImages.length < 9) {
                            return _AddImageTile(
                              onTap: () async {
                                final message = await controller
                                    .pickProductImages();
                                if (!context.mounted || message == null) {
                                  return;
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      _localizedImageMessage(context, message),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                          return _PickedImageTile(
                            imagePath: controller.selectedImages[index],
                            isCover: index == 0,
                            onRemove: () =>
                                controller.removeProductImage(index),
                          );
                        },
                      ),
                      if (controller.validationErrors['images'] != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _validationMessage(
                            context,
                            controller.validationErrors['images']!,
                          ),
                          style: TextStyle(
                            color: colors.discount,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SectionCard(
                  title: l10n.sellerProductOptionsTitle,
                  subtitle: l10n.sellerProductOptionsSubtitle,
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: controller.isReturnable,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.sellerReturnable),
                        subtitle: Text(l10n.sellerReturnableSubtitle),
                        onChanged: controller.setReturnable,
                      ),
                      const Divider(height: 18),
                      SwitchListTile(
                        value: controller.saveAsDraft,
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.sellerSaveDraft),
                        subtitle: Text(
                          controller.saveAsDraft
                              ? l10n.sellerSaveAsDraftOnSubtitle
                              : l10n.sellerSaveAsDraftOffSubtitle,
                        ),
                        onChanged: controller.setSaveAsDraft,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitForm(SellerProductController controller) async {
    final result = controller.saveAsDraft
        ? await controller.saveProductAsDraft(
            formKey: _formKey,
            existingProduct: widget.product,
            titleEn: _titleEn.text,
            titleAr: _titleAr.text,
            descriptionEn: _descriptionEn.text,
            descriptionAr: _descriptionAr.text,
            price: _price.text,
            oldPrice: _oldPrice.text,
            stock: _stock.text,
            sku: _sku.text,
            materialEn: _materialEn.text,
            materialAr: _materialAr.text,
            compositionEn: _compositionEn.text,
            compositionAr: _compositionAr.text,
            careInstructionsEn: _careEn.text,
            careInstructionsAr: _careAr.text,
          )
        : await controller.submitProductForApproval(
            formKey: _formKey,
            existingProduct: widget.product,
            titleEn: _titleEn.text,
            titleAr: _titleAr.text,
            descriptionEn: _descriptionEn.text,
            descriptionAr: _descriptionAr.text,
            price: _price.text,
            oldPrice: _oldPrice.text,
            stock: _stock.text,
            sku: _sku.text,
            materialEn: _materialEn.text,
            materialAr: _materialAr.text,
            compositionEn: _compositionEn.text,
            compositionAr: _compositionAr.text,
            careInstructionsEn: _careEn.text,
            careInstructionsAr: _careAr.text,
          );

    if (!mounted || result == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.saveAsDraft
              ? context.l10n.sellerProductSaved
              : context.l10n.sellerProductSubmitted,
        ),
      ),
    );
    Navigator.pop(context);
  }
}

class _HeroIntro extends StatelessWidget {
  const _HeroIntro({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? const [Color(0xFF17202D), Color(0xFF243446), Color(0xFF35304F)]
              : const [Color(0xFF171717), Color(0xFF5E4A3C), Color(0xFFA86E54)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEditing
                ? context.l10n.sellerProductFormHeroEditTitle
                : context.l10n.sellerProductFormHeroCreateTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.sellerProductFormHeroSubtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LabeledDropdown extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.items,
    required this.onChanged,
    required this.displayValue,
    this.value,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final List<String> items;
  final String? value;
  final bool enabled;
  final String? errorText;
  final ValueChanged<String?> onChanged;
  final String Function(String value) displayValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: ValueKey('$label-$value-$enabled'),
          initialValue: value,
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(displayValue(item)),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: enabled
                ? context.l10n.sellerSelectLabel(label)
                : context.l10n.sellerChoosePreviousFieldFirst,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            _validationMessage(context, errorText!),
            style: TextStyle(
              color: colors.discount,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _SelectorHeader extends StatelessWidget {
  const _SelectorHeader({
    required this.title,
    required this.buttonLabel,
    required this.onTap,
  });

  final String title;
  final String buttonLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          icon: const Icon(Icons.add, size: 18),
          label: Text(buttonLabel),
        ),
      ],
    );
  }
}

class _SelectionWrap extends StatelessWidget {
  const _SelectionWrap({
    required this.items,
    required this.emptyLabel,
    required this.onRemove,
    required this.displayValue,
    this.errorText,
  });

  final List<String> items;
  final String emptyLabel;
  final String? errorText;
  final ValueChanged<String> onRemove;
  final String Function(String value) displayValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              emptyLabel,
              style: TextStyle(color: colors.secondaryText),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (item) => Chip(
                    label: Text(displayValue(item)),
                    onDeleted: () => onRemove(item),
                  ),
                )
                .toList(),
          ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _validationMessage(context, errorText!),
            style: TextStyle(
              color: colors.discount,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _PickedImageTile extends StatelessWidget {
  const _PickedImageTile({
    required this.imagePath,
    required this.isCover,
    required this.onRemove,
  });

  final String imagePath;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          Positioned.fill(
            child: ProductImage(
              imageUrl: imagePath,
              imageUrls: [imagePath],
              radius: 18,
            ),
          ),
          if (isCover)
            PositionedDirectional(
              start: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryText.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.sellerCover,
                  style: TextStyle(
                    color: colors.surface,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          PositionedDirectional(
            end: 8,
            top: 8,
            child: Material(
              color: colors.surface.withValues(alpha: 0.92),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 16, color: colors.icon),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddImageTile extends StatelessWidget {
  const _AddImageTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: colors.icon,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.sellerGallery,
              style: TextStyle(
                color: colors.primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showMultiSelectSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required List<String> selected,
  required ValueChanged<String> onToggle,
  required String Function(String value) displayValue,
}) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      final colors = context.appColors;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 16),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.sellerSelectMultipleOptions,
                    style: TextStyle(color: colors.secondaryText),
                  ),
                  const SizedBox(height: 14),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: options.map((option) {
                          final isSelected = selected.contains(option);
                          return FilterChip(
                            label: Text(displayValue(option)),
                            selected: isSelected,
                            onSelected: (_) {
                              onToggle(option);
                              setModalState(() {});
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    text: context.l10n.commonDone,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

String _localizedImageMessage(BuildContext context, String message) {
  final l10n = context.l10n;
  switch (message) {
    case 'You can upload up to 9 images only.':
      return l10n.sellerImageMessageLimitReached;
    case 'Restart the app once to enable gallery access.':
      return l10n.sellerImageMessageRestart;
    case 'Photo library permission is required to add product images.':
      return l10n.sellerImageMessagePermission;
    case 'Unable to open the gallery right now.':
      return l10n.sellerImageMessageUnavailable;
    case 'Image added from gallery.':
      return l10n.sellerImageMessageAdded;
    default:
      if (message.endsWith('images added from gallery.')) {
        final count = int.tryParse(message.split(' ').first) ?? 0;
        return l10n.sellerImageMessageAddedMultiple(count);
      }
      return message;
  }
}

String _validationMessage(BuildContext context, String message) {
  final l10n = context.l10n;
  switch (message) {
    case 'Please select a department':
      return l10n.validationDepartmentRequired;
    case 'Please select a category':
      return l10n.validationCategoryRequired;
    case 'Please select a valid category':
      return l10n.validationCategoryRequired;
    case 'This category is not allowed for your store.':
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'هذا التصنيف غير مسموح لهذا المتجر.'
          : 'This category is not allowed for your store.';
    case 'Please select a subcategory':
      return l10n.validationSubcategoryRequired;
    case 'Add at least a title, SKU, image, or category.':
      return Localizations.localeOf(context).languageCode == 'ar'
          ? 'أضف عنوانا أو SKU أو صورة أو تصنيفا على الأقل.'
          : 'Add at least a title, SKU, image, or category.';
    case 'Select at least one color':
      return l10n.validationColorRequired;
    case 'Select at least one size':
      return l10n.validationSizeRequired;
    case 'Add at least one product image':
      return l10n.validationImageRequired;
    case 'You can upload up to 9 images only.':
      return l10n.validationMaximumImages;
    case 'Product title is required':
      return l10n.validationProductTitleRequired;
    case 'Arabic title is required':
      return l10n.validationArabicTitleRequired;
    case 'Description is required':
      return l10n.validationDescriptionRequired;
    case 'Arabic description is required':
      return l10n.validationArabicDescriptionRequired;
    case 'Enter a valid price greater than 0':
      return l10n.validationValidPrice;
    case 'Old price must be greater than or equal to price':
      return l10n.validationOldPriceMin;
    case 'Enter a valid stock quantity':
      return l10n.validationValidStock;
    case 'SKU is required':
      return l10n.validationSkuRequired;
    case 'Material is required':
      return l10n.validationMaterialRequired;
    default:
      return message;
  }
}
