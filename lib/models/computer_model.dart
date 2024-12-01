import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'config.dart'; // Import Config for base URL

class Computer {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String company;
  final String cpu;
  final String ram;
  final String memory;
  final String gpu;
  final String weight;
  final String screenResolution;
  final String inches;
  final String quantityInStock;
  final String opsys; // New field for operating system
  final String productsTypeName; // New field for product type name
  int quantity;
  final String? bannerUrl; // Thêm bannerUrl, có thể null
  final double discount;
  final double promotionPrice;

  Computer({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.company,
    required this.cpu,
    required this.ram,
    required this.memory,
    required this.gpu,
    required this.weight,
    required this.screenResolution,
    required this.inches,
    required this.quantityInStock,
    required this.opsys,
    required this.productsTypeName,
    this.quantity = 1,
    this.bannerUrl,
    required this.discount,
    required this.promotionPrice,
  });

  // Add this toJson method to resolve the error
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'ram': ram,
      'cpu': cpu,
      'gpu': gpu,
      'memory': memory,
      'price': price,
      'discount': discount,
      'promotionPrice': promotionPrice,
    };
  }

  factory Computer.fromJson(Map<String, dynamic> json) {
    return Computer(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Computer',
      imageUrl:
          json['imageUrl'] as String? ?? 'https://via.placeholder.com/150',
      price: (json['prices'] as num?)?.toDouble() ?? 0.0,
      company: json['company'] as String? ?? 'Unknown Company',
      cpu: json['cpu'] as String? ?? 'Unknown CPU',
      ram: json['ram'] as String? ?? 'Unknown RAM',
      memory: json['memory'] as String? ?? 'Unknown Memory',
      gpu: json['gpu'] as String? ?? 'Unknown GPU',
      weight: json['weight'] as String? ?? 'Unknown Weight',
      screenResolution:
          json['screenResolution'] as String? ?? 'Unknown Resolution',
      inches: json['inches'] as String? ?? 'Unknown Size',
      quantityInStock:
          json['quantityInStock'].toString(), // Ensure quantity as String
      opsys: json['opsys'] as String? ?? 'Unknown OS', // Parsing opsys
      productsTypeName: json['productsTypeName'] as String? ??
          'Unknown Type', // Parsing productsTypeName
      quantity: json['quantity'] ?? 1, // Số lượng khi tạo từ JSON
      bannerUrl: json['bannerUrl'] as String?, // Nếu không có thì null
      discount:
          json['discount'] is num ? (json['discount'] as num).toDouble() : 0,
      promotionPrice: json['promotionPrice'] != null
          ? (json['promotionPrice'] as num).toDouble()
          : 0.0,
    );
  }
}

Future<List<Computer>> loadComputers({Map<String, dynamic>? filters}) async {
  final response =
      await http.get(Uri.parse('${Config.baseUrl}/product/getAllProduct'));

  if (response.statusCode == 200) {
    try {
      final jsonResponse = json.decode(response.body);
      final data = jsonResponse['data'] as List;
      var computers = data.map((json) => Computer.fromJson(json)).toList();

      if (filters != null && filters.isNotEmpty) {
        computers = computers.where((computer) {
          bool matches = true;
          filters.forEach((field, value) {
            if (field == 'price') {
              // Handle price filter as a range
              if (value is RangeValues) {
                matches &= (computer.price >= value.start &&
                    computer.price <= value.end);
              }
            } else if (value is List) {
              // For list filters (company, ram, etc.), check if the value is in the list
              matches &= value.contains(computer.toJson()[field]?.toString());
            } else {
              // For exact match filters (like productTypeName), check equality
              matches &=
                  computer.toJson()[field]?.toString() == value?.toString();
            }
          });
          return matches;
        }).toList();
      }

      return computers;
    } catch (e) {
      throw Exception('Failed to parse computers: $e');
    }
  } else {
    throw Exception(
        'Failed to load computers, status code: ${response.statusCode}');
  }
}
