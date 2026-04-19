import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  // Check and request permissions
  Future<bool> checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  // One-time fetch (for compatibility)
  Future<String> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) return 'Permission Denied';

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      
      return await getAddressFromPosition(position);
    } catch (e) {
      return 'Location Error';
    }
  }

  // Get a stream of location updates
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  // Geocode a specific position
  Future<String> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String area = place.subLocality ?? place.thoroughfare ?? '';
        String city = place.locality ?? place.administrativeArea ?? '';
        return area.isNotEmpty ? '$area, $city' : city;
      }
      return 'Unknown Location';
    } catch (e) {
      return 'Geocoding Error';
    }
  }

  // Sync to Firestore
  Future<void> updateUserLocation({
    required String uid,
    required Position position,
    required String address,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastLatitude': position.latitude,
        'lastLongitude': position.longitude,
        'address': address,
        'locationUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore location sync error: $e');
    }
  }
}
