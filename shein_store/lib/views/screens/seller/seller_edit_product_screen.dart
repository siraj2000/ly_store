import 'package:flutter/material.dart';

import '../../../models/product_model.dart';
import 'seller_product_form.dart';

class SellerEditProductScreen extends StatelessWidget {
  const SellerEditProductScreen({super.key, this.product});

  final ProductModel? product;

  @override
  Widget build(BuildContext context) {
    return SellerProductFormScreen(product: product);
  }
}
