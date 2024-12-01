import 'package:HDTech/screens/Cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CustomAppBar extends StatefulWidget {
  final void Function(Map<String, dynamic>) onFilterChanged;
  final bool enableLocationServices; // Required parameter

  const CustomAppBar({
    super.key,
    required this.onFilterChanged,
    required this.enableLocationServices, // Marked as required
  });

  @override
  CustomAppBarState createState() => CustomAppBarState();
}

class CustomAppBarState extends State<CustomAppBar> {
  String _currentLocation = 'Location is off';

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  @override
  void didUpdateWidget(covariant CustomAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-check location when the toggle changes
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    if (!widget.enableLocationServices) {
      setState(() {
        _currentLocation = 'Location is off';
      });
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentLocation = 'No location access';
      });
      return;
    }

    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        setState(() {
          // Format street name (replace "Đường" or "Street" with "St.")
          String street = place.thoroughfare
                  ?.replaceAll("Đường", "St.")
                  .replaceAll("Street", "St.")
                  .trim() ??
              '';

          // Abbreviate administrative area
          String administrativeAreaAbbr =
              abbreviate(place.administrativeArea ?? '');

          // Build location string
          if (street.length + administrativeAreaAbbr.length > 20) {
            _currentLocation = '$street, $administrativeAreaAbbr';
          } else {
            _currentLocation =
                '$street, ${place.subAdministrativeArea ?? ''}, $administrativeAreaAbbr';
          }
        });
      } else {
        setState(() {
          _currentLocation = 'Unable to get address';
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to get location';
      });
    }
  }

  // Move abbreviate function outside _getCurrentLocation
  String abbreviate(String input) {
    return input
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(10),
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open FilterDrawer
          },
          icon: SvgPicture.asset(
            "images/icons/code-scan-svgrepo-com.svg",
            height: 30,
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 38,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Your location',
                  style: TextStyle(
                    color: Color(0xFF707B81),
                    fontSize: 14,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      "images/map-point-svgrepo-com.svg",
                      height: 18,
                      width: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      _currentLocation,
                      style: const TextStyle(
                        color: Color(0xFF1A242F),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            padding: const EdgeInsets.all(10),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          icon: SvgPicture.asset(
            "images/icons/cart-2-svgrepo-com.svg",
            height: 30,
          ),
        ),
      ],
    );
  }
}
