import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371;
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180);

  Position? _currentPosition;
  String? _currentAddress;
  String? _error;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  String? get error => _error;
  bool get isLoading => _isLoading;

  bool get hasPosition => _currentPosition != null;

  //Hàm lấy tọa độ
  Future<void> fetchLocation() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Kiểm tra Location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Location services are disabled.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Kiểm tra permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Location permissions are denied';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Location permissions are permanently denied.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Lấy vị trí hiện tại
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _error = null;

        if (_currentPosition != null) {
          _currentAddress = await getAddressFromLatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          );
          debugPrint("Địa chỉ hiện tại: $_currentAddress");
        }

        if (_currentPosition == null) {
          _error = 'Không lấy được vị trí, kiểm tra GPS hoặc quyền';
          debugPrint(_error);
        }
      } catch (e) {
        _error = 'Lỗi khi lấy vị trí: $e';
        debugPrint(_error);
      }
    } catch (e) {
      // Bắt tất cả lỗi bất ngờ
      _error = 'Lỗi không xác định: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Hàm đổi tọa độ thành vị trí 
  Future<String> getAddressFromLatLng(double lat, double lng) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    } else {
      return "Không tìm thấy địa chỉ";
    }
  } catch (e) {
    return "Lỗi chuyển đổi vị trí: $e";
  }
}
}
