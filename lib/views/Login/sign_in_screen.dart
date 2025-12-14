import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goviet_map_app/viewmodels/auth_service.dart';
import 'package:goviet_map_app/views/Home/root_screen.dart.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Dùng cho đăng ký
  final TextEditingController _confirmPassController = TextEditingController(); // Dùng cho đăng ký

  final AuthService _authService = AuthService();
  
  bool _hidePassword = true;
  bool _rememberPassword = false;
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _nameController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _toggleForm(bool isLogin) {
    setState(() {
      _isLogin = isLogin;
      // Clear form khi chuyển tab để tránh nhầm lẫn
      _emailController.clear();
      _passController.clear();
      _nameController.clear();
      _confirmPassController.clear();
    });
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP / ĐĂNG KÝ EMAIL ---
  void _handleEmailAuth() async {
    // Validate cơ bản
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
      return;
    }

    if (!_isLogin) {
      // Logic riêng cho Đăng ký
      if (_passController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Mật khẩu nhập lại không khớp")));
        return;
      }
    }

    setState(() => _isLoading = true); // Bắt đầu load

    try {
      final user = _isLogin
          ? await _authService.signInWithEmail(_emailController.text.trim(), _passController.text.trim())
          : await _authService.signUpWithEmail(_emailController.text.trim(), _passController.text.trim());

      if (user != null && mounted) {
         // Thành công -> Chuyển màn hình
         Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => RootScreen())
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // Tắt load
    }
  }

  // --- HÀM XỬ LÝ GOOGLE ---
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => RootScreen())
        );
      }
    } catch (e) {
      // Lỗi hoặc user hủy login thì không làm gì hoặc hiện thông báo nhẹ
      print("Google Login Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'GoViet Map',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 48 / 32,
            color: Color(0xff659B4D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Nút chuyển đổi giữa Đăng nhập / Đăng ký ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _toggleForm(true),
                  child: Text(
                    'Đăng nhập',
                    style: _isLogin 
                      ? Theme.of(context).textTheme.headlineMedium!.copyWith(decoration: TextDecoration.underline)
                      : Theme.of(context).textTheme.labelLarge
                  ),
                ),
                const SizedBox(width: 4),
                Text('/', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _toggleForm(false),
                  child: Text(
                    'Đăng ký',
                    style: !_isLogin 
                      ? Theme.of(context).textTheme.headlineMedium!.copyWith(decoration: TextDecoration.underline)
                      : Theme.of(context).textTheme.labelLarge
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _isLogin ? _buildLoginForm() : _buildRegisterForm(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailAuth, 
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12),
                  backgroundColor: Color(0xff659B4D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(24)
                  ),
              
                ),
                child: Text(
                  _isLogin ? 'Đăng nhập' : 'Đăng kí',
                  style:Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white)
                )
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){}, 
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(24),
                    side: BorderSide(color: Color(0xffBABABA))
                  ),
              
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/Google.svg', width: 21),
                    const SizedBox(width: 8),
                    Text(
                      'Tiếp tục với Google',
                      style: Theme.of(context).textTheme.bodyMedium
                    )
                  ],
                )
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleGoogleLogin, 
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(24),
                    side: BorderSide(color: Color(0xffBABABA))
                  ),
              
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/Fb.svg', width: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Tiếp tục với Facebook',
                      style: Theme.of(context).textTheme.bodyMedium
                    )
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- FORM ĐĂNG NHẬP ---
  Widget _buildLoginForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Email'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Nhập gmail của bạn',
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xff659B4D), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Mật khẩu'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _passController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              hintText: 'Nhập mật khẩu của bạn',
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xff659B4D), width: 2),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                icon: SvgPicture.asset(
                  'assets/icons/eye.svg',
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Remember password + forgot password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                    value: _rememberPassword,
                    onChanged: (value) {
                      setState(() {
                        _rememberPassword = value ?? false;
                      });
                    },
                    activeColor: const Color(0xff659B4D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text('Nhớ mật khẩu'),
                ],
              ),
              const Text(
                'Quên mật khẩu',
                style: TextStyle(
                  color: Color(0xFF2C93CF),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FORM ĐĂNG KÝ ---
  Widget _buildRegisterForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Họ và tên'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: 'Nhập tên của bạn',
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xff659B4D), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Email'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: 'Nhập gmail của bạn',
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xff659B4D), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Mật khẩu'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _passController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              hintText: 'Tạo mật khẩu',
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xff659B4D), width: 2),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                icon: SvgPicture.asset(
                  'assets/icons/eye.svg',
                  
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Nhập lại Mật khẩu'),
          const SizedBox(height: 4),
          TextFormField(
            controller: _confirmPassController,
            obscureText: _hidePassword,
            decoration: InputDecoration(
              hintText: 'Nhập',
              contentPadding: const EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(color: Color(0xff659B4D), width: 2),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                },
                icon: SvgPicture.asset(
                  'assets/icons/eye.svg',
                  
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
