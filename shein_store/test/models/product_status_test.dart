import 'package:flutter_test/flutter_test.dart';
import 'package:stylehub_store/models/product_status.dart';

void main() {
  test('legacy product status values migrate to stable ids', () {
    expect(ProductStatus.fromStorage('approved'), ProductStatus.active);
    expect(
      ProductStatus.fromStorage('pending_approval'),
      ProductStatus.pendingApproval,
    );
    expect(ProductStatus.fromStorage('out_of_stock'), ProductStatus.outOfStock);
  });

  test('stable product status ids serialize predictably', () {
    expect(ProductStatus.active.id, 'active');
    expect(ProductStatus.automatedReview.id, 'automated_review');
    expect(ProductStatus.manualReview.id, 'manual_review');
    expect(ProductStatus.informationRequired.id, 'information_required');
    expect(ProductStatus.pendingApproval.id, 'pending_approval');
    expect(ProductStatus.outOfStock.id, 'out_of_stock');
  });
}
