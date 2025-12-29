import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'package:shared_preferences/shared_preferences.dart';
import 'package:goviet_map_app/viewmodels/auth_viewmodel.dart'; // 2. Import ViewModel

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

  // Không cần khai báo AuthService và _isLoading ở đây nữa
  
  bool _hidePassword = true;
  bool _rememberPassword = false;
  bool _isLogin = true;

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
      // Reset lỗi trong VM nếu có (tùy chọn)
    });
  }

  // --- HÀM LƯU TRẠNG THÁI LOGIN ---
  Future<void> _saveLoginState(bool isRemembered) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRemembered', isRemembered);
  }

  // --- HÀM XỬ LÝ ĐĂNG NHẬP / ĐĂNG KÝ EMAIL (GỌI VM) ---
  void _handleEmailAuth() async {
    // 1. Validate cơ bản
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
      if (_nameController.text.isEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập họ tên")));
         return;
      }
    }

    // 2. Gọi ViewModel
    final authVM = context.read<AuthViewModel>(); // Dùng read để gọi hàm
    bool success;

    if (_isLogin) {
      success = await authVM.login(_emailController.text.trim(), _passController.text.trim());
    } else {
      success = await authVM.register(_emailController.text.trim(), _passController.text.trim());
      // Lưu ý: Nếu muốn update Display Name ngay khi đăng ký, bạn cần thêm logic updateProfile trong VM
    }

    // 3. Xử lý kết quả
    if (mounted) {
      if (success) {
        await _saveLoginState(_rememberPassword);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Hiện lỗi từ ViewModel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authVM.errorMessage ?? "Đã có lỗi xảy ra"))
        );
      }
    }
  }

  // --- HÀM XỬ LÝ GOOGLE (GỌI VM) ---
  void _handleGoogleLogin() async {
    final authVM = context.read<AuthViewModel>();
    
    final success = await authVM.loginGoogle();

    if (mounted) {
      if (success) {
        await _saveLoginState(true);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authVM.errorMessage ?? "Đăng nhập Google thất bại"))
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái loading từ ViewModel để vẽ UI
    final authVM = context.watch<AuthViewModel>(); 

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
            // --- Tabs chuyển đổi ---
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
            
            // Nút Action chính (Login/Register)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Disable nút khi đang loading
                onPressed: authVM.isLoading ? null : _handleEmailAuth, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: const Color(0xff659B4D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)
                  ),
                ),
                child: authVM.isLoading 
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
                onPressed: authVM.isLoading ? null : _handleGoogleLogin, 
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
            // Nút Facebook
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

  // --- FORM ĐĂNG NHẬP (Giữ nguyên UI) ---
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

  // --- FORM ĐĂNG KÝ (Giữ nguyên UI) ---
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