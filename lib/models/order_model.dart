import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; // Import Logger
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

import 'config.dart'; // Import Config để sử dụng baseUrl

// Khởi tạo Logger
var logger = Logger();

class Product {
  final String name;
  final int quantity;
  final String company;
  final String imageUrl;
  final int prices;

  Product({
    required this.name,
    required this.quantity,
    required this.company,
    required this.imageUrl,
    required this.prices,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['productId']['name'] ?? 'Unknown Product',
      company: json['productId']['company'] ?? 'Unknown Type',
      quantity: json['quantity'] ?? 0,
      imageUrl: json['productId']['imageUrl'] ??
          'https://via.placeholder.com/150', // URL mặc định
      prices: (json['productId']['promotionPrice'] as num?)?.toInt() ?? 0,
    );
  }
}

class Order {
  final String id;
  final String userId;
  final String cartId;
  final String name;
  final String phone;
  final String email;
  final double totalPrice;
  final double shippingFee;
  final double vatOrder;
  final double orderTotal;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String shippingAddress;
  final List<Product> products;

  Order({
    required this.id,
    required this.userId,
    required this.cartId,
    required this.name,
    required this.phone,
    required this.email,
    required this.totalPrice,
    required this.shippingFee,
    required this.vatOrder,
    required this.orderTotal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.shippingAddress,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var productList = (json['products'] as List? ?? [])
        .map((product) => Product.fromJson(product))
        .toList();

    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      cartId: json['cartId'] ?? '',
      name: json['name'] ?? 'Not available',
      phone: json['phone'] ?? 'Not available',
      email: json['email'] ?? 'Not available',
      totalPrice: _parseDouble(json['totalPrice']),
      shippingFee: _parseDouble(json['shippingFee']),
      vatOrder: _parseDouble(json['VAT']),
      orderTotal: _parseDouble(json['orderTotal']),
      status: json['status'] ?? 'Unknown',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      shippingAddress: json['shippingAddress'] ?? 'Not available',
      products: productList,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return (value as num).toDouble();
  }
}

// Sửa hàm fetchOrders để lấy userId từ SharedPreferences
Future<List<Order>> fetchOrders() async {
  // Lấy userId từ SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('id');

  if (userId == null) {
    // Nếu không có userId, log lỗi và trả về thông báo
    logger.e('User ID not found in SharedPreferences');
    throw Exception('User ID not found');
  }

  // Log thông tin userId
  logger.i('Fetching orders for userId: $userId');

  final response =
      await http.get(Uri.parse('${Config.baseUrl}/order/getAll/$userId'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Log phản hồi từ API
    logger.i('Response from API: $data');

    if (data['status'] == 'OK') {
      logger.i('Orders fetched successfully');
      List<Order> orders =
          (data['data'] as List).map((order) => Order.fromJson(order)).toList();

      // Log imageUrl for each product
      for (var order in orders) {
        for (var product in order.products) {
          logger.i('Product image URL: ${product.imageUrl}');
        }
      }

      return orders;
    } else {
      logger.e('Error fetching orders: ${data['message']}');
      throw Exception('Failed to fetch orders: ${data['message']}');
    }
  } else {
    logger.e('Failed to fetch orders. Status code: ${response.statusCode}');
    throw Exception('Failed to fetch orders');
  }
}
