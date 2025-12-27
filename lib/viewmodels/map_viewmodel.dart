// lib/viewmodels/map_viewmodel.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MapViewModel extends ChangeNotifier {
  // --- LOCATION STATE ---
  Position? _currentPosition;
  String? _currentAddress;
  StreamSubscription<Position>? _positionStreamSubscription;
  String? _error;
  bool _isLoadingLocation = false;

  // --- ROUTE STATE ---
  List<LatLng> _routePoints = [];
  double _distanceKm = 0.0;
  double _durationMinutes = 0.0;
  bool _isRouteVisible = false;
  bool _isLoadingRoute = false;

  // --- GETTERS ---
  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  String? get error => _error;
  bool get isLoadingLocation => _isLoadingLocation;
  bool get hasPosition => _currentPosition != null;

  List<LatLng> get routePoints => _routePoints;
  double get distanceKm => _distanceKm;
  double get durationMinutes => _durationMinutes;
  bool get isRouteVisible => _isRouteVisible;
  bool get isLoadingRoute => _isLoadingRoute;

  // --- 1. LOCATION LOGIC ---

  Future<void> fetchLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled.';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied.';
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _error = null;

      if (_currentPosition != null) {
        _currentAddress = await _getAddressFromLatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
      }
    } catch (e) {
      _error = 'Lỗi không xác định: $e';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void startTrackingLocation() async {
    // Logic check quyền tương tự fetchLocation...
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    await _positionStreamSubscription?.cancel();
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        _currentPosition = position;
        notifyListeners();
      }
    });
  }

  Future<String> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
      }
      return "Không tìm thấy địa chỉ";
    } catch (e) {
      return "Lỗi định vị";
    }
  }

  // --- 2. ROUTE LOGIC (OSRM) ---

  Future<void> fetchRoute(LatLng start, LatLng end) async {
    _isLoadingRoute = true;
    notifyListeners();

    final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
           _isLoadingRoute = false;
           notifyListeners();
           return;
        }

        final routeProps = data['routes'][0];
        final double distMet = (routeProps['distance'] as num).toDouble();
        final double durSec = (routeProps['duration'] as num).toDouble();
        final List coordinates = routeProps['geometry']['coordinates'];

        _routePoints = coordinates
            .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
            .toList();
            
        _distanceKm = distMet / 1000;
        _durationMinutes = durSec / 60;
        _isRouteVisible = true;
      }
    } catch (e) {
      debugPrint("Lỗi gọi API: $e");
    } finally {
      _isLoadingRoute = false;
      notifyListeners();
    }
  }

  void clearRoute() {
    _routePoints = [];
    _distanceKm = 0.0;
    _durationMinutes = 0.0;
    _isRouteVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // Tiện ích tính khoảng cách (Static)
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180);
}