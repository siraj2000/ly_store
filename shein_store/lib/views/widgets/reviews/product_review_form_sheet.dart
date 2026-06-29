import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/localization_extension.dart';
import '../../../models/product_model.dart';
import '../../../models/review_model.dart';

class ProductReviewFormSheet extends StatefulWidget {
  const ProductReviewFormSheet({
    super.key,
    required this.product,
    required this.onSubmit,
    this.existingReview,
  });

  final ProductModel product;
  final ReviewModel? existingReview;
  final Future<ReviewActionResult> Function({
    required int rating,
    required String comment,
  })
  onSubmit;

  static Future<bool?> show({
    required BuildContext context,
    required ProductModel product,
    required Future<ReviewActionResult> Function({
      required int rating,
      required String comment,
    })
    onSubmit,
    ReviewModel? existingReview,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ProductReviewFormSheet(
        product: product,
        existingReview: existingReview,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ProductReviewFormSheet> createState() => _ProductReviewFormSheetState();
}

class _ProductReviewFormSheetState extends State<ProductReviewFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _commentController;
  late int _rating;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating.round().clamp(0, 5) ?? 0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isEditing = widget.existingReview != null;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final title = isEditing
        ? context.tr('Edit Review', 'تعديل التقييم')
        : context.tr('Product Review', 'تقييم المنتج');

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(Icons.rate_review_outlined, color: colors.icon),
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
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.product.resolvedTitle(
                            Localizations.localeOf(context),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: colors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                context.tr('Select rating', 'اختر عدد النجوم'),
                style: TextStyle(
                  color: colors.primaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton.filledTonal(
                    onPressed: _isSubmitting
                        ? null
                        : () => setState(() => _rating = star),
                    icon: Icon(
                      star <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: star <= _rating ? colors.warning : colors.icon,
                    ),
                  );
                }),
              ),
              if (_rating == 0)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    context.tr('Rating is required.', 'التقييم بالنجوم مطلوب.'),
                    style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _commentController,
                enabled: !_isSubmitting,
                minLines: 4,
                maxLines: 7,
                maxLength: 1000,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  labelText: context.tr('Write your comment', 'اكتب تعليقك'),
                  hintText: context.tr(
                    'Share what stood out about quality, fit, or delivery.',
                    'شارك رأيك عن الجودة أو المقاس أو التوصيل.',
                  ),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return context.tr('Comment is required.', 'التعليق مطلوب.');
                  }
                  if (text.length < 5) {
                    return context.tr(
                      'Comment must be at least 5 characters.',
                      'يجب ألا يقل التعليق عن 5 أحرف.',
                    );
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context, false),
                      child: Text(context.tr('Cancel', 'إلغاء')),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              isEditing
                                  ? context.tr('Edit Review', 'تعديل التقييم')
                                  : context.tr(
                                      'Submit Review',
                                      'إرسال التقييم',
                                    ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() {});
      return;
    }
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    setState(() => _isSubmitting = true);
    final result = await widget.onSubmit(
      rating: _rating,
      comment: _commentController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);
    if (!result.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.tr('Review submitted successfully', 'تم إرسال التقييم بنجاح'),
        ),
      ),
    );
    Navigator.pop(context, true);
  }
}
