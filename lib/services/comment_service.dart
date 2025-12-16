import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goviet_map_app/models/comment_model.dart';

class CommentService {
  // Khởi tạo các instance của Firebase
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // =========================================================
  // 1. LẤY DANH SÁCH COMMENT (STREAM)
  // Dùng Stream để dữ liệu tự động cập nhật khi có người khác comment
  // =========================================================
  Stream<List<CommentModel>> getCommentsByPlaceId(String placeId) {
    return _db
        .collection('comments') // Tên collection trên Firebase
        .where('placeId', isEqualTo: placeId) // Chỉ lấy comment của địa điểm này
        .orderBy('timestamp', descending: true) // Sắp xếp mới nhất lên đầu
        .snapshots() // Lắng nghe thay đổi
        .map((snapshot) {
          // Chuyển đổi từ dữ liệu thô (JSON/DocumentSnapshot) sang List<Model>
          return snapshot.docs.map((doc) {
            return CommentModel.fromFirestore(doc);
          }).toList();
        });
  }

  // =========================================================
  // 2. GỬI COMMENT MỚI (FUTURE)
  // =========================================================
  Future<void> postComment({
    required String placeId,
    required String content,
    required double rating,
    List<String> images = const [],
  }) async {
    // Lấy thông tin user hiện tại đang đăng nhập
    final User? user = _auth.currentUser;

    // Kiểm tra bảo mật: Nếu chưa đăng nhập thì chặn luôn
    if (user == null) {
      throw Exception("Bạn cần đăng nhập để thực hiện chức năng này.");
    }

    // Xử lý tên hiển thị: Nếu không có tên thì lấy phần đầu email hoặc "Người dùng"
    final String displayName = user.displayName ?? user.email?.split('@')[0] ?? "Người dùng";

    // Tạo object từ Model
    final newComment = CommentModel(
      id: null, // ID sẽ do Firestore tự sinh ra
      placeId: placeId,
      userId: user.uid,
      userName: displayName,
      userAvatarUrl: user.photoURL, // Lấy avatar từ Google/Facebook nếu có
      content: content,
      rating: rating,
      images: images,
      timestamp: DateTime.now(), // Thời gian hiện tại trên máy (Firestore sẽ dùng serverTimestamp khi map)
    );

    // Đẩy lên Firestore (Chuyển Model -> Map)
    await _db.collection('comments').add(newComment.toMap());
  }
}