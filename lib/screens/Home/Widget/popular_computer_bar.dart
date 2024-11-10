import 'package:HDTech/constants.dart';
import 'package:HDTech/models/computer_model.dart';
import 'package:HDTech/screens/Detail/detail_screen.dart';
import 'package:HDTech/Provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:HDTech/screens/Auth/login_screen.dart';

class PopularComputerBar extends StatefulWidget {
  final bool isRefreshing;

  const PopularComputerBar({super.key, this.isRefreshing = false});

  @override
  PopularComputerBarState createState() => PopularComputerBarState();
}

class PopularComputerBarState extends State<PopularComputerBar> {
  late Future<List<Computer>> futureComputers;
  late List<double> scales;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    futureComputers = loadComputers();
    scales = [];
    _checkLoginStatus(); // Kiểm tra trạng thái đăng nhập khi khởi tạo
  }

  void reloadComputers() {
    setState(() {
      futureComputers = loadComputers();
    });
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

// Hàm hiển thị hộp thoại yêu cầu đăng nhập
  Future<bool> _showLoginDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible:
              false, // Ngăn không cho đóng hộp thoại khi bấm ra ngoài
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
              backgroundColor: Colors.white,
              contentPadding: const EdgeInsets.all(
                  20), // Thêm padding cho nội dung hộp thoại
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tiêu đề
                  const Center(
                    child: Text(
                      "Login Required",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
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
            );
          },
        ) ??
        false; // Trả về false nếu người dùng không chọn gì
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context,
        listen: false); // Khai báo provider để sử dụng addToCart

    return FutureBuilder<List<Computer>>(
      future: futureComputers,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No computers found.'));
        }

        final computers = snapshot.data!;

        if (scales.length != computers.length) {
          scales = List<double>.filled(computers.length, 1.0);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Transform.translate(
            offset: const Offset(0, -25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: computers.length,
                  itemBuilder: (context, index) {
                    final computer = computers[index];
                    return GestureDetector(
                      onTapDown: (_) {
                        setState(() {
                          scales[index] = 0.95;
                        });
                      },
                      onTapUp: (_) {
                        setState(() {
                          scales[index] = 1.0;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              popularComputerBar: computer,
                            ),
                          ),
                        );
                      },
                      onTapCancel: () {
                        setState(() {
                          scales[index] = 1.0;
                        });
                      },
                      child: Transform.scale(
                        scale: scales[index],
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: NetworkImage(computer.imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      '${computer.productsTypeName} - ${computer.name}', // Concatenate productsTypeName and name
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(
                                      NumberFormat.currency(
                                              locale: 'vi_VN', symbol: 'VNĐ')
                                          .format(computer.price),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: kprimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () async {
                                  // Kiểm tra nếu chưa đăng nhập, hiển thị hộp thoại yêu cầu đăng nhập
                                  if (!_isLoggedIn) {
                                    bool shouldLogin =
                                        await _showLoginDialog(); // Hiển thị hộp thoại
                                    if (!shouldLogin)
                                      return; // Nếu người dùng không muốn đăng nhập, không làm gì
                                    await _navigateToLogin(); // Nếu người dùng đồng ý đăng nhập, điều hướng đến màn hình đăng nhập
                                    if (!_isLoggedIn)
                                      return; // Nếu sau khi đăng nhập, người dùng vẫn chưa đăng nhập, không tiếp tục
                                  }

                                  provider.addToCart(computer,
                                      quantity:
                                          1); // Thêm sản phẩm vào giỏ hàng

                                  // Hiển thị SnackBar để xác nhận
                                  final snackBar = SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "Successfully added to cart!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green[500],
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    action: SnackBarAction(
                                      label: 'Close',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ScaffoldMessenger.of(context)
                                            .hideCurrentSnackBar();
                                      },
                                    ),
                                    duration: const Duration(seconds: 1),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                  );

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: const BoxDecoration(
                                    color: kprimaryColor,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
