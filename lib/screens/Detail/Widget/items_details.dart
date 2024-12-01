import 'package:HDTech/models/computer_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for currency formatting

class ItemsDetails extends StatelessWidget {
  final Computer popularComputerBar;

  const ItemsDetails({
    super.key,
    required this.popularComputerBar,
  });

  @override
  Widget build(BuildContext context) {
    // Format the price using the Vietnamese currency format
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Padding(
      padding: const EdgeInsets.all(10.0), // Overall padding for content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display productsTypeName before name
          Text(
            "${popularComputerBar.company} ${popularComputerBar.name}",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 25,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),

          // Product price and discount
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Discounted price
              Text(
                formatCurrency.format(popularComputerBar.promotionPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.red,
                ),
              ),
              // Original price and discount percentage
              if (popularComputerBar.price !=
                      popularComputerBar.promotionPrice &&
                  popularComputerBar.discount > 0)
                Row(
                  children: [
                    // Original price (crossed out)
                    Text(
                      formatCurrency.format(popularComputerBar.price),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Discount percentage
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2), // Padding for better spacing
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD0D0), // Light red background
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${popularComputerBar.discount.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          // "Description:" title
          const Text(
            "Description:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 1.2,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10), // Space between title and content

          // List of product attributes
          _buildDetailRow("Type: ", popularComputerBar.productsTypeName),
          _buildDetailRow("Quantity in Stock: ",
              popularComputerBar.quantityInStock.toString()),
          _buildDetailRow(
              "Screen Size: ", "${popularComputerBar.inches} inches"),
          _buildDetailRow(
              "Screen Resolution: ", popularComputerBar.screenResolution),
          _buildDetailRow("CPU: ", popularComputerBar.cpu),
          _buildDetailRow("RAM: ", popularComputerBar.ram),
          _buildDetailRow("Memory: ", popularComputerBar.memory),
          _buildDetailRow("GPU: ", popularComputerBar.gpu),
          _buildDetailRow("Weight: ", popularComputerBar.weight),
          _buildDetailRow("Operating System: ", popularComputerBar.opsys),
        ],
      ),
    );
  }

  // Method to build detail rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0), // Space between rows
      child: Row(
        children: [
          // Label
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
            ),
          ),
          // Value
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
