import 'dart:convert';

import 'package:HDTech/models/config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

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
}
