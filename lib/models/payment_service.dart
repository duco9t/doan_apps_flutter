import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/config.dart'; // Đảm bảo bạn đã import file chứa `Config.baseUrl`

class PaymentRequest {
  final String orderId;
  final String returnUrl;

  PaymentRequest({required this.orderId, required this.returnUrl});

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'returnUrl': returnUrl,
    };
  }
}

class PaymentResponse {
  final String paymentURL;

  PaymentResponse({required this.paymentURL});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(paymentURL: json['paymentURL']);
  }
}

class PaymentService {
  static Future<PaymentResponse> createPayment(PaymentRequest request) async {
    final url = Uri.parse('${Config.baseUrl}/payments/create_payment');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PaymentResponse.fromJson(data);
    } else {
      throw Exception('Failed to create payment');
    }
  }
}
