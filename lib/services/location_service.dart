import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  Future<String> getCurrentLocation() async {
    try {
      // Test if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location Disabled';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Permission Denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return 'Permission Denied Forever';
      }

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
      // Catching any exception (including PermissionDefinitionsNotFoundException)
      // to prevent the app from crashing.
      return 'Location Error';
    }
  }
}
