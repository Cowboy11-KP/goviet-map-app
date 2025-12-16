import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goviet_map_app/viewmodels/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

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
      _emailController.clear();
      _passController.clear();
      _nameController.clear();
      _confirmPassController.clear();
    });
  }

  // --- HÀM LƯU TRẠNG THÁI LOGIN ---
  Future<void> _saveLoginState(bool isRemembered) async {
    final prefs = await SharedPreferences.getInstance();
    // Lưu key 'isRemembered' để StartScreen kiểm tra
    await prefs.setBool('isRemembered', isRemembered);
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP / ĐĂNG KÝ EMAIL ---
  void _handleEmailAuth() async {
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")));
      return;
    }

    if (!_isLogin) {
      if (_passController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu phải có ít nhất 6 ký tự.")));
        return;
      }
      if (_passController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mật khẩu nhập lại không khớp")));
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final user = _isLogin
          ? await _authService.signInWithEmail(_emailController.text.trim(), _passController.text.trim())
          : await _authService.signUpWithEmail(_emailController.text.trim(), _passController.text.trim());

      if (user != null && mounted) {
        // --- LƯU TRẠNG THÁI REMEMBER ---
        // Nếu người dùng tick vào checkbox, lưu true. Không tick thì lưu false.
        await _saveLoginState(_rememberPassword);

        // Chuyển màn hình (Dùng named route cho đồng bộ với main.dart)
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- HÀM XỬ LÝ GOOGLE ---
  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null && mounted) {
        // --- LƯU TRẠNG THÁI REMEMBER ---
        // Với Google, thường mặc định là luôn nhớ đăng nhập
        await _saveLoginState(true);

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
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
                const Text('/', style: TextStyle(fontSize: 28)),
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
            
            // Nút Action chính
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleEmailAuth, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xff659B4D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)
                  ),
                ),
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _isLogin ? 'Đăng nhập' : 'Đăng kí',
                      style:Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.white)
                    )
              ),
            ),
            const SizedBox(height: 12),
            
            // Nút Google
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleGoogleLogin, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Color(0xffBABABA))
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
            // Nút Facebook (Giữ nguyên UI)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){}, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: const BorderSide(color: Color(0xffBABABA))
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xff659B4D), width: 2)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xff659B4D), width: 2)),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: SvgPicture.asset('assets/icons/eye.svg'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // --- CHECKBOX NHỚ MẬT KHẨU ---
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  const Text('Nhớ mật khẩu'),
                ],
              ),
              const Text(
                'Quên mật khẩu',
                style: TextStyle(color: Color(0xFF2C93CF), fontSize: 12, fontWeight: FontWeight.w600),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xff659B4D), width: 2)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xff659B4D), width: 2)),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xff659B4D), width: 2)),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: SvgPicture.asset('assets/icons/eye.svg'),
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
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xff659B4D), width: 2)),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
                icon: SvgPicture.asset('assets/icons/eye.svg'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}