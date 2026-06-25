class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.author,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.hasPhoto = false,
  });

  final String id;
  final String author;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final bool hasPhoto;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      hasPhoto: json['hasPhoto'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt.toIso8601String(),
    'hasPhoto': hasPhoto,
  };
}
