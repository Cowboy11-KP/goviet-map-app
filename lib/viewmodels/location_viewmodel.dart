import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _currentPosition;
  String? _error;
  bool _isLoading = false;

  Position? get currentPosition => _currentPosition;
  String? get error => _error;
  bool get isLoading => _isLoading;

  bool get hasPosition => _currentPosition != null;

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

        debugPrint('Vị trí lấy được: $_currentPosition');

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
}
