import 'dart:convert';

import 'package:HDTech/constants.dart';
import 'package:HDTech/models/config.dart';
import 'package:HDTech/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Initialize Logger
var logger = Logger();

class OrderDetailPage extends StatelessWidget {
  final String orderStatus;
  final String orderNumber;
  final String trackingNumber;
  final String deliveryAddress;
  final List<Product> products;
  final double subtotal;
  final double shipping;
  final double totalPrice;
  // ignore: non_constant_identifier_names
  final double VATorder;
  final String name;
  final String phone;

  const OrderDetailPage({
    super.key,
    required this.orderStatus,
    required this.orderNumber,
    required this.trackingNumber,
    required this.deliveryAddress,
    required this.products,
    required this.subtotal,
    required this.shipping,
    required this.totalPrice,
    // ignore: non_constant_identifier_names
    required this.VATorder,
    required this.name,
    required this.phone,
  });

  // Build Status Banner
  Widget buildStatusBanner() {
    String statusText;
    String svgImage;
    List<Color> gradientColors;

    switch (orderStatus) {
      case 'Delivered':
        statusText = 'Your order is delivered';
        svgImage = 'images/icons/delivered.svg';
        gradientColors = [
          const Color.fromARGB(255, 154, 0, 215),
          const Color.fromARGB(255, 53, 120, 197)
        ];
        break;
      case 'Pending':
        statusText = 'Your order is being pending';
        svgImage = 'images/icons/processing.svg';
        gradientColors = [
          const Color.fromARGB(255, 212, 40, 40),
          const Color.fromARGB(255, 255, 144, 80)
        ];
        break;
      case 'Shipped':
        statusText = 'Your order is shipped';
        svgImage = 'images/icons/delivering.svg';
        gradientColors = [
          const Color.fromARGB(255, 127, 173, 0),
          const Color.fromARGB(255, 14, 170, 14)
        ];
        break;
      case 'Cancelled':
        statusText = 'Your order has been cancelled.';
        svgImage = 'images/icons/x-octagon-error-svgrepo-com.svg';
        gradientColors = [kPrimaryColor, Colors.red];
        break;
      default:
        statusText = 'Unknown Status';
        return const SizedBox.shrink(); // Hide component if status is unknown
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SvgPicture.asset(svgImage, width: 40, height: 40),
        ],
      ),
    );
  }

  // Build Order Details
// Build Order Details
  Widget buildOrderDetails() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Order Number:'),
              Text(
                orderNumber.length > 18
                    ? '${orderNumber.substring(0, 18)}...'
                    : orderNumber,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tracking Number:'),
              Text(
                trackingNumber.length > 18
                    ? '${trackingNumber.substring(0, 18)}...'
                    : trackingNumber,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Delivery Address:'),
              Text(
                deliveryAddress.length > 18
                    ? '${deliveryAddress.substring(0, 18)}...'
                    : deliveryAddress,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recipient Name:'),
              Text(
                name.isEmpty ? 'Not available' : name,
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recipient Phone:'),
              Text(
                phone.isEmpty ? 'Not available' : phone,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Product Bill
  Widget buildProductBill() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Map qua danh sách sản phẩm và hiển thị chi tiết từng sản phẩm
          ...products.map((product) {
            return Padding(
              padding: const EdgeInsets.only(
                  bottom: 8.0), // Khoảng cách giữa các sản phẩm
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hình ảnh sản phẩm
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imageUrl.isEmpty
                          ? 'https://via.placeholder.com/150' // Placeholder nếu thiếu URL
                          : product.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          logger.i(
                              "Image loaded successfully: ${product.imageUrl}");
                          return child;
                        } else {
                          logger.i("Loading image: ${product.imageUrl}");
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        }
                      },
                      errorBuilder: (BuildContext context, Object error,
                          StackTrace? stackTrace) {
                        logger.e("Error loading image: ${product.imageUrl}",
                            error: error);
                        return Image.asset(
                            'assets/images/error_placeholder.png'); // Hình ảnh lỗi
                      },
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Loại sản phẩm và tên sản phẩm
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  // Số lượng và giá
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Quantity: ${product.quantity}'),
                      Text('${formatPrice(product.prices.toDouble())} đ'),
                    ],
                  ),
                ],
              ),
            );
          // ignore: unnecessary_to_list_in_spreads
          }).toList(), // Kết thúc map và chuyển thành danh sách

          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('${formatPrice(subtotal)} đ'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('VAT'),
              Text('${formatPrice(VATorder)} đ'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shipping'),
              Text('${formatPrice(shipping)} đ'),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total order'),
              Text(
                '${formatPrice(subtotal + VATorder + shipping)} đ',
              ),
            ],
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Voucher'),
              Text(
                '(-${((1 - totalPrice / (subtotal + VATorder + shipping)) * 100).toStringAsFixed(0)}%)   '
                '${formatPrice(totalPrice - (subtotal + VATorder + shipping))} đ',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                '${formatPrice(totalPrice)} đ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Action Button
  Widget buildActionButton(BuildContext context, String orderId) {
    if (orderStatus == 'Shipped') {
      // Nút 'Received'
      return OutlinedButton(
        onPressed: () {
          _showConfirmationDialog(
            context: context,
            title: 'Confirmation',
            content: 'Are you sure you want to mark this order as received?',
            onConfirm: () {
              Navigator.pop(context); // Đóng dialog
              _deliverOrder(context, orderId);
            },
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white, // Nền trắng
          side: const BorderSide(color: Colors.green),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: const Text(
          'Received',
          style: TextStyle(
            color: Colors.green, // Màu chữ
            fontWeight: FontWeight.bold, // Chữ đậm
          ),
        ),
      );
    } else if (orderStatus == 'Pending') {
      // Nút 'Cancel Order'
      return OutlinedButton(
        onPressed: () {
          _showConfirmationDialog(
            context: context,
            title: 'Confirmation',
            content: 'Are you sure you want to cancel this order?',
            onConfirm: () {
              Navigator.pop(context); // Đóng dialog
              _cancelOrder(context, orderId);
            },
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white, // Nền trắng
          side: const BorderSide(color: kPrimaryColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: const Text(
          'Cancel Order',
          style: TextStyle(
            color: kPrimaryColor, // Màu chữ
            fontWeight: FontWeight.bold, // Chữ đậm
          ),
        ),
      );
    }
    return const SizedBox.shrink(); // Hide button for other statuses
  }

  // Format price
  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset('images/icons/alt-arrow-left-svgrepo-com.svg'),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Order Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              buildStatusBanner(),
              const SizedBox(height: 16.0),
              buildOrderDetails(),
              const SizedBox(height: 16.0),
              buildProductBill(),
              const SizedBox(height: 16.0),
              buildActionButton(context, orderNumber),
            ],
          ),
        ),
      ),
    );
  }
}

// Function to show confirmation dialog
Future<void> _showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

// Function to handle cancel order
Future<void> _cancelOrder(BuildContext context, String orderId) async {
  // Log the received orderId
  logger.i('Cancel Order Function Called - Order ID: $orderId');

  if (orderId.isEmpty) {
    logger.e('Order ID is empty. Cannot cancel order.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Order ID is missing!')),
    );
    return;
  }

  try {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/order/cancel'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        logger.i('Order canceled successfully - Order ID: $orderId');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order canceled successfully!')),
        );
      } else {
        logger.e('Failed to cancel order: ${data['message']}');
        throw Exception(data['message']);
      }
    } else {
      logger.e(
          'HTTP error while canceling order. Status code: ${response.statusCode}');
      throw Exception('Failed to cancel order.');
    }
  } catch (e) {
    logger.e('Exception while canceling order: $e');
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

// Function to handle deliver order
Future<void> _deliverOrder(BuildContext context, String orderId) async {
  // Log the received orderId
  logger.i('Deliver Order Function Called - Order ID: $orderId');

  if (orderId.isEmpty) {
    logger.e('Order ID is empty. Cannot mark order as received.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error: Order ID is missing!')),
    );
    return;
  }

  try {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/order/deliver'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'orderId': orderId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK') {
        logger.i('Order marked as received - Order ID: $orderId');
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order marked as received!')),
        );
      } else {
        logger.e('Failed to mark order as received: ${data['message']}');
        throw Exception(data['message']);
      }
    } else {
      logger.e(
          'HTTP error while marking order as received. Status code: ${response.statusCode}');
      throw Exception('Failed to mark order as received.');
    }
  } catch (e) {
    logger.e('Exception while marking order as received: $e');
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
