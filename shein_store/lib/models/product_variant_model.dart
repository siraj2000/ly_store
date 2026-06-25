class ProductVariantModel {
  const ProductVariantModel({
    required this.id,
    this.color = '',
    this.size = '',
    this.sku = '',
    this.stock = 0,
    this.priceAdjustment = 0,
    this.isActive = true,
  });

  final String id;
  final String color;
  final String size;
  final String sku;
  final int stock;
  final double priceAdjustment;
  final bool isActive;

  ProductVariantModel copyWith({
    String? id,
    String? color,
    String? size,
    String? sku,
    int? stock,
    double? priceAdjustment,
    bool? isActive,
  }) {
    return ProductVariantModel(
      id: id ?? this.id,
      color: color ?? this.color,
      size: size ?? this.size,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      priceAdjustment: priceAdjustment ?? this.priceAdjustment,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String? ?? '',
      color: json['color'] as String? ?? '',
      size: json['size'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      priceAdjustment: (json['priceAdjustment'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'color': color,
    'size': size,
    'sku': sku,
    'stock': stock,
    'priceAdjustment': priceAdjustment,
    'isActive': isActive,
  };
}
