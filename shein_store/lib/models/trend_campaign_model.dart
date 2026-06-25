import 'localized_text_model.dart';

class TrendCampaignModel {
  const TrendCampaignModel({
    required this.id,
    required this.titleText,
    required this.subtitleText,
    required this.hashtag,
    required this.imageUrl,
    required this.productIds,
    required this.displayOrder,
    required this.isActive,
    this.startAt,
    this.endAt,
  });

  final String id;
  final LocalizedTextModel titleText;
  final LocalizedTextModel subtitleText;
  final String hashtag;
  final String imageUrl;
  final List<String> productIds;
  final int displayOrder;
  final bool isActive;
  final DateTime? startAt;
  final DateTime? endAt;
}
