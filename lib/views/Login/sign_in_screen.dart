import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _switchPage(int page) {
    setState(() => _currentPage = page);
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'GoViet Map',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 48 / 32,
            color: Color(0xff659B4D)
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _switchPage(0),
                  child: Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: _currentPage == 0 ? FontWeight.bold : FontWeight.normal,
                      decoration: _currentPage == 0 ? TextDecoration.underline : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => _switchPage(1),
                  child: Text(
                    'Đăng ký',
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 20,
                      fontWeight: _currentPage == 1 ? FontWeight.bold : FontWeight.normal,
                      decoration: _currentPage == 1 ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  SignInForm(),
                  SignUpForm(),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool _hidePassword = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gmail'
          ),
          const SizedBox(height: 4),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Nhập gmail của bạn',
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(width: 1)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Colors.green, // Màu viền khi focus
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mật khẩu '
          ),
          const SizedBox(height: 4),
          TextFormField(
            obscureText: _hidePassword,
            decoration: InputDecoration(
              hintText: 'Nhập gmail mật khẩu',
              contentPadding: EdgeInsets.all(8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide(width: 1)
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Colors.green, // Màu viền khi focus
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _hidePassword = !_hidePassword;
                  });
                }, 
                icon: SvgPicture.asset('assets/icons/eye.svg')
              )
            ),
          )
        ],
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}