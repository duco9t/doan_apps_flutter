import 'package:HDTech/Provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:HDTech/constants.dart';
import 'package:HDTech/models/computer_model.dart';
import 'package:provider/provider.dart';
import 'package:HDTech/screens/Auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddToCart extends StatefulWidget {
  final Computer popularComputerBar;

  const AddToCart({super.key, required this.popularComputerBar});

  @override
  State<AddToCart> createState() => _AddToCartState();
}

class _AddToCartState extends State<AddToCart> {
  int currentIndex = 1;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Kiểm tra trạng thái đăng nhập khi khởi tạo
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );

    // Nếu người dùng đăng nhập thành công, cập nhật trạng thái
    if (result == true) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: 75,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: const Color.fromARGB(255, 199, 199, 199),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Widget tăng giảm số lượng sản phẩm
            Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        if (currentIndex > 1) currentIndex--; // Giảm số lượng
                      });
                    },
                    iconSize: 18,
                    icon: const Icon(Icons.remove, color: Colors.white),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    currentIndex.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        currentIndex++; // Tăng số lượng
                      });
                    },
                    iconSize: 18,
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            GestureDetector(
              onTap: () async {
                // Kiểm tra xem người dùng có đăng nhập hay không
                if (!_isLoggedIn) {
                  // Nếu chưa đăng nhập, yêu cầu người dùng đăng nhập
                  bool shouldLogin = await _showLoginDialog(
                      context); // Hiển thị hộp thoại yêu cầu đăng nhập
                  if (!shouldLogin)
                    return; // Nếu người dùng không muốn đăng nhập, không làm gì
                  await _navigateToLogin(); // Điều hướng đến màn hình đăng nhập
                  if (!_isLoggedIn)
                    return; // Nếu sau khi đăng nhập người dùng vẫn chưa đăng nhập, không tiếp tục
                }

                // Lấy userId từ SharedPreferences
                final prefs = await SharedPreferences.getInstance();
                final userId = prefs.getString('id'); // Lấy userId đã lưu

                if (userId == null) {
                  // Nếu không có userId, yêu cầu người dùng đăng nhập lại hoặc thông báo lỗi

                  return;
                }

                // Nếu người dùng đã đăng nhập, thêm sản phẩm vào giỏ hàng
                final productId = widget.popularComputerBar.id
                    ?.toString(); // Lấy ID sản phẩm từ đối tượng popularComputerBar
                final quantity = currentIndex;

                // Gọi CartProvider để thêm sản phẩm vào giỏ hàng
                if (productId != null) {
                  provider.addItem(userId, productId, quantity);
                }

                // Thêm thông báo sau khi thêm vào giỏ hàng
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sản phẩm đã được thêm vào giỏ hàng')),
                );
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: kprimaryColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50),
                alignment: Alignment.center,
                child: const Text(
                  "Add to Cart",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Hiển thị hộp thoại yêu cầu đăng nhập
Future<bool> _showLoginDialog(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible:
            false, // Ngăn không cho đóng hộp thoại khi bấm ra ngoài
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiêu đề
                  Text(
                    "Login Required",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Nội dung hộp thoại
                  Text(
                    "You need to be logged in to add items to the cart. Would you like to log in now?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Các nút lựa chọn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút "No"
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(false); // Nếu người dùng chọn "No"
                        },
                        child: Text(
                          "No",
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Nút "Yes"
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(true); // Nếu người dùng chọn "Yes"
                        },
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ) ??
      false; // Trả về false nếu người dùng không chọn gì
}
