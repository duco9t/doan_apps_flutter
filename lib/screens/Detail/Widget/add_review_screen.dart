import 'package:HDTech/models/account_service.dart'; // Import AccountService
import 'package:HDTech/models/review_service.dart';
import 'package:HDTech/screens/Auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPopup extends StatefulWidget {
  final String productId; // Thêm biến productId
  final Function(int, String) onPostReview; // Function to handle posting review
  final Function() onRefreshReviews; // Callback to refresh reviews

  const ReviewPopup(
      {super.key,
      required this.productId,
      required this.onPostReview,
      required this.onRefreshReviews});

  @override
  ReviewPopupState createState() => ReviewPopupState();
}

class ReviewPopupState extends State<ReviewPopup> {
  int selectedRating = 0;
  TextEditingController commentController = TextEditingController();

  // Create an instance of ReviewService
  final ReviewService reviewService = ReviewService();

  // Kiểm tra trạng thái đăng nhập
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString('access_token');
    return accessToken != null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.white,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Write a Review",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // Rating stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              // Comment input
              TextField(
                controller: commentController,
                maxLines: 4, // Allow multiple lines for the comment
                decoration: InputDecoration(
                  hintText: "Enter your comment...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white, // Background color of the TextField
                ),
              ),
              const SizedBox(height: 24),
              // Cancel and Post buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                    child: const Text("Cancel"),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedRating == 0 ||
                          commentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please rate and enter comments!")),
                        );
                      } else {
                        // Kiểm tra trạng thái đăng nhập
                        bool isLoggedIn = await _checkLoginStatus();

                        if (!isLoggedIn) {
                          // ignore: use_build_context_synchronously
                          bool shouldLogin = await _showLoginDialog(context);
                          if (!shouldLogin) {
                            return; // Nếu không muốn đăng nhập, không làm gì thêm
                          }

                          // Nếu chọn đăng nhập, điều hướng đến LoginScreen
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        } else {
                          // Nếu đã đăng nhập, lấy dữ liệu người dùng và gửi đánh giá
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String? accessToken = prefs.getString('access_token');
                          String? userId = prefs.getString('id');

                          if (accessToken != null && userId != null) {
                            // Lấy thông tin người dùng từ AccountService
                            AccountService accountService = AccountService();
                            var userDetails =
                                await accountService.getUserDetails();

                            if (userDetails != null) {
                              String username = userDetails['name'];

                              bool success = await reviewService.addReview(
                                productId: widget.productId,
                                userId: userId,
                                username: username,
                                rating: selectedRating,
                                comment: commentController.text,
                                token: accessToken,
                              );

                              if (success) {
                                widget.onRefreshReviews();
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Review posted successfully!')),
                                );
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                              } else {
                                // ignore: use_build_context_synchronously
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Evaluation failed!')),
                                );
                              }
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Unable to retrieve user information!')),
                              );
                            }
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Token or userId not found!')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 14),
                    ),
                    child: const Text(
                      "Post",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // Hiển thị hộp thoại yêu cầu đăng nhập
  Future<bool> _showLoginDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
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
                    const Text(
                      "Login Required",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You need to be logged in to post a review. Would you like to log in now?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "No",
                            style: TextStyle(
                              color: Colors.red[400],
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Yes",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
        false;
  }
}
