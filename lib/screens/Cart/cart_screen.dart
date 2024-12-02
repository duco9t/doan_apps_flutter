import 'package:HDTech/Provider/cart_provider.dart';
import 'package:HDTech/constants.dart';
import 'package:HDTech/screens/Cart/check_out.dart';
import 'package:HDTech/screens/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final formatCurrency = NumberFormat.currency(
    locale: 'vi_VN', symbol: 'đ'); // Format currency in VND

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
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
        // ignore: use_build_context_synchronously
        Provider.of<CartProvider>(context, listen: false);
      } else {
        debugPrint('User ID not found in SharedPreferences');
      }
    } catch (e) {
      debugPrint('Failed to initialize cart: $e');
    }
  }

  // Hàm refresh giỏ hàng
  Future<void> _refreshCart() async {
    await Provider.of<CartProvider>(context, listen: false).fetchCart(userId!);
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
                    userId!, finalList[index].productId); // Tăng số lượng
              } else {
                provider.decrementQuantity(
                    userId!, finalList[index].productId); // Giảm số lượng
              }
            },
            child: Icon(icon, size: 20),
          );
        }

        return Scaffold(
          backgroundColor: kcontentColor,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _refreshCart, // Hàm làm mới giỏ hàng
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
                  // Wrap ListView.builder in Expanded to allow scrolling
                  SizedBox(
                    height: 500,
                    child: ListView.builder(
                      shrinkWrap:
                          true, // Cho phép cuộn danh sách mà không bị giới hạn
                      itemCount: finalList.length,
                      itemBuilder: (context, index) {
                        final cartItem = finalList[index];
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
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            20), // Bo góc ảnh
                                        child: Image.network(
                                          cartItem.imageUrl,
                                          fit: BoxFit
                                              .cover, // Giữ tỉ lệ ảnh và bao phủ toàn bộ vùng hiển thị
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.name.length > 20
                                              ? '${cartItem.name.substring(0, 20)}...' // Cắt chuỗi và thêm "..."
                                              : cartItem.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          cartItem.company,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          formatCurrency
                                              .format(cartItem.promotionPrice),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: kPrimaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (cartItem.price !=
                                                cartItem.promotionPrice ||
                                            cartItem.discount != 0)
                                          Row(
                                            children: [
                                              if (cartItem.price !=
                                                  cartItem.promotionPrice)
                                                Text(
                                                  formatCurrency
                                                      .format(cartItem.price),
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              const SizedBox(width: 8),
                                              if (cartItem.discount != 0)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFFFD0D0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                  ),
                                                  child: Text(
                                                    '-${cartItem.discount.toStringAsFixed(0)}%',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: kPrimaryColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                            ],
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
                                      // ignore: deprecated_member_use
                                      color: Colors.red,
                                      width: 22,
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
                                        productQuantity(Icons.remove,
                                            index), // Giảm sản phẩm
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
          ),
          bottomSheet: const CheckOutBox(), // Phần checkout vẫn giữ nguyên
        );
      },
    );
  }
}
