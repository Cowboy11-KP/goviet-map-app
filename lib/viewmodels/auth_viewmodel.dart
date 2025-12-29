// lib/viewmodels/auth_viewmodel.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart'; // Import AuthService bạn vừa gửi

class AuthViewModel extends ChangeNotifier {
  // 1. Khởi tạo Service
  final AuthService _authService = AuthService();

  // 2. State (Trạng thái)
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  // 3. Getters (Để UI lấy dữ liệu)
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // --- Getters hỗ trợ UI Profile (Giữ nguyên để không phải sửa UI ProfileScreen) ---
  String get displayName => _currentUser?.displayName ?? "Người dùng mới";
  String get email => _currentUser?.email ?? "Chưa cập nhật email";
  String? get photoUrl => _currentUser?.photoUrl;
  String get phoneNumber => _currentUser?.phoneNumber ?? "Chưa cập nhật SĐT";

  // 4. Constructor: Lắng nghe trạng thái đăng nhập ngay khi khởi tạo
  AuthViewModel() {
    _authService.authStateChanges.listen((userModel) {
      _currentUser = userModel;
      notifyListeners(); // Tự động báo UI vẽ lại khi Login/Logout
    });
  }

  // --- CÁC HÀM XỬ LÝ LOGIC ---

  // Đăng nhập Email
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signInWithEmail(email, password);
      // Không cần gán _currentUser ở đây vì Stream trong constructor đã lo việc đó
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng ký Email
  Future<bool> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUpWithEmail(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng nhập Google
  Future<bool> loginGoogle() async {
    _setLoading(true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _errorMessage = "Đã hủy đăng nhập";
        return false;
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _setLoading(false);
  }

  // Reload user (Cập nhật thông tin mới nhất từ Firebase)
  Future<void> reloadUser() async {
    // AuthService hiện tại chưa có hàm reload, ta có thể gọi tạm instance hoặc bổ sung sau
    // Ở đây ta chỉ cần notify để UI vẽ lại nếu có thay đổi cục bộ
    notifyListeners(); 
  }

  // Hàm phụ để set loading và báo UI
  void _setLoading(bool value) {
    _isLoading = value;
    if (value == true) _errorMessage = null; // Reset lỗi khi bắt đầu tác vụ mới
    notifyListeners();
  }
}