import 'package:HDTech/constants.dart';
import 'package:HDTech/models/computer_model.dart';
import 'package:HDTech/screens/Detail/detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PopularComputerBar extends StatefulWidget {
  final String searchQuery;

  const PopularComputerBar({super.key, required this.searchQuery});

  @override
  PopularComputerBarState createState() => PopularComputerBarState();
}

class PopularComputerBarState extends State<PopularComputerBar> {
  late Future<List<Computer>> futureComputers;

  @override
  void initState() {
    super.initState();
    futureComputers = loadComputers();
  }

  Future<void> _refreshComputers() async {
    setState(() {
      futureComputers = loadComputers();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        final filteredComputers = computers.where((computer) {
          final query = widget.searchQuery.toLowerCase();
          return computer.name.toLowerCase().contains(query) ||
              computer.productsTypeName.toLowerCase().contains(query) ||
              computer.company
                  .toLowerCase()
                  .contains(query); // Tìm kiếm theo company
        }).toList();

        return RefreshIndicator(
          onRefresh: _refreshComputers,
          child: GridView.builder(
            padding: const EdgeInsets.only(
              left: 20.0, // Padding bên trái
              right: 20.0, // Padding bên phải
              bottom:
                  70.0, // Padding bên dưới để tránh bị che bởi BottomNavigationBar
            ),
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              childAspectRatio: 0.80,
            ),
            itemCount: filteredComputers.length,
            itemBuilder: (context, index) {
              final computer = filteredComputers[index];
              return ComputerItem(computer: computer);
            },
          ),
        );
      },
    );
  }
}

class ComputerItem extends StatefulWidget {
  final Computer computer;

  const ComputerItem({super.key, required this.computer});

  @override
  State<ComputerItem> createState() => _ComputerItemState();
}

class _ComputerItemState extends State<ComputerItem> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return GestureDetector(
      onTapDown: (_) => setState(() => scale = 0.95),
      onTapUp: (_) {
        setState(() => scale = 1.0);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DetailScreen(popularComputerBar: widget.computer),
          ),
        );
      },
      onTapCancel: () => setState(() => scale = 1.0),
      child: Transform.scale(
        scale: scale,
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
                  // Product Image
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.computer.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Product Name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${widget.computer.company} ${widget.computer.name}', // Display productsTypeName before name
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Price and Discount
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discounted Price
                        Text(
                          formatCurrency.format(widget.computer.promotionPrice),
                          style: const TextStyle(
                            fontSize: 18,
                            color: kprimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Original Price and Discount Percentage
                        if (widget.computer.price !=
                                widget.computer.promotionPrice &&
                            widget.computer.discount > 0)
                          Row(
                            children: [
                              // Original Price (crossed out)
                              Text(
                                formatCurrency.format(widget.computer.price),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Discount Percentage
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(
                                      0xFFFFD0D0), // Light red background
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${widget.computer.discount.toStringAsFixed(0)}%',
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
