import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:HDTech/models/config.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:logger/logger.dart'; 
import 'package:HDTech/models/cart_model.dart';
import 'checkout_model.dart';
// Create an instance of Logger
final Logger logger = Logger();

Future<String?> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('id');
}

class CheckoutService {
  // Get Order Details
   // Fetch cart details using userId (for checkout)
  static Future<CheckoutDetails> getCheckoutDetails(String userId) async {
    final url = Uri.parse('${Config.baseUrl}/cart/get-cart/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Trả về CheckoutDetails thay vì List<CartItem>
      return CheckoutDetails.fromJson(data);
    } else {
      throw Exception("Failed to load cart details");
    }
  }

   // Tạo đơn hàng (POST)
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required List<CartItem> items,
    required String shippingAddress,
    required String name,
    required String phone,
    required String email,
    required String token,
  }) async {
  
    final url = Uri.parse('${Config.baseUrl}/order/create');
     final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "userId": userId,
      "items": items.map((item) => item.toJson()).toList(),
      "shippingAddress": shippingAddress,
      "name": name,
      "phone": phone,
      "email": email,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "orderId": data["data"]["_id"]};
      } else {
        final error = jsonDecode(response.body);
        return {"success": false, "message": error["message"]};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  
}
