import 'package:HDTech/models/account_service.dart';
import 'package:HDTech/models/computer_model.dart';
import 'package:HDTech/models/review_model.dart';
import 'package:HDTech/models/review_service.dart';
import 'package:HDTech/models/user_model.dart';
import 'package:HDTech/screens/Detail/Widget/add_review_screen.dart';
import 'package:HDTech/screens/Detail/Widget/addto_cart.dart';
import 'package:HDTech/screens/Detail/Widget/detail_app_bar.dart';
import 'package:HDTech/screens/Detail/Widget/image_slider.dart';
import 'package:HDTech/screens/Detail/Widget/items_details.dart';
import 'package:HDTech/screens/Detail/Widget/product_review.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailScreen extends StatefulWidget {
  final Computer popularComputerBar;

  const DetailScreen({super.key, required this.popularComputerBar});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Map<String, dynamic>> reviewData;
  late Future<User?> userData;

  @override
  void initState() {
    super.initState();
    reviewData = fetchReviews(widget.popularComputerBar.id);
  }

  int currentImage = 0;

  // Hàm làm mới dữ liệu đánh giá
  void refreshReviews() {
    setState(() {
      reviewData = fetchReviews(
          widget.popularComputerBar.id); // Lấy lại dữ liệu đánh giá
    });
  }

  // Hàm kiểm tra thông tin người dùng và mở dialog đánh giá
  Future<void> _handleReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    String? accessToken = prefs.getString('access_token');

    if (userId != null && accessToken != null) {
      // Lấy thông tin người dùng
      AccountService accountService = AccountService();
      var userDetails = await accountService.getUserDetails();

      if (userDetails != null) {
        String username = userDetails['name'];

        // Mở dialog Write a Review và truyền các tham số
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) {
            return ReviewPopup(
              productId:
                  widget.popularComputerBar.id, // Truyền productId vào đây
              onPostReview: (rating, comment) async {
                bool success = await ReviewService().addReview(
                  productId: widget.popularComputerBar.id,
                  userId: userId,
                  username: username,
                  rating: rating,
                  comment: comment,
                  token: accessToken,
                );

                if (success) {
                  // Nếu đánh giá thành công, làm mới dữ liệu
                  refreshReviews();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(); // Đóng dialog
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Review posted successfully!'),
                      behavior: SnackBarBehavior
                          .floating, // Đảm bảo SnackBar không đẩy lên
                      margin: EdgeInsets.fromLTRB(
                          10, 10, 10, 70), // Thêm khoảng cách dưới
                    ),
                  );
                } else {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to post review!'),
                      behavior: SnackBarBehavior
                          .floating, // Đảm bảo SnackBar không đẩy lên
                      margin: EdgeInsets.fromLTRB(
                          10, 10, 10, 70), // Thêm khoảng cách dưới
                    ),
                  );
                }
              },
              onRefreshReviews: refreshReviews, // Truyền hàm làm mới ở đây
            );
          },
        );
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to retrieve user information!'),
            behavior:
                SnackBarBehavior.floating, // Đảm bảo SnackBar không đẩy lên
            margin:
                EdgeInsets.fromLTRB(10, 10, 10, 70), // Thêm khoảng cách dưới
          ),
        );
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No user information found!'),
          behavior: SnackBarBehavior.floating, // Đảm bảo SnackBar không đẩy lên
          margin: EdgeInsets.fromLTRB(10, 10, 10, 70), // Thêm khoảng cách dưới
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AddToCart(popularComputerBar: widget.popularComputerBar),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              expandedHeight: 60,
              pinned: true,
              backgroundColor: Colors.white,
              title: DetailAppBar(),
              automaticallyImplyLeading: false,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 20),
                MyImageSlider(
                  images: [widget.popularComputerBar.imageUrl],
                  onChange: (index) {
                    setState(() {
                      currentImage = index;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(40),
                      topLeft: Radius.circular(40),
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemsDetails(
                          popularComputerBar: widget.popularComputerBar),
                      const SizedBox(height: 20),
                      FutureBuilder<Map<String, dynamic>>(
                        future: reviewData,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Unable to load review.'));
                          } else if (snapshot.hasData) {
                            final data = snapshot.data!;
                            final reviews = data['reviews'] as List<Review>;
                            final averageRating =
                                (data['averageRating'] as num).toDouble();

                            return Column(
                              children: [
                                ProductReviews(
                                  reviews: reviews,
                                  averageRating: averageRating,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _handleReview,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 20),
                                    minimumSize:
                                        const Size(double.infinity, 60),
                                  ),
                                  child: const Text("Write a Review"),
                                ),
                              ],
                            );
                          } else {
                            return const Center(child: Text('No reviews.'));
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 80,
                  child: const Center(),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
