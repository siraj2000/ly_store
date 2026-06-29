enum ReviewStatus {
  pending,
  approved,
  rejected;

  static ReviewStatus fromJson(String? value) {
    return ReviewStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ReviewStatus.approved,
    );
  }
}

enum ReviewEligibilityReason {
  success,
  notLoggedIn,
  notCustomer,
  notPurchased,
  paymentNotCompleted,
  orderCancelled,
  alreadyReviewed,
  productNotFound,
}

class ReviewEligibilityResult {
  const ReviewEligibilityResult({
    required this.canReview,
    required this.reason,
    this.eligibleOrderId,
    this.existingReview,
  });

  final bool canReview;
  final ReviewEligibilityReason reason;
  final String? eligibleOrderId;
  final ReviewModel? existingReview;
}

class ReviewActionResult {
  const ReviewActionResult({
    required this.success,
    required this.message,
    this.review,
  });

  final bool success;
  final String message;
  final ReviewModel? review;
}

class ProductRatingSummary {
  const ProductRatingSummary({
    required this.averageRating,
    required this.reviewCount,
    required this.ratingBreakdown,
  });

  final double averageRating;
  final int reviewCount;
  final Map<int, int> ratingBreakdown;

  static const empty = ProductRatingSummary(
    averageRating: 0,
    reviewCount: 0,
    ratingBreakdown: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
  );
}

class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.customerAvatarUrl,
    this.imagePaths = const [],
    this.updatedAt,
    this.status = ReviewStatus.approved,
    this.isVerifiedPurchase = false,
  });

  final String id;
  final String productId;
  final String orderId;
  final String customerId;
  final String customerName;
  final String? customerAvatarUrl;
  final double rating;
  final String comment;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ReviewStatus status;
  final bool isVerifiedPurchase;

  String get author => customerName;
  bool get hasPhoto => imagePaths.isNotEmpty;

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? orderId,
    String? customerId,
    String? customerName,
    String? customerAvatarUrl,
    double? rating,
    String? comment,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    ReviewStatus? status,
    bool? isVerifiedPurchase,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAvatarUrl: customerAvatarUrl ?? this.customerAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final legacyAuthor = json['author'] as String?;
    final rawImages = json['imagePaths'] ?? json['images'];
    return ReviewModel(
      id: json['id'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? legacyAuthor ?? '',
      customerAvatarUrl: json['customerAvatarUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      imagePaths: rawImages is List
          ? rawImages.map((item) => item.toString()).toList()
          : (json['hasPhoto'] as bool? ?? false)
          ? const ['legacy-photo']
          : const [],
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      status: ReviewStatus.fromJson(json['status'] as String?),
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'orderId': orderId,
    'customerId': customerId,
    'customerName': customerName,
    'customerAvatarUrl': customerAvatarUrl,
    'rating': rating,
    'comment': comment,
    'imagePaths': imagePaths,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'status': status.name,
    'isVerifiedPurchase': isVerifiedPurchase,
    'author': customerName,
    'hasPhoto': hasPhoto,
  };
}
