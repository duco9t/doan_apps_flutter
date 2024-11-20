import 'package:HDTech/models/cart_model.dart';

class CheckoutDetails {
  final List<CartItem> products;
  final double totalPrice;
  final double vatOrder;
  final double shippingFee;
  final double orderTotal;

  CheckoutDetails({
    required this.products,
    required this.totalPrice,
    required this.vatOrder,
    required this.shippingFee,
    required this.orderTotal,
  });

  factory CheckoutDetails.fromJson(Map<String, dynamic> json) {
    // Calculate base total price from JSON
    final basePrice = json['totalPrice'].toDouble();

    // Fixed VAT rate (10% of total price)
    final calculatedVAT = basePrice * 0.1;

    // Shipping fee calculation based on total price
    final calculatedShippingFee = calculateShippingFee(basePrice);

    // Calculate final order total
    final calculatedOrderTotal = basePrice + calculatedVAT + calculatedShippingFee;

    return CheckoutDetails(
      products: (json['products'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalPrice: basePrice,
      vatOrder: calculatedVAT,
      shippingFee: calculatedShippingFee,
      orderTotal: calculatedOrderTotal,
    );
  }

  // Helper method to calculate shipping fee based on order value
  static double calculateShippingFee(double totalPrice) {
    if (totalPrice >= 50000000) {  // Over 50M VND
      return 0.0;  // Free shipping
    } else if (totalPrice >= 20000000) {  // Over 20M VND
      return 30000.0;  // 30k VND shipping
    } else {
      return 50000.0;  // Standard 50k VND shipping
    }
  }
}