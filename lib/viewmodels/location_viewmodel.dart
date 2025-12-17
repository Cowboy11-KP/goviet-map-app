import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {

  // Tính toán khoảng cách
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
  StreamSubscription<Position>? _positionStreamSubscription; // Để quản lý luồng dữ liệu
  
  String? _error;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;
  String? get error => _error;
  bool get isLoading => _isLoading;

  bool get hasPosition => _currentPosition != null;

  // --- HÀM BẮT ĐẦU THEO DÕI VỊ TRÍ (REAL-TIME) ---
  void startTrackingLocation() async {
    // 1. Kiểm tra quyền trước khi bắt đầu
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // 2. Cấu hình độ chính xác
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Độ chính xác cao nhất (GPS)
      distanceFilter: 10, // Chỉ cập nhật khi di chuyển > 10 mét (Tiết kiệm pin)
    );

    // 3. Lắng nghe luồng dữ liệu (Stream)
    // Hủy stream cũ nếu có để tránh trùng lặp
    await _positionStreamSubscription?.cancel();
    
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        _currentPosition = position;
        debugPrint("📍 Vị trí mới: ${position.latitude}, ${position.longitude}");
        notifyListeners(); // Báo cho UI cập nhật
      }
    });
  }
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

        // // Gọi hàm tracking luôn để đảm bảo logic đồng bộ
        // startTrackingLocation();

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

  // Hủy lắng nghe khi thoát app để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
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
