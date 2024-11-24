import 'dart:convert';

import 'package:HDTech/constants.dart';
import 'package:HDTech/models/checkout_model.dart';
import 'package:HDTech/models/checkout_service.dart';
import 'package:HDTech/models/payment_service.dart';
import 'package:HDTech/screens/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/config.dart';

final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

class CheckOutScreen extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String user_Id;

  // ignore: non_constant_identifier_names
  const CheckOutScreen({super.key, required this.user_Id});

  @override
  State<CheckOutScreen> createState() => _CheckOutScreenState();
}

class _CheckOutScreenState extends State<CheckOutScreen> {
  final TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController phoneController = TextEditingController(text: "");
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController addressController =
      TextEditingController(text: "");

  bool isLoading = false;

  get shippingAddress => null;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CheckoutDetails>(
      future: CheckoutService.getCheckoutDetails(widget.user_Id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Lỗi: ${snapshot.error}")),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Không có dữ liệu!")),
          );
        }

        final checkoutDetails = snapshot.data!;
        final cartId = checkoutDetails.cartId;
        final productIds =
            checkoutDetails.products.map((p) => p.productId).toList();
        final totalPrice = checkoutDetails.totalPrice.toDouble() ?? 0.0;
        final vatOrder = checkoutDetails.VATorder.toDouble() ?? 0.0;
        final shippingFee = checkoutDetails.shippingFee.toDouble() ?? 0.0;
        final orderTotal = checkoutDetails.orderTotal.toDouble() ?? 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text("ORDER DETAILS"),
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Order Information",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    _buildInputField(
                      "Name",
                      controller: nameController,
                    ),
                    _buildInputField(
                      "Phone Number",
                      controller: phoneController,
                    ),
                    _buildInputField(
                      "Email",
                      controller: emailController,
                    ),
                    _buildInputField(
                      "Delivery Address",
                      controller: addressController,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Order Details",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: checkoutDetails.products.length,
                        itemBuilder: (context, index) {
                          final product = checkoutDetails.products[index];
                          return ListTile(
                            title: Text(
                              product.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                            subtitle: Text(
                              "Quantity: ${product.quantity}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: Text(
                              formatCurrency.format(product.total.toDouble()),
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    _buildSummaryRow("Total Value", totalPrice),
                    _buildSummaryRow("VAT", vatOrder),
                    _buildSummaryRow("Shipping Fee", shippingFee),
                    const Divider(),
                    _buildSummaryRow(
                      "Grand Total",
                      orderTotal,
                      isBold: true,
                      color: kPrimaryColor,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => _handlePayment(context, cartId, productIds),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        minimumSize: const Size(double.infinity, 55),
                      ),
                      child: Text(
                        isLoading ? "Processing..." : "Pay now",
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(String labelText,
      {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double? value,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatCurrency.format(value ?? 0.0),
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePayment(
      BuildContext context, String cartId, List<String> productIds) async {
    try {
      if (nameController.text.isEmpty ||
          phoneController.text.isEmpty ||
          emailController.text.isEmpty ||
          addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      // Log the starting point
      logger.i("Starting payment process...");

      final checkoutDetails =
          await CheckoutService.getCheckoutDetails(widget.user_Id);
      logger.d("Checkout details fetched: $checkoutDetails");
      // Split address by comma and trim whitespace
      final addressParts =
          addressController.text.split(',').map((e) => e.trim()).toList();

      // Prepare shipping address object according to schema
      final shippingAddress = {
        'address': addressParts.isNotEmpty ? addressParts[0] : '',
        'city': addressParts.length > 1 ? addressParts[1] : '',
        'country': addressParts.length > 2 ? addressParts[2] : 'Việt Nam',
      };

      // Perform your API calls
      final url = Uri.parse('${Config.baseUrl}/order/create');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userId': widget.user_Id,
          'cartId': cartId,
          'productIds': productIds,
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'shippingAddress': shippingAddress,
          'totalPrice': checkoutDetails.totalPrice,
          'shippingFee': checkoutDetails.shippingFee,
          'VATorder': checkoutDetails.VATorder,
          'orderTotal': checkoutDetails.orderTotal,
          'status': 'Pending',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        logger.d("Order created successfully: $responseData");

        if (responseData['status'] == 'OK') {
          final orderId = responseData['data']?['_id'] ?? '';

          final paymentRequest = PaymentRequest(
            orderId: orderId,
            returnUrl: "https://vnpay.vn/",
          );

          // Log the payment request
          logger.d("Payment request: $paymentRequest");

          try {
            final paymentResponse =
                await PaymentService.createPayment(paymentRequest);
            logger.d("Payment response: $paymentResponse");

            // Thêm log để kiểm tra paymentURL
            logger.d("Payment URL: ${paymentResponse.paymentURL}");

            // Chỉ gọi một lần và chuyển hướng đến WebView nếu có URL hợp lệ
            // ignore: unnecessary_null_comparison
            if (paymentResponse.paymentURL != null) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    WebViewScreen(paymentUrl: paymentResponse.paymentURL),
              ));
            } else {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Failed to create payment or invalid payment URL')),
              );
            }
          } catch (error) {
            logger.e("Error during payment creation: $error");
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Payment creation failed: $error")),
            );
          }
        } else {
          throw Exception(responseData['message'] ?? 'Order creation failed');
        }
      } else {
        logger.e("API Response: ${response.body}");
        throw Exception('Order creation failed');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      logger.e("Payment process failed: $error");

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

 
}

class WebViewScreen extends StatelessWidget {
  final String paymentUrl;

  const WebViewScreen({super.key, required this.paymentUrl});

  @override
  Widget build(BuildContext context) {
    // Initialize the WebViewController
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(paymentUrl));

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Chặn hành động back mặc định
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const BottomNavBar()), // Thay thế BottomNavBar với trang bạn cần
          (route) => false, // Xóa tất cả các route trước đó
        );
        return Future.value(
            false); // Trả về false để ngừng hành động quay lại mặc định
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Payment")),
        body: WebViewWidget(controller: controller),
      ),
    );
  }
}
