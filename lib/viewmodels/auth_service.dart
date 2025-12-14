import 'package:flutter/foundation.dart'; // 1. Import cái này để dùng debugPrint
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Helper để in log đẹp hơn, dễ nhìn hơn trong đống chữ lằng nhằng
  void _log(String message) {
    debugPrint("🚀 [AuthService]: $message");
  }

  // 1. Stream lắng nghe trạng thái
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((User? user) {
      if (user != null) {
        _log("Stream -> User đã Login: ${user.email}");
        return UserModel.fromFirebase(user);
      } else {
        _log("Stream -> User đã Logout (null)");
        return null;
      }
    });
  }

  UserModel? get currentUser {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebase(user) : null;
  }

  // 2. Đăng nhập Email
  Future<UserModel?> signInWithEmail(String email, String password) async {
    _log("Bắt đầu login Email: $email");
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      _log("Login thành công ✅: ${result.user?.email}");
      return result.user != null ? UserModel.fromFirebase(result.user!) : null;
    } on FirebaseAuthException catch (e) {
      _log("Lỗi Firebase ❌: ${e.code} - ${e.message}");
      throw e.message ?? "Đăng nhập thất bại";
    } catch (e) {
      _log("Lỗi lạ ❌: $e");
      throw "Lỗi hệ thống";
    }
  }

  // 3. Đăng ký Email
  Future<UserModel?> signUpWithEmail(String email, String password) async {
    _log("Bắt đầu Đăng ký: $email");
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      _log("Đăng ký thành công ✅ UID: ${result.user?.uid}");
      return result.user != null ? UserModel.fromFirebase(result.user!) : null;
    } on FirebaseAuthException catch (e) {
      _log("Lỗi Đăng ký ❌: ${e.code}");
      if (e.code == 'weak-password') throw 'Mật khẩu quá yếu.';
      if (e.code == 'email-already-in-use') throw 'Email này đã tồn tại.';
      throw e.message ?? "Đăng ký thất bại";
    }
  }

  // 4. Đăng nhập Google
  Future<UserModel?> signInWithGoogle() async {
    _log("Bắt đầu Google Sign-In...");
    try {
      // Step 1
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _log("User hủy chọn Google Account ⚠️");
        return null;
      }
      _log("User đã chọn Google: ${googleUser.email}");

      // Step 2
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      _log("Đã lấy Token từ Google (IdToken: ${googleAuth.idToken != null})");

      // Step 3
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      _log("Google Login vào Firebase thành công ✅: ${result.user?.displayName}");
      
      return result.user != null ? UserModel.fromFirebase(result.user!) : null;
    } catch (e) {
      _log("Lỗi Google Login Crash ❌: $e");
      throw "Không thể đăng nhập Google";
    }
  }

  // 5. Đăng xuất
  Future<void> signOut() async {
    _log("Đang đăng xuất...");
    await _googleSignIn.signOut();
    await _auth.signOut();
    _log("Đã đăng xuất xong 👋");
  }
}