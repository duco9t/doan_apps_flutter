import 'dart:convert';

import 'package:HDTech/constants.dart';
import 'package:HDTech/models/checkout_model.dart';
import 'package:HDTech/models/checkout_service.dart';
import 'package:HDTech/models/payment_service.dart';
import 'package:HDTech/models/user_model.dart';
import 'package:HDTech/screens/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để sử dụng Clipboard
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart' as logger;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Để sử dụng launch và canLaunch
import 'package:webview_flutter/webview_flutter.dart';

import '../../models/config.dart';

final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

class CheckOutScreen extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final String user_Id;

  // ignore: non_constant_identifier_names
  const CheckOutScreen({super.key, required this.user_Id});

  @override
  State<CheckOutScreen> createState() => CheckOutScreenState();
}

class CheckOutScreenState extends State<CheckOutScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late bool isLoading;
  final TextEditingController voucherCodeController =
      TextEditingController(text: "");

  get shippingAddress => null;

  @override
  void initState() {
    super.initState();
    isLoading = true;

    // Khởi tạo các controller nhưng chưa gán giá trị
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    addressController = TextEditingController();

    _initializeData();
    _getCurrentLocation();
  }

  Future<void> _initializeData() async {
    try {
      // Lấy dữ liệu người dùng từ UserService
      final user = await UserService().getUserDetails();

      if (user == null) {
        logger.Logger().i('Không tìm thấy người dùng.');
        return;
      }

      // Gán giá trị cho các controller sau khi lấy dữ liệu người dùng
      nameController.text = user['name'];
      emailController.text = user['email'];
      phoneController.text =
          user['phone'].toString(); // Chuyển đổi int sang String

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      logger.Logger().e('Lỗi khi khởi tạo dữ liệu: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address =
            '${place.thoroughfare ?? ''}, ${place.administrativeArea ?? ''}, ${place.subAdministrativeArea ?? ''}';
        addressController.text = address;
      } else {
        addressController.text = 'Unable to fetch address';
      }
    } catch (e) {
      addressController.text = 'Error fetching address';
    }
  }

  Future<void> getUserDetails() async {
    try {
      // Lấy userId từ SharedPreferences
      String? userId = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('userId'));

      if (userId == null) {
        throw Exception("Không tìm thấy UserId trong SharedPreferences");
      }

      // Lấy access_token từ SharedPreferences
      String? accessToken = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('accessToken'));

      if (accessToken == null) {
        throw Exception("Không tìm thấy accessToken trong SharedPreferences");
      }

      // Giả sử bạn có một phương thức lấy dữ liệu người dùng từ API
      final userDetails = await fetchUserDetailsFromApi(userId, accessToken);

      if (userDetails == null) {
        throw Exception("Không tìm thấy dữ liệu người dùng từ API");
      }

      // Tiến hành sử dụng dữ liệu người dùng
      logger.Logger()
          .i("Thông tin người dùng: $userDetails"); // Log voucher code
    } catch (e) {
      logger.Logger()
          .i("⛔ Lỗi khi tải dữ liệu người dùng: $e"); // Log voucher code
      // Hiển thị thông báo lỗi hoặc thực hiện hành động khác khi có lỗi
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetailsFromApi(
      String userId, String accessToken) async {
    // Thực hiện yêu cầu API để lấy thông tin người dùng
    final url = Uri.parse('YOUR_API_URL');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi khi lấy dữ liệu người dùng từ API");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CheckoutDetails?>(
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

        if (snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text("Không có dữ liệu!")),
          );
        }

        final checkoutDetails = snapshot.data!;
        final cartId = checkoutDetails.cartId;
        final productIds =
            checkoutDetails.products.map((p) => p.productId).toList();
        final totalPrice = checkoutDetails.totalPrice.toDouble();
        final vatOrder = checkoutDetails.VATorder.toDouble();
        final shippingFee = checkoutDetails.shippingFee.toDouble();
        final orderTotal = checkoutDetails.orderTotal.toDouble();

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
          resizeToAvoidBottomInset:
              false, // Ngăn bố cục bị đẩy lên khi bàn phím hiển thị
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
                    _buildInputField(
                      "Voucher",
                      controller: voucherCodeController,
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
                              formatCurrency
                                  .format(product.promotionPrice.toDouble()),
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

      // Kiểm tra mã voucher
      final voucherCode = voucherCodeController.text.trim();
      logger.Logger()
          .i("Voucher Code Entered: $voucherCode"); // Log voucher code
      if (voucherCode.isNotEmpty) {
        final isValid = await _validateVoucher(voucherCode);
        if (!isValid) {
          _showVoucherDialog(
              // ignore: use_build_context_synchronously
              context,
              "Invalid Voucher",
              "The voucher code is not valid.");
          return;
        }
      }

      setState(() {
        isLoading = true;
      });

      final checkoutDetails =
          await CheckoutService.getCheckoutDetails(widget.user_Id);

      final shippingAddress = addressController.text;

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
          'voucherCode': voucherCode,
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
        logger.Logger().i("Response Data: $responseData");

        if (responseData['status'] == 'OK') {
          final orderId = responseData['data']?['data']?['_id'] ?? '';
          logger.Logger().i("Extracted Order ID: $orderId");

          final paymentRequest = PaymentRequest(
            orderId: orderId,
            returnUrl: "https://vnpay.vn/",
          );
          logger.Logger().i("Payment Request: $paymentRequest");

          try {
            final paymentResponse =
                await PaymentService.createPayment(paymentRequest);
            logger.Logger().i("Payment Response: $paymentResponse");

            // ignore: unnecessary_null_comparison
            if (paymentResponse.paymentURL != null) {
              logger.Logger().i("Payment URL: ${paymentResponse.paymentURL}");
              // ignore: use_build_context_synchronously
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    WebViewScreen(paymentUrl: paymentResponse.paymentURL),
              ));
            } else {
              logger.Logger().w("Payment URL is null.");
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to create payment URL')),
              );
            }
          } catch (error) {
            logger.Logger().e("Payment creation failed: $error");
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Payment creation failed: $error")),
            );
          }
        } else {
          logger.Logger().e(
              "Order creation failed with message: ${responseData['message']}");
          throw Exception(responseData['message'] ?? 'Order creation failed');
        }
      } else {
        logger.Logger().e(
            "Order creation failed. HTTP Status Code: ${response.statusCode}");
        throw Exception('Order creation failed');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _validateVoucher(String voucherCode) async {
    // Danh sách mã voucher hợp lệ
    const validVouchers = [
      "HDTECH2",
      "HDTECH5",
      "HDTECH7",
      "HDTECH9",
      "HDTECH10",
      "HDTECH12",
      "HDTECH14",
      "HDTECH15",
      "HDTECH18",
      "HDTECH20",
    ];

    // Kiểm tra nếu mã voucher có trong danh sách hợp lệ
    if (validVouchers.contains(voucherCode)) {
      return true;
    } else {
      logger.Logger().e("Voucher code '$voucherCode' is invalid.");
      return false;
    }
  }

  void _showVoucherDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

class CheckoutModel {
  final String userId;
  final String name;
  final String email;
  final String phone;

  CheckoutModel(
      {required this.userId,
      required this.name,
      required this.email,
      required this.phone});

  factory CheckoutModel.fromMap(Map<String, dynamic> map) {
    return CheckoutModel(
      userId: map['userId'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const WebViewScreen({super.key, required this.paymentUrl});

  @override
  // ignore: library_private_types_in_public_api
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController controller;
  late String currentUrl;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl));
    currentUrl = widget.paymentUrl;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
          (route) => false,
        );
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Payment"),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'Copy URL':
                    // Copy the current URL to clipboard
                    await Clipboard.setData(ClipboardData(text: currentUrl));
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('URL copied to clipboard')),
                    );
                    break;
                  case 'Open in Browser':
                    // Open the URL in an external browser
                    // ignore: deprecated_member_use
                    if (await canLaunch(currentUrl)) {
                      // ignore: deprecated_member_use
                      await launch(currentUrl);
                    } else {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cannot open URL')),
                      );
                    }
                    break;
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Copy URL', 'Open in Browser'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await controller.loadRequest(Uri.parse(currentUrl));
          },
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}
