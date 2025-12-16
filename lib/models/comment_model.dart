import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String? id;           // ID của document trên Firestore
  final String placeId;        // <--- LINK: ID của địa điểm du lịch (từ Place Model)
  final String userId;         // <--- LINK: ID của người dùng đã comment (từ Auth Service)
  final String userName;       // Tên hiển thị người dùng (lưu để load nhanh)
  final String? userAvatarUrl; // URL ảnh đại diện (nếu có)
  final double rating;         // Điểm đánh giá (1.0 - 5.0)
  final String content;        // Nội dung comment
  final List<String> images;   // Danh sách URL ảnh đính kèm (nếu có)
  final DateTime timestamp;    // Thời gian comment

  CommentModel({
    this.id,
    required this.placeId,  
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.content,
    required this.images,
    required this.timestamp,
  });

  // Factory: Chuyển từ DocumentSnapshot (Firestore) sang Object (Dart)
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      placeId: data['placeId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Ẩn danh',
      userAvatarUrl: data['userAvatarUrl'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      content: data['content'] ?? '',
      images: data['images'] != null 
          ? List<String>.from(data['images']) 
          : [],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Method: Chuyển từ Object (Dart) sang Map (để đẩy lên Firestore)
  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'content': content,
      'images': images,
      'timestamp': FieldValue.serverTimestamp(), // Dùng giờ của server
    };
  }
}