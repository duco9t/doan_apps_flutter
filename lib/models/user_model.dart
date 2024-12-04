import 'dart:convert';

import 'package:HDTech/models/config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; // Import the logger package
import 'package:shared_preferences/shared_preferences.dart';

var logger = Logger();

class User {
  final String userId;
  final String name;
  final String email;
  final String phone;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['_id'], // Adjust if the actual response field is different
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}

class UserService {
  // ignore: body_might_complete_normally_nullable
  Future<Map<String, dynamic>?> getUserDetails() async {
    logger.d('Getting user details...');

    // Get SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('id');
    String? accessToken = prefs.getString('access_token');

    // Log values from SharedPreferences
    logger.d('UserId from SharedPreferences: $userId');
    logger.d('AccessToken from SharedPreferences: $accessToken');

    if (userId == null || accessToken == null) {
      logger.e('Either UserId or AccessToken is null');
      return null;
    }

    // Make GET request to API
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/user/get-details/$userId'),
      headers: {
        'token': 'Bearer $accessToken', // Thêm dòng này để gửi token
      },
    );

    // Log status and response
    logger.d('Response Status Code: ${response.statusCode}');
    logger.d('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      logger.d('API Response: ${jsonResponse.toString()}');

      if (jsonResponse['status'] == 'Oke' && jsonResponse['data'] != null) {
        logger.d('User data retrieved: ${jsonResponse['data']}');
        // Kiểm tra kỹ các trường trong 'data'
        if (jsonResponse['data']['_id'] != null) {
          // Xử lý tiếp
        } else {
          logger.e('User data is incomplete');
        }
        return jsonResponse['data'];
      } else {
        logger.e('Error in response data: ${jsonResponse['massage']}');
        return null;
      }
    }
  }

  Future<bool> updateUserDetails(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    logger.d('Updating user details...');

    if (userId.isEmpty) {
      logger.e('UserId is empty');
      return false;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedUserId = prefs.getString('id');
    if (storedUserId == null) {
      logger.e('No userId found in SharedPreferences');
      return false;
    }

    logger.d('Stored UserId from SharedPreferences: $storedUserId');

    // Make PUT request to update user details
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/user/update-user/$storedUserId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(userData),
    );

    // Log status and response
    logger.d('Response Status Code: ${response.statusCode}');
    logger.d('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      logger.d('API Response for update: ${jsonResponse.toString()}');

      if (jsonResponse['status'] == 'Success') {
        logger.i('User updated successfully');
        return true;
      } else {
        logger.e('Failed to update user: ${jsonResponse['message']}');
        return false;
      }
    } else {
      logger.e(
          'Failed to make update request with status code: ${response.statusCode}');
      return false;
    }
  }
}
