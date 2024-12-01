import 'package:HDTech/models/cart_model.dart';

class CheckoutDetails {
  final String cartId;
  final List<CartItem> products;
  final double totalPrice;
  // ignore: non_constant_identifier_names
  final double VATorder;
  final double shippingFee;
  final double orderTotal;

  CheckoutDetails({
    required this.cartId,
    required this.products,
    required this.totalPrice,
    // ignore: non_constant_identifier_names
    required this.VATorder,
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
    final cartId = json['_id'];

    return CheckoutDetails(
      cartId: cartId,
      products: (json['products'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalPrice: basePrice,
      VATorder: calculatedVAT,
      shippingFee: calculatedShippingFee,
      orderTotal: calculatedOrderTotal,
    );
  }

  // Helper method to calculate shipping fee based on order value
  static double calculateShippingFee(double totalPrice) {
    if (totalPrice > 50000000) { 
      return 0.0;  
    } else {
      return 800000.0;  
    }
  }
}