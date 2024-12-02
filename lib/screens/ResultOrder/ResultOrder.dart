// ignore: file_names
// ignore_for_file: file_names, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:HDTech/screens/nav_bar_screen.dart';

class ResultOrder extends StatelessWidget {
  const ResultOrder({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng màu xanh đậm thay vì màu xám
    const Color primaryTextColor = Color(0xFF1E3A8A);
    const Color secondaryTextColor = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Thêm container với shadow cho image
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/done.gif',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              // Thêm container với gradient cho text đầu tiên
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.1),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "The order has been successfully placed! 🎉",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: primaryTextColor,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Text thứ hai với style mới
              const Text(
                "The shop will soon prepare and ship your order to you in the next few days.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: secondaryTextColor,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 40),
              // Button với gradient và animation
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD70018), Color(0xFFFF1744)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD70018).withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavBar()),
    );
  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Return to Home",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}