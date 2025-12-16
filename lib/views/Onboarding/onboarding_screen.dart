import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/onboarding/onboarding1.png",
      "title": "Bản đồ sống \n Dẫn lối mọi hành trình",
    },
    {
      "image": "assets/onboarding/onboarding2.png",
      "title": "Ghi dấu mọi hành trình của bạn",
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
  
    await prefs.setBool('seenOnboarding', true); 

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // void _skip() {
  //   Navigator.pushReplacementNamed(context, '/login');
  // }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                    return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(page["image"]!),
                        const SizedBox(height: 43),
                        Text(
                          page["title"]!,
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Color(0xff659B4D)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              )
            ),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.white, // Nền trắng
                  side: const BorderSide(color: Color(0xff659B4D)), // Viền xanh
                  elevation: 0,
                ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tiếp',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Color(0xff517C3E)),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xff517C3E),)
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}