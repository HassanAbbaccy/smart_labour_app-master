import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return 'Location Disabled';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'Permission Denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Permission Denied Forever';
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Construct a readable address: "Area, City"
        String area = place.subLocality ?? place.thoroughfare ?? '';
        String city = place.locality ?? place.administrativeArea ?? '';

        if (area.isNotEmpty && city.isNotEmpty) {
          return '$area, $city';
        } else if (city.isNotEmpty) {
          return city;
        } else {
          return area;
        }
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Error Locating';
    }
  }
}
