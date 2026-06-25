import '../../models/product_model.dart';
import '../../models/product_status.dart';
import '../../models/store_model.dart';
import '../../models/user_model.dart';

class PublicProductVisibilityHelper {
  const PublicProductVisibilityHelper._();

  static bool isProductPublic({
    required ProductModel product,
    UserModel? seller,
    StoreModel? store,
  }) {
    final sellerIsAvailable = seller?.isSellerAccountActive ?? false;
    final storeIsAvailable =
        store != null &&
        store.isActive &&
        !store.vacationMode &&
        store.suspendedAt == null;

    return product.status.isVisibleInCatalog &&
        product.isActive &&
        !product.isDeleted &&
        product.stock > 0 &&
        sellerIsAvailable &&
        storeIsAvailable;
  }
}
