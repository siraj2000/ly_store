import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub_store/controllers/product_controller.dart';
import 'package:stylehub_store/services/local_storage_service.dart';
import 'package:stylehub_store/services/mock_data_service.dart';
import 'package:stylehub_store/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProductController> buildProductController() async {
    SharedPreferences.setMockInitialValues({});
    final localStorageService = await LocalStorageService.create();
    final mockDataService = await MockDataService.create(
      localStorageService: localStorageService,
    );
    final controller = ProductController(
      productService: ProductService(mockDataService),
      mockDataService: mockDataService,
    )..products = mockDataService.products;
    return controller;
  }

  test(
    'subcategory id filters products inside the selected category',
    () async {
      final controller = await buildProductController();
      final baseProduct = controller.marketplaceProducts.firstWhere(
        (product) => product.categoryId.trim().isNotEmpty,
      );
      final source = baseProduct.copyWith(
        subcategoryId: 'stable-test-subcategory',
        subcategoryName: 'Stable Test Subcategory',
      );
      controller.products = [
        source,
        ...controller.products.where((product) => product.id != source.id),
      ];

      final categoryProducts = controller.productsForCategoryIds([
        source.categoryId,
      ]);
      final subcategoryProducts = controller.bySubcategory(
        source.subcategoryId,
      );
      final filteredIds = categoryProducts.map((product) => product.id).toSet()
        ..retainAll(subcategoryProducts.map((product) => product.id).toSet());

      expect(filteredIds, contains(source.id));
      expect(
        filteredIds.every(
          (id) =>
              controller.marketplaceProducts
                  .firstWhere((product) => product.id == id)
                  .categoryId ==
              source.categoryId,
        ),
        isTrue,
      );

      final roundTrip = source.toJson();
      expect(roundTrip['subcategoryId'], source.subcategoryId);
      expect(roundTrip['departmentId'], source.departmentId);
    },
  );
}
