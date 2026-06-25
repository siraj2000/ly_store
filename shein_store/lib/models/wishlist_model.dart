class WishlistBoardModel {
  const WishlistBoardModel({
    required this.id,
    required this.name,
    required this.productIds,
    this.isPrivate = false,
  });

  final String id;
  final String name;
  final List<String> productIds;
  final bool isPrivate;

  factory WishlistBoardModel.fromJson(Map<String, dynamic> json) {
    return WishlistBoardModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      productIds: (json['productIds'] as List<dynamic>? ?? [])
          .map((item) => item as String)
          .toList(),
      isPrivate: json['isPrivate'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'productIds': productIds,
    'isPrivate': isPrivate,
  };
}
