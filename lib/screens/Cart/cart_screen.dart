import 'package:HDTech/Provider/cart_provider.dart';
import 'package:HDTech/constants.dart';
import 'package:HDTech/screens/Cart/check_out.dart';
import 'package:HDTech/screens/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

final formatCurrency = NumberFormat.currency(
    locale: 'vi_VN', symbol: 'VNĐ'); // Format currency in VND

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {


  late Future<void> _fetchCartFuture;

  String? userId;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('id'); // Lấy giá trị userId từ SharedPreferences

      if (userId != null && userId!.isNotEmpty) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        _fetchCartFuture = cartProvider.fetchCart(userId!);
      } else {
        debugPrint('User ID not found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Failed to initialize cart: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, provider, child) {
        final finalList = provider.cartItems;

        // Tăng giảm số lượng sản phẩm
        Widget productQuantity(IconData icon, int index) {
          return GestureDetector(
            onTap: () {
              if (icon == Icons.add) {
                provider.incrementQuantity(
                    userId!, // Pass the actual userId
                    finalList[index].productId); // Tăng số lượng
              } else {
                provider.decrementQuantity(
                    userId!, // Pass the actual userId
                    finalList[index].productId); // Giảm số lượng
              }
            },
            child: Icon(icon, size: 20),
          );
        }

        return Scaffold(
          // cho phan tong tien va check out
          bottomSheet: const CheckOutBox(),

          backgroundColor: kcontentColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(15),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BottomNavBar(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios,
                        ),
                      ),
                      const Text(
                        "My Cart",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Container(),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: finalList.length,
                    itemBuilder: (context, index) {
                      final cartItem = finalList[index]; // Truy xuất CartItem
                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: kcontentColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Image.network(
                                      cartItem.imageUrl,
                                    ), // Hiển thị hình ảnh sản phẩm
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        '${cartItem.company}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        formatCurrency.format(cartItem.price),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 35,
                            right: 35,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    provider.removeItem(
                                        userId!,
                                        cartItem
                                            .productId); // Xóa sản phẩm khỏi giỏ hàng
                                  },
                                  icon: SvgPicture.asset(
                                    'images/icons/recycle-bin-svgrepo-com.svg',
                                    color: Colors.red,
                                    width: 22, // Điều chỉnh kích thước của icon
                                    height: 22,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: kcontentColor,
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      productQuantity(
                                          Icons.add, index), // Thêm sản phẩm
                                      const SizedBox(width: 10),
                                      Text(
                                        cartItem.quantity.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      productQuantity(
                                          Icons.remove, index), // Giảm sản phẩm
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
