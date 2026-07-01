import '../models/product_model.dart';
import 'dummy_json_product_api.dart';
import 'fake_store_fashion_api.dart';
import 'mock_data_service.dart';

class ProductService {
  ProductService(
    this._mockDataService, {
    DummyJsonProductApi? productApi,
    FakeStoreFashionApi? fashionApi,
  }) : _productApi = productApi ?? DummyJsonProductApi(),
       _fashionApi = fashionApi ?? FakeStoreFashionApi();

  final MockDataService _mockDataService;
  final DummyJsonProductApi _productApi;
  final FakeStoreFashionApi _fashionApi;

  Future<List<ProductModel>> fetchProducts() async {
    final importedProducts = <ProductModel>[];
    try {
      importedProducts.addAll(await _productApi.fetchProducts());
    } catch (_) {
      // Keep trying the next demo source when DummyJSON is offline or blocked.
    }
    try {
      importedProducts.addAll(await _fashionApi.fetchClothingProducts());
    } catch (_) {
      // Keep the marketplace usable when the fashion demo API is offline.
    }

    return _mergeProducts(
      importedProducts: importedProducts,
      localProducts: _mockDataService.allProducts,
    );
  }

  List<ProductModel> _mergeProducts({
    required List<ProductModel> importedProducts,
    required List<ProductModel> localProducts,
  }) {
    final byId = <String, ProductModel>{};
    for (final product in importedProducts) {
      byId[product.id] = product;
    }
    for (final product in localProducts) {
      byId[product.id] = product;
    }
    return byId.values.toList();
  }
}
