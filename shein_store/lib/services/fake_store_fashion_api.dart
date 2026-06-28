import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/localized_text_model.dart';
import '../models/product_model.dart';

class FakeStoreFashionApi {
  FakeStoreFashionApi({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _productsUri = Uri.https('fakestoreapi.com', '/products');

  Future<List<ProductModel>> fetchClothingProducts() async {
    final response = await _client
        .get(_productsUri)
        .timeout(const Duration(seconds: 6));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FakeStoreFashionApiException(
        'FakeStoreAPI returned HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .where((item) {
          final category = (item['category'] as String? ?? '').toLowerCase();
          return category.contains('clothing');
        })
        .map(_mapProduct)
        .toList();
  }

  ProductModel _mapProduct(Map<String, dynamic> json) {
    final apiId = (json['id'] as num?)?.toInt() ?? 0;
    final title = json['title'] as String? ?? 'Fashion item';
    final description =
        json['description'] as String? ?? 'Imported fashion item.';
    final category = (json['category'] as String? ?? '').toLowerCase();
    final isMens = category.contains('men');
    final categoryId = isMens ? 'men' : 'women';
    final sellerId = isMens ? 'seller_2' : 'seller_1';
    final sellerName = isMens ? 'Northline Studio' : 'Demo Seller';
    final storeId = isMens ? 'store_seller_2' : 'store_seller_1';
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final discount = (apiId * 3 % 28).clamp(6, 28);
    final oldPrice = price / (1 - (discount / 100));
    final rating = json['rating'] is Map<String, dynamic>
        ? json['rating'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final now = DateTime.now();

    return ProductModel(
      id: 'fakestore_$apiId',
      sellerId: sellerId,
      sellerName: sellerName,
      storeId: storeId,
      title: title,
      titleText: LocalizedTextModel(en: title, ar: title),
      categoryId: categoryId,
      categoryName: isMens ? 'Men' : 'Women',
      department: categoryId,
      subcategoryName: isMens ? 'Men Clothing' : 'Women Clothing',
      price: double.parse(price.toStringAsFixed(2)),
      oldPrice: double.parse(oldPrice.toStringAsFixed(2)),
      discount: discount,
      rating: (rating['rate'] as num?)?.toDouble() ?? 4.0,
      reviewCount: (rating['count'] as num?)?.toInt() ?? 50,
      imageUrl: json['image'] as String?,
      imageUrls: [
        if ((json['image'] as String? ?? '').trim().isNotEmpty)
          json['image'] as String,
      ],
      colors: const ['Black', 'White', 'Navy', 'Beige'],
      sizes: const ['XS', 'S', 'M', 'L', 'XL'],
      description: description,
      descriptionText: LocalizedTextModel(en: description, ar: description),
      material: 'Imported fabric blend',
      composition: 'Fashion catalog sample',
      careInstructions: 'Machine wash cold. Hang to dry.',
      sku: 'FAKESTORE-$apiId',
      stock: 12 + (apiId * 5) % 45,
      tags: [
        'fashion',
        'clothing',
        categoryId,
        if (isMens) 'menswear' else 'womenswear',
      ],
      isNew: apiId.isEven,
      isHot: apiId % 3 == 0,
      isFlashSale: discount >= 12,
      soldCount: 120 + (apiId * 41) % 700,
      views: 450 + (apiId * 71) % 2200,
      createdAt: now.subtract(Duration(days: 3 + apiId)),
      updatedAt: now.subtract(Duration(days: apiId % 8)),
      publishedAt: now.subtract(Duration(days: 2 + apiId)),
      countryOfOrigin: 'FakeStoreAPI catalog',
    );
  }
}

class FakeStoreFashionApiException implements Exception {
  const FakeStoreFashionApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
