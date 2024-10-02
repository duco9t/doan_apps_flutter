import 'package:flutter/material.dart';
import 'package:flutter_application_1/constants.dart';

class TrademarkAppBar extends StatefulWidget {
  const TrademarkAppBar({super.key});

  @override
  TrademarkAppBarState createState() => TrademarkAppBarState();
}

class TrademarkAppBarState extends State<TrademarkAppBar> {
  String selectedBrand = 'Alienware';
  void updateSelectedBrand(String brandName) {
    setState(() {
      selectedBrand = brandName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  updateSelectedBrand('Alienware');
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      top: 6, left: 6, right: 16, bottom: 6),
                  decoration: ShapeDecoration(
                    color: selectedBrand == 'Alienware'
                        ? kprimaryColor
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 42,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: Image.asset(
                              'images/logo-alienware.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (selectedBrand == 'Alienware')
                        const Text(
                          'Alienware',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Airbnb Cereal App',
                            fontWeight: FontWeight.w500,
                            height: 0.08,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              ...List.generate(3, (index) {
                String imagePath;
                String brandName;

                switch (index) {
                  case 0:
                    imagePath = 'images/logo-msi.png';
                    brandName = 'MSI';
                    break;
                  case 1:
                    imagePath = 'images/logo-asus.png';
                    brandName = 'Asus';
                    break;
                  case 2:
                    imagePath = 'images/logo_dell.png';
                    brandName = 'Dell';
                    break;
                  default:
                    imagePath = '';
                    brandName = '';
                }

                return GestureDetector(
                  onTap: () {
                    updateSelectedBrand(brandName);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 6, right: 16),
                    decoration: ShapeDecoration(
                      color: selectedBrand == brandName
                          ? kprimaryColor
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 42,
                          height: 54,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(7.0),
                              child: Image.asset(
                                imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (selectedBrand == brandName)
                          Text(
                            brandName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Airbnb Cereal App',
                              fontWeight: FontWeight.w500,
                              height: 0.08,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
