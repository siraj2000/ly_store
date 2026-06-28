import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/localized_text_model.dart';
import '../models/product_model.dart';

class DummyJsonProductApi {
  DummyJsonProductApi({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _productsUri = Uri.https('dummyjson.com', '/products', {
    'limit': '100',
    'select':
        'id,title,description,category,price,discountPercentage,rating,stock,thumbnail,images,tags,sku,brand,weight,dimensions',
  });

  Future<List<ProductModel>> fetchProducts() async {
    final response = await _client
        .get(_productsUri)
        .timeout(const Duration(seconds: 6));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ProductApiException(
        'DummyJSON returned HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final rawProducts = decoded['products'] as List<dynamic>? ?? const [];
    return rawProducts
        .whereType<Map<String, dynamic>>()
        .map(_mapProduct)
        .where((product) => product.stock > 0)
        .toList();
  }

  ProductModel _mapProduct(Map<String, dynamic> json) {
    final apiId = (json['id'] as num?)?.toInt() ?? 0;
    final title = json['title'] as String? ?? 'Imported product';
    final description =
        json['description'] as String? ?? 'Imported product from DummyJSON.';
    final category = (json['category'] as String? ?? 'sale').toLowerCase();
    final mappedCategory = _mapCategory(category, title);
    final seller = _sellerFor(mappedCategory.id);
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final discount = ((json['discountPercentage'] as num?)?.round() ?? 0).clamp(
      0,
      90,
    );
    final oldPrice = discount > 0 ? price / (1 - (discount / 100)) : price + 8;
    final images = [
      json['thumbnail'] as String?,
      ...(json['images'] as List<dynamic>? ?? const []).whereType<String>(),
    ].whereType<String>().where((value) => value.trim().isNotEmpty).toSet();
    final tags = [
      category,
      mappedCategory.id,
      ...(json['tags'] as List<dynamic>? ?? const []).whereType<String>(),
    ];
    final now = DateTime.now();

    return ProductModel(
      id: 'dummy_$apiId',
      sellerId: seller.sellerId,
      sellerName: seller.sellerName,
      storeId: seller.storeId,
      title: title,
      titleText: LocalizedTextModel(en: title, ar: title),
      categoryId: mappedCategory.id,
      categoryName: mappedCategory.name,
      department: mappedCategory.department,
      subcategoryName: _subcategoryFor(category, mappedCategory.name),
      price: double.parse(price.toStringAsFixed(2)),
      oldPrice: double.parse(oldPrice.toStringAsFixed(2)),
      discount: discount,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.2,
      reviewCount: 24 + (apiId * 7) % 260,
      imageUrl: images.isEmpty ? null : images.first,
      imageUrls: images.toList(),
      colors: _colorsFor(mappedCategory.id),
      sizes: _sizesFor(mappedCategory.id),
      description: description,
      descriptionText: LocalizedTextModel(en: description, ar: description),
      material: _materialFor(mappedCategory.id),
      composition: 'Imported catalog sample',
      careInstructions: 'Follow product label instructions.',
      sku: json['sku'] as String? ?? 'DUMMY-$apiId',
      stock: (json['stock'] as num?)?.toInt() ?? 10,
      tags: tags.toSet().toList(),
      isNew: apiId % 3 == 0,
      isHot: apiId % 5 == 0,
      isFlashSale: discount >= 10,
      soldCount: 80 + (apiId * 37) % 620,
      views: 300 + (apiId * 53) % 1600,
      createdAt: now.subtract(Duration(days: 4 + apiId)),
      updatedAt: now.subtract(Duration(days: apiId % 12)),
      publishedAt: now.subtract(Duration(days: 2 + apiId)),
      weight: (json['weight'] as num?)?.toDouble() ?? 0,
      dimensions: _dimensionsFrom(json['dimensions']),
      countryOfOrigin: 'API catalog',
    );
  }

  _MappedCategory _mapCategory(String category, String title) {
    final text = '$category $title'.toLowerCase();
    if (text.contains('beauty') ||
        text.contains('fragrance') ||
        text.contains('skin')) {
      return const _MappedCategory('beauty', 'Beauty', 'beauty');
    }
    if (text.contains('dress') || text.contains('women')) {
      return const _MappedCategory('women', 'Women', 'women');
    }
    if (text.contains('men')) {
      return const _MappedCategory('men', 'Men', 'men');
    }
    if (text.contains('shoe') || text.contains('sandal')) {
      return const _MappedCategory('shoes', 'Shoes', 'shoes');
    }
    if (text.contains('bag') ||
        text.contains('purse') ||
        text.contains('wallet')) {
      return const _MappedCategory('bags', 'Bags', 'bags');
    }
    if (text.contains('jewel') || text.contains('accessor')) {
      return const _MappedCategory(
        'jewelry',
        'Jewelry & Accessories',
        'jewelry',
      );
    }
    if (text.contains('kitchen')) {
      return const _MappedCategory('kitchen', 'Kitchen', 'kitchen');
    }
    if (text.contains('home') ||
        text.contains('furniture') ||
        text.contains('decor')) {
      return const _MappedCategory('house', 'House', 'house');
    }
    if (text.contains('phone') ||
        text.contains('laptop') ||
        text.contains('tablet')) {
      return const _MappedCategory('electronics', 'Electronics', 'electronics');
    }
    return const _MappedCategory('sale', 'Sale', 'sale');
  }

  _SellerSeed _sellerFor(String categoryId) {
    switch (categoryId) {
      case 'men':
      case 'shoes':
      case 'bags':
        return const _SellerSeed(
          'seller_2',
          'Northline Studio',
          'store_seller_2',
        );
      case 'beauty':
      case 'jewelry':
      case 'house':
      case 'home':
      case 'kitchen':
        return const _SellerSeed('seller_3', 'Coastal Edit', 'store_seller_3');
      default:
        return const _SellerSeed('seller_1', 'Demo Seller', 'store_seller_1');
    }
  }

  String _subcategoryFor(String category, String fallback) {
    return category
        .split('-')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ')
        .ifEmpty(fallback);
  }

  List<String> _colorsFor(String categoryId) {
    switch (categoryId) {
      case 'beauty':
        return const ['Rose', 'Nude', 'Coral'];
      case 'home':
      case 'house':
      case 'kitchen':
        return const ['White', 'Natural', 'Black'];
      default:
        return const ['Black', 'White', 'Beige'];
    }
  }

  List<String> _sizesFor(String categoryId) {
    switch (categoryId) {
      case 'beauty':
      case 'jewelry':
      case 'bags':
      case 'home':
      case 'house':
      case 'kitchen':
      case 'electronics':
        return const ['One Size'];
      case 'shoes':
        return const ['36', '37', '38', '39', '40', '41'];
      default:
        return const ['XS', 'S', 'M', 'L', 'XL'];
    }
  }

  String _materialFor(String categoryId) {
    switch (categoryId) {
      case 'beauty':
        return 'Beauty formula';
      case 'kitchen':
      case 'house':
      case 'home':
        return 'Home-grade materials';
      case 'jewelry':
        return 'Metal blend';
      default:
        return 'Mixed materials';
    }
  }

  Map<String, double> _dimensionsFrom(Object? value) {
    if (value is! Map<String, dynamic>) {
      return const {};
    }
    return value.map((key, item) => MapEntry(key, (item as num).toDouble()));
  }
}

class ProductApiException implements Exception {
  const ProductApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _MappedCategory {
  const _MappedCategory(this.id, this.name, this.department);

  final String id;
  final String name;
  final String department;
}

class _SellerSeed {
  const _SellerSeed(this.sellerId, this.sellerName, this.storeId);

  final String sellerId;
  final String sellerName;
  final String storeId;
}

extension on String {
  String ifEmpty(String fallback) => trim().isEmpty ? fallback : this;
}
