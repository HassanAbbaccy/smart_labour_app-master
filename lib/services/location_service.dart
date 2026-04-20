import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final ValueNotifier<Position?> currentPosition = ValueNotifier<Position?>(null);
  final ValueNotifier<String> currentAddress = ValueNotifier<String>('Detecting Location...');
  
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastSyncedPosition;
  static const double _syncThresholdMeters = 50.0;

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

  // One-time fetch (for convenience)
  Future<String> getCurrentLocation() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return 'Permission Denied';

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return await getAddressFromPosition(position);
    } catch (e) {
      return 'Location Error';
    }
  }

  // Start global tracking
  Future<void> startLocalTracking(String? uid) async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) {
      currentAddress.value = 'Location Permission Denied';
      return;
    }

    // Initial fetch
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _updateLocalState(position, uid);
    } catch (e) {
      debugPrint('Initial location fetch error: $e');
    }

    // Listen for updates
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen(
      (Position position) => _updateLocalState(position, uid),
      onError: (e) => debugPrint('Location stream error: $e'),
    );
  }

  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  Future<void> _updateLocalState(Position position, String? uid) async {
    currentPosition.value = position;
    
    // Reverse geocode to get address
    final address = await getAddressFromPosition(position);
    currentAddress.value = address;

    // Sync to Firestore if threshold met
    if (uid != null) {
      if (_lastSyncedPosition == null || 
          Geolocator.distanceBetween(
            _lastSyncedPosition!.latitude, 
            _lastSyncedPosition!.longitude, 
            position.latitude, 
            position.longitude
          ) > _syncThresholdMeters) {
        
        _lastSyncedPosition = position;
        updateUserLocation(uid: uid, position: position, address: address);
      }
    }
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
      debugPrint('Firestore location synced: $address');
    } catch (e) {
      debugPrint('Firestore location sync error: $e');
    }
  }
}
