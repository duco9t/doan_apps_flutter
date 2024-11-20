import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

class Review {
  final String userId;
  final String username;
  final int rating;
  final String comment;
  final String id;
  final DateTime createdAt;
  final List<Reply> replies;

  Review({
    required this.userId,
    required this.username,
    required this.rating,
    required this.comment,
    required this.id,
    required this.createdAt,
    required this.replies,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      userId: json['userId'] ?? '',
      username: json['username'] ?? 'Unknown User',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      id: json['_id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      replies: (json['replies'] as List<dynamic>?)
              ?.map((replyJson) => Reply.fromJson(replyJson))
              .toList() ??
          [],
    );
  }
}

class Reply {
  final String userId;
  final String username;
  final String comment;
  final String id;
  final DateTime createdAt;

  Reply({
    required this.userId,
    required this.username,
    required this.comment,
    required this.id,
    required this.createdAt,
  });

  factory Reply.fromJson(Map<String, dynamic> json) {
    return Reply(
      userId: json['userId']['_id'] ?? '',
      username: json['username'] ?? 'Unknown User',
      comment: json['comment'] ?? '',
      id: json['_id'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

Future<Map<String, dynamic>> fetchReviews(String productId) async {
  final response = await http.get(
    Uri.parse('${Config.baseUrl}/review/get-review/$productId'),
  );

  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    final reviews = (jsonResponse['reviews'] as List<dynamic>?)
            ?.map((json) => Review.fromJson(json))
            .toList() ??
        [];
    final averageRating = jsonResponse['averageRating'] ?? 0.0;

    return {
      'reviews': reviews,
      'averageRating': averageRating,
    };
  } else {
    throw Exception('Failed to fetch reviews: ${response.statusCode}');
  }
}
