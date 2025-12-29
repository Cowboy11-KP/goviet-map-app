import 'package:flutter/material.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/services/place_service.dart';

class PlaceViewModel extends ChangeNotifier {
  final PlaceService _placeService = PlaceService();

  List<Place> _masterPlaces = []; 
  List<Place> _places = [];       
  
  bool _isLoading = false;          // Loading cho danh sách tổng
  bool _isFetchingDetail = false;   // Loading riêng cho việc lấy chi tiết

  // Getters
  List<Place> get places => _places;
  List<Place> get masterPlaces => _masterPlaces;
  bool get isLoading => _isLoading;
  bool get isFetchingDetail => _isFetchingDetail; // Getter mới

  Map<String, List<Place>> get placesByProvince {
    Map<String, List<Place>> grouped = {};
    for (var place in _places) {
      if (!grouped.containsKey(place.province)) {
        grouped[place.province] = [];
      }
      grouped[place.province]!.add(place);
    }
    return grouped;
  }

  // --- 1. HÀM TẢI DỮ LIỆU TỪ FIREBASE ---
  Future<void> loadPlaces() async {
    if (_masterPlaces.isNotEmpty) return; 

    _isLoading = true;
    notifyListeners(); 

    try {
      final data = await _placeService.getAllPlaces();
      _masterPlaces = data;
      _places = List.from(_masterPlaces); 
    } catch (e) {
      debugPrint("Lỗi tải places: $e");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  // --- 2. HÀM LẤY CHI TIẾT THEO ID (MỚI THÊM) ---
  Future<Place?> getPlaceById(String id) async {
    // 1. Tìm trong list có sẵn trước (để đỡ tốn gọi mạng)
    try {
      final localPlace = _masterPlaces.firstWhere((p) => p.id == id);
      debugPrint("✅ Tìm thấy Place trong bộ nhớ local: ${localPlace.name}");
      return localPlace;
    } catch (e) {
      // Nếu không thấy trong list local -> Gọi Firebase
    }

    // 2. Gọi Firebase nếu không thấy local
    _isFetchingDetail = true;
    notifyListeners();

    try {
      final place = await _placeService.getPlaceById(id);
      return place;
    } catch (e) {
      debugPrint("Lỗi lấy chi tiết place: $e");
      return null;
    } finally {
      _isFetchingDetail = false;
      notifyListeners();
    }
  }

  // --- 3. HÀM TÌM KIẾM UI ---
  void searchPlaces(String query) {
    if (query.trim().isEmpty) {
      _places = List.from(_masterPlaces);
    } else {
      final cleanQuery = _normalizeString(query);
      _places = _masterPlaces.where((place) {
        final cleanName = _normalizeString(place.name);
        return cleanName.contains(cleanQuery); 
      }).toList();
    }
    notifyListeners(); 
  }

  // --- 4. HÀM TÌM KIẾM LOCAL (CHO SEARCH DELEGATE) ---
  List<Place> searchLocal(String query) {
    if (query.trim().isEmpty) {
      return []; 
    }
    final cleanQuery = _normalizeString(query);
    return _masterPlaces.where((place) {
      final cleanName = _normalizeString(place.name);
      return cleanName.contains(cleanQuery);
    }).toList();
  }

  // --- UTILS ---
  String _normalizeString(String str) {
    String data = str.toLowerCase();
    const String withDiacritics = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựíìỉĩịýỳỷỹỵđ';
    const String withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeooooooooooooooooouuuuuuuuuuuiiiiiyyyyyd';

    for (int i = 0; i < withDiacritics.length; i++) {
      data = data.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return data.replaceAll(" ", "");
  }
}