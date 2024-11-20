import 'package:HDTech/models/cart_model.dart';
import 'package:HDTech/models/cart_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart'; // Import logger
import 'package:provider/provider.dart';

final formatCurrency = NumberFormat.currency(
    locale: 'vi_VN', symbol: 'VNĐ'); // Format currency in VND

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final Logger _logger = Logger(); // Tạo instance của Logger
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });
  }

  double get totalPrice => subtotal;

  Future<void> fetchCart(String userId) async {
    _logger.i("Fetching cart for user: $userId");
    try {
      // Lấy giỏ hàng từ CartService
      _cartItems = await _cartService.getCart(userId);

      // Kiểm tra nếu giỏ hàng trống
      if (_cartItems.isEmpty) {
        _logger.w("No items in the cart.");
      }

      // Cập nhật UI
      notifyListeners();

      _logger.i("Fetched cart successfully with ${_cartItems.length} items");
    } catch (e) {
      _logger.e("Failed to fetch cart: $e");

      // Trong trường hợp có lỗi, bạn có thể trả về giỏ hàng mặc định hoặc thông báo lỗi
      _cartItems = []; // Giỏ hàng trống trong trường hợp có lỗi
      notifyListeners();
    }
  }

  Future<void> addItem(String userId, String productId, int quantity) async {
    _logger.i(
        "Adding item $productId with quantity $quantity to cart for user: $userId");
    try {
      await _cartService.addToCart(userId, productId, quantity);
      await fetchCart(userId); // Sync state after adding
      _logger.i("Item added successfully to cart");
      notifyListeners();
    } catch (e) {
      _logger.e("Failed to add item to cart: $e");
    }
  }

  Future<void> removeItem(String userId, String productId) async {
    _logger.i("Removing item $productId from cart for user: $userId");
    try {
      await _cartService.deleteProductFromCart(userId, productId);
      await fetchCart(userId); // Sync state after removal
      _logger.i("Item removed successfully from cart");
    } catch (e) {
      _logger.e("Failed to remove item from cart: $e");
    }
  }

  Future<void> clearCart(String userId) async {
    _logger.i("Clearing cart for user: $userId");
    try {
      await _cartService.clearCart(userId);
      _cartItems = [];
      notifyListeners();
      _logger.i("Cart cleared successfully");
    } catch (e) {
      _logger.e("Failed to clear cart: $e");
    }
  }

  Future<void> incrementQuantity(String userId, String productId) async {
    _logger.i(
        "Tăng số lượng sản phẩm $productId trong giỏ hàng cho người dùng: $userId");
    try {
      final index =
          _cartItems.indexWhere((item) => item.productId == productId);

      if (index != -1) {
        final currentQuantity = _cartItems[index].quantity;
        final product = _cartItems[index];

        // Kiểm tra số lượng sản phẩm có vượt quá số lượng tồn kho không
        if (currentQuantity + 1 > int.parse(product.quantityInStock)) {
          throw Exception('Số lượng trong kho không đủ');
        }

        // Tăng số lượng sản phẩm ở phía client
        _cartItems[index].quantity = currentQuantity + 1;

        // Cập nhật số lượng trong giỏ hàng ở phía server
        await _cartService.updateCartItem(
            userId, productId, _cartItems[index].quantity);

        // Cập nhật UI
        notifyListeners();
        _logger.i(
            "Số lượng sản phẩm $productId đã tăng lên ${_cartItems[index].quantity}");
      }
    } catch (e) {
      _logger.e("Thêm số lượng sản phẩm $productId vào giỏ hàng thất bại: $e");
    }
  }

  Future<void> decrementQuantity(String userId, String productId) async {
    _logger.i(
        "Giảm số lượng sản phẩm $productId trong giỏ hàng cho người dùng: $userId");
    try {
      final index =
          _cartItems.indexWhere((item) => item.productId == productId);
      if (index != -1 && _cartItems[index].quantity > 1) {
        final currentQuantity = _cartItems[index].quantity;

        // Giảm số lượng sản phẩm ở phía client
        _cartItems[index].quantity = currentQuantity - 1;

        // Cập nhật số lượng trong giỏ hàng ở phía server
        await _cartService.updateCartItem(
            userId, productId, _cartItems[index].quantity);

        // Cập nhật UI
        notifyListeners();
        _logger.i(
            "Số lượng sản phẩm $productId đã giảm xuống ${_cartItems[index].quantity}");
      } else {
        // Nếu số lượng giảm xuống 0, cần xóa sản phẩm khỏi giỏ hàng
        _logger.i("Số lượng là 0, sẽ xóa sản phẩm $productId khỏi giỏ hàng");
        await _cartService.deleteProductFromCart(userId, productId);
        await fetchCart(userId); // Đồng bộ lại giỏ hàng
        _logger.i(
            "Sản phẩm $productId đã được xóa khỏi giỏ hàng vì số lượng bằng 0");
      }
    } catch (e) {
      _logger.e("Giảm số lượng sản phẩm $productId thất bại: $e");
    }
  }

  static CartProvider of(BuildContext context) {
    return Provider.of<CartProvider>(context, listen: false);
  }
}
