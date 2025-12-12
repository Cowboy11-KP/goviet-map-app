// viewmodels/place_viewmodel.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goviet_map_app/models/place_model.dart';

class PlaceViewModel extends ChangeNotifier {
  List<Place> _places = [];
  bool _isLoading = false;

  List<Place> get places => _places;
  bool get isLoading => _isLoading;

  // Hàm tải dữ liệu
  Future<void> loadPlaces() async {
    if (_places.isNotEmpty) return; // Nếu đã có dữ liệu thì không tải lại

    _isLoading = true;
    notifyListeners(); // Báo cho UI hiện loading

    try {
      final jsonStr = await rootBundle.loadString('assets/data/vietnam_tourist_places.json');
      final List data = jsonDecode(jsonStr);
      _places = data.map((e) => Place.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Lỗi tải places: $e");
    }

    _isLoading = false;
    notifyListeners(); // Báo cho UI cập nhật danh sách
  }
}