// lib/services/place_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tên collection trên Firebase
  final String _collectionName = 'Place';

  // --- 1. LẤY TẤT CẢ ---
  Future<List<Place>> getAllPlaces() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection(_collectionName).get();

      final List<Place> places = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Place.fromJson(data);
      }).toList();

      debugPrint("✅ Đã tải ${places.length} địa điểm từ Firestore");
      return places;

    } catch (e) {
      debugPrint("❌ Lỗi lấy data Place: $e");
      return [];
    }
  }

  // --- 2. TÌM KIẾM THEO TÊN (SERVER SIDE) ---
  Future<List<Place>> searchPlacesByName(String query) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '$query\uf8ff') // Trick để search prefix text
          .get();

      return snapshot.docs.map((e) => Place.fromJson(e.data())).toList();
    } catch (e) {
      debugPrint("❌ Lỗi search place: $e");
      return [];
    }
  }

  // --- 3. [MỚI] LẤY CHI TIẾT THEO ID ---
  Future<Place?> getPlaceById(String id) async {
    try {
      // Cách 1: Thử tìm theo Document ID (Ví dụ document path là 'Hồ Gươm')
      // Đây là cách nhanh nhất và tốn ít chi phí đọc nhất
      DocumentSnapshot doc = await _firestore.collection(_collectionName).doc(id).get();
      
      if (doc.exists) {
        debugPrint("🔍 Tìm thấy theo Document ID: $id");
        return Place.fromJson(doc.data() as Map<String, dynamic>);
      }

      // Cách 2: Nếu không thấy, thử tìm theo field "id" bên trong dữ liệu (Ví dụ id="1")
      // Dành cho trường hợp bạn truyền vào ID số
      QuerySnapshot query = await _firestore
          .collection(_collectionName)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        debugPrint("🔍 Tìm thấy theo Field 'id': $id");
        return Place.fromJson(query.docs.first.data() as Map<String, dynamic>);
      }

      debugPrint("⚠️ Không tìm thấy địa điểm nào với ID: $id");
      return null;

    } catch (e) {
      debugPrint("❌ Lỗi lấy place theo ID: $e");
      return null;
    }
  }
}