import '../models/product_model.dart';
import 'mock_data_service.dart';

class ProductService {
  ProductService(this._mockDataService);

  final MockDataService _mockDataService;

  Future<List<ProductModel>> fetchProducts() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _mockDataService.products;
  }
}
