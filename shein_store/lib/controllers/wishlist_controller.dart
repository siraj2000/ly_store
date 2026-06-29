import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/user_role.dart';
import '../models/wishlist_model.dart';
import 'auth_controller.dart';
import 'product_controller.dart';

class WishlistController extends ChangeNotifier {
  AuthController? _authController;
  ProductController? _productController;
  List<String> _wishlistProductIds = [];
  List<WishlistBoardModel> _boards = const [];
  String? _boundUserId;

  void bind({
    required AuthController authController,
    required ProductController productController,
  }) {
    _authController = authController;
    _productController = productController;
    final nextUserId = authController.currentUser?.id;
    if (_boundUserId != nextUserId) {
      _boundUserId = nextUserId;
      _wishlistProductIds = List<String>.from(
        authController.currentUser?.wishlistProductIds ?? const [],
      );
      _boards = List<WishlistBoardModel>.from(
        authController.currentUser?.wishlistBoards ?? const [],
      );
      if (_boards.isEmpty && authController.currentRole == UserRole.customer) {
        _boards = const [
          WishlistBoardModel(id: 'board_saved', name: 'Saved', productIds: []),
        ];
      }
    }
    notifyListeners();
  }

  List<String> get wishlistProductIds => _wishlistProductIds;
  List<WishlistBoardModel> get boards => List.unmodifiable(_boards);

  List<ProductModel> get wishlistProducts =>
      (_productController?.products ?? [])
          .where((product) => _wishlistProductIds.contains(product.id))
          .toList();

  bool isWishlisted(String productId) =>
      _wishlistProductIds.contains(productId);

  bool toggleWishlist(ProductModel product) {
    if (_authController?.currentRole != UserRole.customer) {
      return false;
    }
    if (isWishlisted(product.id)) {
      _wishlistProductIds.remove(product.id);
      _persistWishlist();
      notifyListeners();
      return false;
    }
    _wishlistProductIds = [..._wishlistProductIds, product.id];
    _persistWishlist();
    notifyListeners();
    return true;
  }

  void removeFromWishlist(String productId) {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    _wishlistProductIds.remove(productId);
    _boards = _boards
        .map(
          (board) => WishlistBoardModel(
            id: board.id,
            name: board.name,
            productIds: board.productIds
                .where((id) => id != productId)
                .toList(),
            isPrivate: board.isPrivate,
          ),
        )
        .toList();
    _persistWishlist();
    notifyListeners();
  }

  WishlistBoardModel? boardById(String? boardId) {
    if (boardId == null || boardId.isEmpty) {
      return _boards.isEmpty ? null : _boards.first;
    }
    final matches = _boards.where((board) => board.id == boardId);
    return matches.isEmpty ? null : matches.first;
  }

  List<ProductModel> productsForBoard(String? boardId) {
    final board = boardById(boardId);
    if (board == null) {
      return const [];
    }
    return (_productController?.marketplaceProducts ?? [])
        .where((product) => board.productIds.contains(product.id))
        .toList();
  }

  bool createBoard(String name, {bool isPrivate = false}) {
    if (_authController?.currentRole != UserRole.customer) {
      return false;
    }
    final cleanedName = name.trim();
    if (cleanedName.isEmpty ||
        _boards.any(
          (board) => board.name.toLowerCase() == cleanedName.toLowerCase(),
        )) {
      return false;
    }
    _boards = [
      ..._boards,
      WishlistBoardModel(
        id: 'board_${DateTime.now().millisecondsSinceEpoch}',
        name: cleanedName,
        productIds: const [],
        isPrivate: isPrivate,
      ),
    ];
    _persistWishlist();
    notifyListeners();
    return true;
  }

  bool renameBoard(String boardId, String name) {
    final cleanedName = name.trim();
    if (cleanedName.isEmpty ||
        _boards.any(
          (board) =>
              board.id != boardId &&
              board.name.toLowerCase() == cleanedName.toLowerCase(),
        )) {
      return false;
    }
    _boards = _boards
        .map(
          (board) => board.id == boardId
              ? WishlistBoardModel(
                  id: board.id,
                  name: cleanedName,
                  productIds: board.productIds,
                  isPrivate: board.isPrivate,
                )
              : board,
        )
        .toList();
    _persistWishlist();
    notifyListeners();
    return true;
  }

  void deleteBoard(String boardId) {
    _boards = _boards.where((board) => board.id != boardId).toList();
    _persistWishlist();
    notifyListeners();
  }

  void removeFromBoard(String boardId, String productId) {
    _boards = _boards
        .map(
          (board) => board.id == boardId
              ? WishlistBoardModel(
                  id: board.id,
                  name: board.name,
                  productIds: board.productIds
                      .where((id) => id != productId)
                      .toList(),
                  isPrivate: board.isPrivate,
                )
              : board,
        )
        .toList();
    _persistWishlist();
    notifyListeners();
  }

  void moveToBoard(String productId, String boardId) {
    if (_authController?.currentRole != UserRole.customer) {
      return;
    }
    final boardIndex = _boards.indexWhere((board) => board.id == boardId);
    if (boardIndex == -1) return;
    final board = _boards[boardIndex];
    final updatedIds = [
      ...board.productIds.where((id) => id != productId),
      productId,
    ];
    _boards[boardIndex] = WishlistBoardModel(
      id: board.id,
      name: board.name,
      productIds: updatedIds,
      isPrivate: board.isPrivate,
    );
    if (!_wishlistProductIds.contains(productId)) {
      _wishlistProductIds = [..._wishlistProductIds, productId];
    }
    _persistWishlist();
    notifyListeners();
  }

  void _persistWishlist() {
    final currentUser = _authController?.currentUser;
    if (currentUser == null || currentUser.role != UserRole.customer) {
      return;
    }
    _authController?.replaceUser(
      currentUser.copyWith(
        wishlistProductIds: List<String>.from(_wishlistProductIds),
        wishlistBoards: List<WishlistBoardModel>.from(_boards),
      ),
    );
  }
}
