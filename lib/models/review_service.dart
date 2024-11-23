import 'dart:convert';

import 'package:HDTech/models/config.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; // Import logger package

class ReviewService {
  // Create a logger instance
  final Logger logger = Logger();

  Future<bool> addReview({
    required String productId,
    required String userId,
    required String username,
    required int rating,
    required String comment,
    required String token, // Added token parameter
  }) async {
    final url =
        Uri.parse('${Config.baseUrl}/review/$productId/add-review/$userId');

    // Log the values to check if they are correct
    logger.d('Sending review data:');
    logger.d('Product ID: $productId');
    logger.d('User ID: $userId');
    logger.d('Username: $username');
    logger.d('Rating: $rating');
    logger.d('Comment: $comment');
    logger.d('Token: $token'); // Log token for debugging

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer $token', // Add token to the Authorization header
        },
        body: json.encode({
          "username": username,
          "rating": rating,
          "comment": comment,
        }),
      );

      // Log response status and body for debugging
      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully posted the review
        final jsonResponse = json.decode(response.body);

        // Check if the response contains the success message
        if (jsonResponse['message'] == 'Thêm đánh giá thành công!') {
          logger.d('Review posted successfully: ${jsonResponse['message']}');
          return true;
        } else {
          logger.e('API response error: ${jsonResponse['message']}');
        }
      } else {
        logger.e('Failed to send review. Status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error sending review: $e'); // Catch any errors
    }
    return false;
  }
}
