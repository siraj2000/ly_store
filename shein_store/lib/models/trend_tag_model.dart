import 'localized_text_model.dart';

class TrendTagModel {
  const TrendTagModel({
    required this.id,
    required this.label,
    this.localizedLabelText,
    required this.productIds,
    required this.storeIds,
    required this.displayOrder,
    required this.isActive,
    this.keywords = const [],
  });

  final String id;
  final String label;
  final LocalizedTextModel? localizedLabelText;
  final List<String> productIds;
  final List<String> storeIds;
  final int displayOrder;
  final bool isActive;
  final List<String> keywords;
}
