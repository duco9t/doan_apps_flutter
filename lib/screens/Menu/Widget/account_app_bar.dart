import 'package:HDTech/models/account_service.dart';
import 'package:HDTech/models/user_model.dart'; // Assuming you have the User model
import 'package:HDTech/screens/Menu/Popup_accounts/delete_account.dart';
import 'package:HDTech/screens/Menu/Popup_accounts/information_app.dart';
import 'package:HDTech/screens/Menu/Popup_accounts/order_status.dart';
import 'package:HDTech/screens/Menu/Popup_accounts/update_user_popup.dart'; // Add this import for the popup
import 'package:HDTech/screens/nav_bar_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic>? _userDetails;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget is initialized
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Update login status
    await prefs.remove('email'); // Remove saved email
    await prefs.remove('password'); // Remove saved password
    await prefs.remove('access_token'); // Remove saved access_token
    await prefs.remove('id'); // Remove saved id

    // Navigate to the login screen
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const BottomNavBar()),
    );
  }

  Future<void> _loadUserData() async {
    AccountService accountService = AccountService();
    _userDetails = await accountService.getUserDetails();

    // Ensure that the phone field is converted to a string
    if (_userDetails != null) {
      _userDetails!['phone'] = _userDetails!['phone'].toString();
    }

    setState(() {}); // Refresh the UI
  }

  Future<void> _showUpdateUserPopup() async {
    if (_userDetails != null) {
      final user = User(
        userId: _userDetails!['userId'] is String
            ? _userDetails!['userId']
            : _userDetails!['userId'].toString(),
        name: _userDetails!['name'] ?? 'Unknown',
        email: _userDetails!['email'] ?? 'unknown@unknown.com',
        phone: _userDetails!['phone'].toString(), // Convert phone to string
      );

      // Show UpdateUserPopup dialog
      final updatedUser = await showDialog<User>(
        context: context,
        builder: (BuildContext context) {
          return UpdateUserPopup(
            user: user,
            onSave: (updatedUser) async {
              // Handle saving updated user when saved
              await _saveUpdatedUser(updatedUser);
            },
          );
        },
      );

      // If there's an updated user, refresh data
      if (updatedUser != null) {
        _saveUpdatedUser(updatedUser);
      }
    }
  }

  Future<void> _saveUpdatedUser(User updatedUser) async {
    // Add your logic to save the updated user information
    // For example, send the data to the server or update SharedPreferences.
    // After saving, reload user data
    setState(() {
      _userDetails = {
        'userId': updatedUser.userId,
        'name': updatedUser.name,
        'email': updatedUser.email,
        'phone': updatedUser.phone,
      };
    });
  }

  Widget _buildAccountButton(
      String title, String iconPath, VoidCallback onPressed) {
    return ZoomTapAnimation(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 243, 243, 243),
          padding: const EdgeInsets.all(12),
          minimumSize: const Size(150, 50), // Minimum size
        ),
        onPressed: onPressed,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(iconPath, height: 30),
                const SizedBox(width: 12), // Space between icon and text
                Text(
                  title,
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                ),
              ],
            ),
            SvgPicture.asset(
              "images/icons/alt-arrow-right-svgrepo-com.svg",
              height: 30, // Icon on the right
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 20),

          // Account information button
          ZoomTapAnimation(
            child: TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0),
                minimumSize: const Size(150, 50),
              ),
              onPressed: _showUpdateUserPopup, // Open the update popup
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red[600]!, Colors.red[200]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            "images/dell-alienware-x16-2024.jpg",
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userDetails?['name'] != null &&
                                      _userDetails!['name'].length > 14
                                  ? '${_userDetails!['name'].substring(0, 14)}...'
                                  : _userDetails?['name'] ?? 'Unknown',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userDetails?['email'] != null &&
                                      _userDetails!['email'].length > 20
                                  ? '${_userDetails!['email'].substring(0, 20)}...'
                                  : _userDetails?['email'] ??
                                      'unknown@unknown.com',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SvgPicture.asset(
                      "images/icons/ruler-cross-pen-svgrepo-com.svg",
                      height: 25,
                      // ignore: deprecated_member_use
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Button for Information Settings
          _buildAccountButton(
            'Information',
            "images/icons/danger-circle-svgrepo-com.svg",
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Information()),
              );
            },
          ),
          const SizedBox(height: 16),

          // Button for Order status
          _buildAccountButton(
              'Order status', "images/icons/cart-2-svgrepo-com.svg", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const OrderStatusPage()),
            );
          }),
          const SizedBox(height: 16),

          // Button for Payment Info
          _buildAccountButton(
              'Payment Info', "images/icons/wallet-svgrepo-com.svg", () {}),
          const SizedBox(height: 16),

          // Button for Delete Account
          _buildAccountButton(
            'Delete Account',
            "images/icons/trash-bin-trash-svgrepo-com.svg",
            () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DeleteAccount()));
            },
          ),

          const SizedBox(height: 16),

          // Logout button
          ZoomTapAnimation(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 243, 243, 243),
                padding: const EdgeInsets.all(12),
                minimumSize: const Size(150, 50),
              ),
              onPressed: () => _logout(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("images/icons/logout-3-svgrepo-com.svg",
                          height: 30),
                      const SizedBox(width: 12),
                      const Text(
                        'Logout',
                        style: TextStyle(fontSize: 17, color: Colors.black),
                      ),
                    ],
                  ),
                  SvgPicture.asset(
                      "images/icons/alt-arrow-right-svgrepo-com.svg",
                      height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
