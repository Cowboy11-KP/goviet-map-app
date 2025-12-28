import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goviet_map_app/models/place_model.dart';

class PlaceViewModel extends ChangeNotifier {

  List<Place> _masterPlaces = []; 
  
  List<Place> _places = [];
  
  bool _isLoading = false;

  // UI chỉ cần lấy _places để hiển thị
  List<Place> get places => _places;
  List<Place> get masterPlaces => _masterPlaces;
  bool get isLoading => _isLoading;

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

  // --- HÀM TẢI DỮ LIỆU (SỬA LẠI) ---
  Future<void> loadPlaces() async {
    // Nếu danh sách gốc đã có dữ liệu thì không cần tải lại file JSON
    if (_masterPlaces.isNotEmpty) return; 

    _isLoading = true;
    notifyListeners(); 

    try {
      final jsonStr = await rootBundle.loadString('assets/data/vietnam_tourist_places.json');
      final List data = jsonDecode(jsonStr);
      
      // Bước 1: Parse dữ liệu vào danh sách GỐC (_masterPlaces)
      _masterPlaces = data.map((e) => Place.fromJson(e)).toList();
      
      // Bước 2: Ban đầu, danh sách HIỂN THỊ (_places) sẽ giống hệt danh sách GỐC
      _places = List.from(_masterPlaces);
      
    } catch (e) {
      debugPrint("Lỗi tải places: $e");
    }

    _isLoading = false;
    notifyListeners(); 
  }

  // --- HÀM TÌM KIẾM NÂNG CAO ---
  void searchPlaces(String query) {
    if (query.trim().isEmpty) {
      _places = List.from(_masterPlaces);
    } else {
      // 1. Chuẩn hóa từ khóa tìm kiếm (xóa dấu, xóa cách, lower case)
      final cleanQuery = _normalizeString(query);

      _places = _masterPlaces.where((place) {
        // 2. Chuẩn hóa tên địa điểm trong dữ liệu
        final cleanName = _normalizeString(place.name);
        
        // 3. So sánh chuỗi đã làm sạch
        // Ví dụ: "Hà Nội" -> "hanoi" vs "Ha Noi" -> "hanoi" => Match
        return cleanName.contains(cleanQuery);
      }).toList();
    }

  }

  // --- HÀM TIỆN ÍCH: CHUẨN HÓA CHUỖI TIẾNG VIỆT ---
  String _normalizeString(String str) {
    // 1. Chuyển về chữ thường
    String data = str.toLowerCase();
    
    // 2. Bảng mã thay thế dấu tiếng Việt
    const String withDiacritics = 'áàảãạăắằẳẵặâấầẩẫậéèẻẽẹêếềểễệóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựíìỉĩịýỳỷỹỵđ';
    const String withoutDiacritics = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeooooooooooooooooouuuuuuuuuuuiiiiiyyyyyd';

    // 3. Lặp và thay thế
    for (int i = 0; i < withDiacritics.length; i++) {
      data = data.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }

    // 4. Xóa khoảng trắng (để tìm "hanoi" vẫn ra "Hà Nội")
    return data.replaceAll(" ", "");
  }
}