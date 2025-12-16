import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goviet_map_app/views/Login/sign_in_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import các màn hình điều hướng
import 'package:goviet_map_app/views/Onboarding/onboarding_screen.dart';
import 'package:goviet_map_app/views/Home/root_screen.dart.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Biến trạng thái: true = đang kiểm tra, false = là người dùng mới (hiện nút)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAppFlow();
  }

  // --- HÀM LOGIC KIỂM TRA LUỒNG ĐI ---
  Future<void> _checkAppFlow() async {
    // 1. Tạo độ trễ giả (2 giây) để hiện Logo chào mừng cho đẹp
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    
    // Lấy dữ liệu đã lưu
    final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    final bool isRemembered = prefs.getBool('isRemembered') ?? false;
    final User? currentUser = FirebaseAuth.instance.currentUser;

    // --- PHÂN LUỒNG ---
    if (seenOnboarding) {
      // CASE A: Người dùng CŨ (Đã từng vào app)
      // Không hiện nút Bắt đầu nữa, mà tự chuyển trang luôn
      
      if (currentUser != null && isRemembered) {
        // A1: Đã login + Có nhớ mật khẩu -> Vào thẳng Home
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const RootScreen())
        );
      } else {
        // A2: Chưa login hoặc Không nhớ mật khẩu -> Về Login
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const SignInScreen())
        );
      }
    } else {
      // CASE B: Người dùng MỚI TINH (Lần đầu mở app)
      // Tắt loading -> Hiện nút "Bắt đầu" để họ bấm
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Full width
        height: double.infinity, // Full height
        decoration: const BoxDecoration(color: Color(0xff659B4D)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 48 / 32,
                ),
                children: [
                  TextSpan(
                    text: 'GoViet',
                    style: TextStyle(color: Color(0xff283E1F)),
                  ),
                  TextSpan(
                    text: ' Xin Chào',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 21),
            // Logo
            Image.asset('assets/logo.png', height: 250),
            
            const SizedBox(height: 40),

            // --- PHẦN QUAN TRỌNG: Thay đổi giao diện dựa theo trạng thái ---
            _isLoading 
              ? const CircularProgressIndicator(color: Colors.white) // Đang check thì xoay
              : ElevatedButton( // Check xong (là New User) thì hiện nút
                  onPressed: () async {
                    // Khi bấm Bắt đầu -> Lưu là đã xem Onboarding
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('seenOnboarding', true);

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const OnBoardingScreen())
                      );
                    }
                  }, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bắt đầu',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: const Color(0xff517C3E), 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xff517C3E), size: 16,)
                    ],
                  ) 
                ),
          ],
        ),
      ),
    );
  }
}