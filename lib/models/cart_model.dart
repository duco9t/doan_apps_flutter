class CartItem {
  String productId;
  String name;
  int quantity;
  final double price;
  final String imageUrl;
  final String company;
  final String quantityInStock;
  final double discount;
  final double promotionPrice;

  CartItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
    required this.company,
    required this.quantityInStock,
    required this.discount,
    required this.promotionPrice,
  });

  // Getter to calculate the total price of the cart item (price * quantity)
  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final productData = json['productId'] as Map<String, dynamic>? ?? {};

    return CartItem(
      productId: productData['_id'] as String? ?? 'No ID', // Giá trị mặc định
      name: productData['name'] as String? ?? 'No name', // Giá trị mặc định
      quantity: json['quantity'] as int? ?? 0,
      price: (productData['prices'] as num?)?.toDouble() ?? 0.0,
      imageUrl:
          productData['imageUrl'] as String? ?? 'No image', // Giá trị mặc định
      company:
          productData['company'] as String? ?? 'No Company', // Giá trị mặc định
      quantityInStock: productData['quantityInStock']?.toString() ??
          'No quantity', // Giá trị mặc định
      discount: (productData['discount'] as num?)?.toDouble() ?? 0.0,
      promotionPrice:
          (productData['promotionPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'imageUrl': imageUrl,
      'company': company,
      'quantityInStock': quantityInStock,
      'discount': discount,
      'promotionPrice': promotionPrice,
    };
  }
}
