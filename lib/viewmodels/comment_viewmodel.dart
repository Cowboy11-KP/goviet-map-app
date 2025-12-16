import 'package:flutter/foundation.dart';
import 'package:goviet_map_app/models/comment_model.dart';
import 'package:goviet_map_app/services/comment_service.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentService _service = CommentService();
  
  // Trạng thái loading khi ĐĂNG comment (không phải khi load list)
  bool _isPosting = false;
  bool get isPosting => _isPosting;

  // 1. Hàm lấy Stream Comment (View sẽ lắng nghe cái này)
  Stream<List<CommentModel>> getComments(String placeId) {
    return _service.getCommentsByPlaceId(placeId);
  }

  // 2. Hàm Gửi Comment (Xử lý logic loading tại đây)
  Future<bool> sendComment({
    required String placeId,
    required String content,
    required double rating,
    List<String> images = const [],
  }) async {
    // Bật loading
    _isPosting = true;
    notifyListeners(); // Báo cho View biết để hiện vòng xoay

    try {
      await _service.postComment(
        placeId: placeId,
        content: content,
        rating: rating,
        images: images,
      );
      
      // Tắt loading
      _isPosting = false;
      notifyListeners();
      return true; // Thành công

    } catch (e) {
      debugPrint("Lỗi đăng comment: $e");
      _isPosting = false;
      notifyListeners();
      return false; // Thất bại
    }
  }
}