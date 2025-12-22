import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteModel {
  final String placeId;
  final String placeName;
  final String placeImage;
  final String province;
  final DateTime addedAt;

  FavoriteModel({
    required this.placeId,
    required this.placeName,
    required this.placeImage,
    required this.province, 
    required this.addedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'placeImage': placeImage,
      'province': province,
      'addedAt': FieldValue.serverTimestamp(),
    };
  }

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FavoriteModel(
      placeId: doc.id,
      placeName: data['placeName'] ?? '',
      placeImage: data['placeImage'] ?? '',
      // Nếu dữ liệu cũ chưa có province thì để mặc định là 'Khác'
      province: data['province'] ?? 'Khác', 
      addedAt: data['addedAt'] != null ? (data['addedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}