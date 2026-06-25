import 'localized_text_model.dart';

class TrendStoreSectionModel {
  const TrendStoreSectionModel({
    required this.storeId,
    required this.trendTagIds,
    required this.featuredProductIds,
    required this.isNew,
    required this.isTrending,
    required this.displayOrder,
    this.reviewPreviewText,
  });

  final String storeId;
  final List<String> trendTagIds;
  final List<String> featuredProductIds;
  final bool isNew;
  final bool isTrending;
  final int displayOrder;
  final LocalizedTextModel? reviewPreviewText;
}
