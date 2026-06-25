import 'package:flutter/material.dart';

import '../../../core/widgets/app_empty_state.dart';
import '../../widgets/common/app_header.dart';

class WishlistBoardScreen extends StatelessWidget {
  const WishlistBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AppHeader(title: 'Board Details'),
      body: AppEmptyState(
        title: 'Board details',
        message: 'Saved board items will appear here as the mock state grows.',
      ),
    );
  }
}
