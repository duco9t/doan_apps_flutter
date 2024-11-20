import 'package:HDTech/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:HDTech/models/checkout_service.dart';
import 'package:HDTech/models/checkout_model.dart'; // Đảm bảo import đúng

final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

class CheckOutScreen extends StatelessWidget {
  final String cartId;

  const CheckOutScreen({Key? key, required this.cartId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = cartId; // Lấy userId từ tham số đầu vào

    return FutureBuilder<CheckoutDetails>(
      future: CheckoutService.getCheckoutDetails(userId),
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
        final totalPrice = checkoutDetails.totalPrice?.toDouble() ?? 0.0;
        final vatOrder = checkoutDetails.vatOrder?.toDouble() ?? 0.0;
        final shippingFee = checkoutDetails.shippingFee?.toDouble() ?? 0.0;
        final orderTotal = checkoutDetails.orderTotal?.toDouble() ?? 0.0;

        return Scaffold(
  appBar: AppBar(
    title: const Text(
      "ORDER DETAILS",
      style: TextStyle(fontWeight: FontWeight.bold), // Đảm bảo tiêu đề AppBar in đậm
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
  ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Information",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 20), 
                Padding(
  padding: const EdgeInsets.only(bottom: 15.0),
  child: _buildInputField("Name", controller: TextEditingController()), 
),
Padding(
  padding: const EdgeInsets.only(bottom: 15.0), 
  child: _buildInputField("Phone Number", controller: TextEditingController()), 
),
Padding(
  padding: const EdgeInsets.only(bottom: 15.0), 
  child: _buildInputField("Email", controller: TextEditingController()), 
),
Padding(
  padding: const EdgeInsets.only(bottom: 15.0), 
  child: _buildInputField("Delivery Address", controller: TextEditingController()), 
),

                const SizedBox(height: 20),
                const Text(
                  "Order Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                          formatCurrency.format(product.total?.toDouble() ?? 0.0), // Sử dụng giá trị mặc định
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
                  color: kprimaryColor,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _handlePayment(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:kprimaryColor,
                    minimumSize: const Size(double.infinity, 55),
                  ),
                  child: const Text(
                    "Pay Now",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField(String labelText, {TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double? value, {bool isBold = false, Color? color}) {
    return Row(
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
          formatCurrency.format(value ?? 0.0), // Sử dụng giá trị mặc định nếu value là null
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  void _handlePayment(BuildContext context) {
    // Xử lý thanh toán
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng thanh toán chưa được triển khai')),
    );
  }
}
