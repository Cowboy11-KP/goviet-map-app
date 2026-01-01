import 'package:flutter/material.dart';

class PlaceCategoryHelper {
  
  // Hàm trả về Widget Marker (Hình tròn bao quanh icon)
  static Widget getIconWidget(String categoryName) {
    IconData iconData;
    Color color;

    // Chuẩn hóa chuỗi để so sánh
    String key = categoryName.trim().toLowerCase();

    // --- LOGIC CHỌN ICON VÀ MÀU ---
    
    // 1. Biển / Đảo (Ưu tiên kiểm tra trước)
    if (key.contains('sea') || key.contains('biển') || key.contains('beach') || key.contains('đảo')) {
      iconData = Icons.beach_access;
      color = Colors.cyan.shade600; // Màu xanh nước biển
    } 
    // 2. Núi / Đồi
    else if (key.contains('mountain') || key.contains('núi') || key.contains('đồi') || key.contains('leo núi')) {
      iconData = Icons.terrain;
      color = Colors.brown; // Màu nâu đất
    }
    // 3. Ăn uống / Café
    else if (key.contains('food') || key.contains('ăn') || key.contains('uống') || key.contains('café') || key.contains('coffee')) {
      iconData = Icons.restaurant;
      color = Colors.orange; // Màu cam thực phẩm
    }
    // 4. Chụp hình / Sống ảo / Check-in
    else if (key.contains('photo') || key.contains('chụp') || key.contains('checkin') || key.contains('camera')) {
      iconData = Icons.camera_alt;
      color = Colors.purpleAccent; // Màu tím nổi bật
    }
    // 5. Khách sạn / Resort
    else if (key.contains('hotel') || key.contains('khách sạn') || key.contains('resort') || key.contains('nghỉ')) {
      iconData = Icons.hotel;
      color = Colors.indigo;
    }
    // 6. Công viên / Thiên nhiên (Cây cối)
    else if (key.contains('park') || key.contains('công viên') || key.contains('vườn') || key.contains('rừng')) {
      iconData = Icons.park;
      color = Colors.green;
    }
    // 7. Lịch sử / Văn hóa / Chùa chiền
    else if (key.contains('history') || key.contains('lịch sử') || key.contains('bảo tàng') || key.contains('di tích') || key.contains('chùa') || key.contains('đền')) {
      iconData = Icons.museum; // Hoặc Icons.account_balance
      color = const Color(0xFF795548); // Nâu đậm
    }
    // 8. Du lịch chung (General Travel)
    else if (key.contains('travel') || key.contains('du lịch')) {
      iconData = Icons.map; // Đổi sang icon bản đồ để tránh trùng với Camera
      color = Colors.blue;
    }
    // 9. Mặc định (Nếu không khớp cái nào)
    else {
      iconData = Icons.location_on;
      color = Colors.redAccent;
    }

    // --- TRẢ VỀ WIDGET ---
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(1),
      child: Icon(iconData, color: color, size: 24), 
    );
  }
}