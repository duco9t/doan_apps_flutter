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
  final double totalPrice;
  final String productsTypeName;
  final String imageUrl;
  final int prices;

  Product({
    required this.name,
    required this.quantity,
    required this.totalPrice,
    required this.productsTypeName,
    required this.imageUrl,
    required this.prices,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['productId']['name'],
      productsTypeName: json['productId']['productsTypeName'],
      quantity: json['quantity'],
      totalPrice:
          json['quantity'] * (json['productId']['prices'] as num).toDouble(),
      imageUrl: json['productId']['imageUrl'] as String? ??
          'https://via.placeholder.com/150', // Correct imageUrl path
      prices: (json['productId']['prices'] as num).toInt(),
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
    var productList = (json['products'] as List)
        .map((product) => Product.fromJson(product))
        .toList();

    return Order(
      id: json['_id'],
      userId: json['userId'],
      cartId: json['cartId'],
      name: (json['name'] as String?)?.isEmpty ?? true
          ? 'Not available'
          : json['name'],
      phone: (json['phone'] as String?)?.isEmpty ?? true
          ? 'Not available'
          : json['phone'] ?? 'Not available',
      email: (json['email'] as String?)?.isEmpty ?? true
          ? 'Not available'
          : json['email'],
      totalPrice:
          (json['totalPrice'] as num?)?.toDouble() ?? 0.0, // Cập nhật chỗ này
      shippingFee:
          (json['shippingFee'] as num?)?.toDouble() ?? 0.0, // Cập nhật chỗ này
      vatOrder:
          (json['VATorder'] as num?)?.toDouble() ?? 0.0, // Cập nhật chỗ này
      orderTotal:
          (json['orderTotal'] as num?)?.toDouble() ?? 0.0, // Cập nhật chỗ này
      status: json['status'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      shippingAddress: (json['shippingAddress'] != null &&
              json['shippingAddress']['address'] != null)
          ? json['shippingAddress']['address']
          : 'Not available',
      products: productList,
    );
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
