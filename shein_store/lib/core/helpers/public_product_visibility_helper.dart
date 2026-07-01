import '../../models/product_model.dart';
import '../../models/store_model.dart';
import '../../models/user_model.dart';
import '../policies/product_availability_policy.dart';

class PublicProductVisibilityHelper {
  const PublicProductVisibilityHelper._();

  static bool isProductPublic({
    required ProductModel product,
    UserModel? seller,
    StoreModel? store,
  }) {
    return ProductAvailabilityPolicy.isProductVisibleInCatalog(
      product: product,
      seller: seller,
      store: store,
    );
  }
}
