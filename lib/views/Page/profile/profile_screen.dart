import 'package:flutter/material.dart';
import 'package:goviet_map_app/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Màu nền xanh nhạt giống thiết kế
  final Color backgroundColor = const Color(0xFFF2F6F1);
  final Color primaryColor = const Color(0xff517C3E);

  @override
  void initState() {
    super.initState();
    // Cập nhật lại thông tin user khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().reloadUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ AuthViewModel
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.currentUser;

    // Nếu chưa đăng nhập (user null), hiện màn hình yêu cầu login
    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Điều hướng sang màn hình Login của bạn
              // Navigator.pushNamed(context, '/login'); 
            },
            child: const Text("Đăng nhập để xem hồ sơ"),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 0, // Ẩn AppBar chuẩn để tự custom header nếu muốn
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- 1. AVATAR & NAME ---
            Stack(
              children: [
                Column(
                  children: [
                    // Avatar Container
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.pink.shade100, // Màu nền fallback
                        backgroundImage: authVM.photoUrl != null
                            ? NetworkImage(authVM.photoUrl!)
                            : null,
                        child: authVM.photoUrl == null
                            ? Text(
                                authVM.displayName.isNotEmpty ? authVM.displayName[0].toUpperCase() : "U",
                                style: TextStyle(fontSize: 30, color: primaryColor, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Tên người dùng
                    Text(
                      authVM.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                // Nút Edit (Góc trên phải)
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    onPressed: () {
                      // Mở màn hình chỉnh sửa hồ sơ
                    },
                    icon: Icon(Icons.edit_outlined, color: primaryColor),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- 2. THÔNG TIN LIÊN HỆ (CARD TRẮNG) ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildContactRow(Icons.email_outlined, authVM.email),
                  // Chỉ hiện SĐT nếu có
                  if (authVM.phoneNumber != "Chưa cập nhật SĐT") ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _buildContactRow(Icons.phone_outlined, authVM.phoneNumber),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. MENU OPTIONS ---
            _buildMenuOption(
              icon: Icons.history, 
              label: "Đã đi", 
              onTap: () {
                // Navigate to History
              }
            ),
            const SizedBox(height: 12),
            _buildMenuOption(
              icon: Icons.star_rate_rounded, 
              label: "Đánh giá của tôi", 
              iconColor: Colors.amber,
              onTap: () {
                // Navigate to Reviews
              }
            ),
            const SizedBox(height: 12),
            _buildMenuOption(
              icon: Icons.lock_outline, 
              label: "Đổi mật khẩu", 
              iconColor: Colors.blue[800],
              onTap: () {
                // Navigate to Change Password
              }
            ),

            const SizedBox(height: 32),

            // --- 4. LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authVM.signOut();
                  // Có thể navigate về màn hình Login ở đây
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEBEBEB), // Màu xám nhạt
                  foregroundColor: Colors.red, // Màu chữ/icon đỏ
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "Đăng xuất",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            
            const SizedBox(height: 20), // Padding bottom
          ],
        ),
      ),
    );
  }

  // --- Widget Helper: Dòng thông tin liên hệ (Email/Phone) ---
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xff659B4D)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // --- Widget Helper: Menu Option Card ---
  Widget _buildMenuOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xff659B4D)).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xff659B4D), size: 22),
        ),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}