import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:HDTech/models/cart_model.dart';
import 'package:HDTech/models/config.dart';
import 'package:logger/logger.dart'; // Import logger

class CartService {
  final Logger _logger = Logger(); // Tạo đối tượng logger

  // Lấy giỏ hàng
  Future<List<CartItem>> getCart(String userId) async {
    final url = Uri.parse('${Config.baseUrl}/cart/get-cart/$userId');
    try {
      final response = await http.get(url);

      _logger.d('Request URL: $url');
      _logger.d('Response Status: ${response.statusCode}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('products') && data['products'] is List) {
          List<dynamic> products = data['products'];
          return products.map((item) => CartItem.fromJson(item)).toList();
        } else {
          _logger.e('No products found in the response');
          return []; // Trả về danh sách trống nếu không có sản phẩm
        }
      } else {
        _logger.e('Failed to fetch cart: ${response.statusCode}');
        return []; // Trả về danh sách trống nếu không thành công
      }
    } catch (e) {
      _logger.e('Error fetching cart: $e');
      return []; // Trả về danh sách trống trong trường hợp có lỗi
    }
  }

  // Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(String userId, String productId, int quantity) async {
    final url = Uri.parse('${Config.baseUrl}/cart/add-update');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "productId": productId,
          "quantity": quantity,
        }),
      );

      _logger.d('Request URL: $url');
      _logger.d('Request Body: ${jsonEncode({
            "userId": userId,
            "productId": productId,
            "quantity": quantity,
          })}');
      _logger.d('Response Status: ${response.statusCode}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // Thành công, có thể làm gì đó sau khi xóa
        _logger.d('Product deleted successfully');
      } else {
        // Nếu không thành công, kiểm tra chi tiết trong response.body
        final responseData = jsonDecode(response.body);
        _logger.e(
            'Error deleting product: ${responseData['message'] ?? 'Unknown error'}');
        throw Exception("Failed to delete product from cart");
      }
    } catch (e) {
      _logger.e('Error adding to cart: $e');
      rethrow;
    }
  }

  // Xóa sản phẩm khỏi giỏ hàng
  Future<void> deleteProductFromCart(String userId, String productId) async {
    final url = Uri.parse(
        '${Config.baseUrl}/cart/delete-product-cart/$userId/product/$productId');

    try {
      final response = await http.delete(url);

      _logger.d('Request URL: $url');
      _logger.d('Response Status: ${response.statusCode}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        _logger.e('Failed to delete product from cart: ${response.statusCode}');
        throw Exception("Failed to delete product from cart");
      }
    } catch (e) {
      _logger.e('Error deleting product from cart: $e');
      rethrow;
    }
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearCart(String userId) async {
    final url = Uri.parse('${Config.baseUrl}/cart/delete-cart/$userId');
    try {
      final response = await http.delete(url);

      _logger.d('Request URL: $url');
      _logger.d('Response Status: ${response.statusCode}');
      _logger.d('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        _logger.e('Failed to clear cart: ${response.statusCode}');
        throw Exception("Failed to clear cart");
      }
    } catch (e) {
      _logger.e('Error clearing cart: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(
      String userId, String productId, int quantity) async {
    final url = Uri.parse('${Config.baseUrl}/cart/update/$userId/$productId');

    try {
      // Sử dụng PUT hoặc PATCH để cập nhật dữ liệu thay vì POST
      final response = await http.put(
        url,
        body: json.encode({'quantity': quantity}),
        headers: {'Content-Type': 'application/json'},
      );

      // Kiểm tra mã trạng thái HTTP
      if (response.statusCode == 200) {
        // Thành công trong việc cập nhật sản phẩm trong giỏ hàng
        return;
      } else {
        throw Exception('Cập nhật sản phẩm trong giỏ hàng thất bại');
      }
    } catch (e) {
      throw Exception('Cập nhật sản phẩm trong giỏ hàng thất bại: $e');
    }
  }
}
