import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goviet_map_app/models/place_model.dart';
import 'package:goviet_map_app/models/favorite_model.dart';

class FavoriteViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy Collection Reference của user hiện tại
  CollectionReference? _getFavCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    // Đường dẫn: users/{uid}/favorites
    return _firestore.collection('users').doc(user.uid).collection('favorites');
  }

  // 1. Kiểm tra đã thích chưa (Để tô màu trái tim)
  Stream<bool> isFavorite(String placeId) {
    final collection = _getFavCollection();
    if (collection == null) return Stream.value(false);

    return collection.doc(placeId).snapshots().map((doc) => doc.exists);
  }

  // 2. Toggle: Thích / Bỏ thích
  Future<void> toggleFavorite(Place place) async {
    final collection = _getFavCollection();
    if (collection == null) return;

    final docRef = collection.doc(place.id);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Nếu đã có -> Xóa (Bỏ thích)
      await docRef.delete();
    } else {
      // Chưa có -> Thêm mới (Thả tim)
      final fav = FavoriteModel(
        placeId: place.id,
        placeName: place.name,
        placeImage: place.images.isNotEmpty ? place.images.first : '',
        province: place.province,
        addedAt: DateTime.now(),
      );
      // Dùng set để tạo document với ID là placeId (chống trùng lặp)
      await docRef.set(fav.toMap());
    }
  }
  
  // 3. Lấy danh sách yêu thích
  Stream<List<FavoriteModel>> getMyFavorites() {
    final collection = _getFavCollection();
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => FavoriteModel.fromFirestore(doc)).toList());
  }
}