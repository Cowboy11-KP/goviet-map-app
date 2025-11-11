import 'package:flutter/material.dart';
import 'package:goviet_map_app/views/Onboarding/onboarding_screen.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xff659B4D)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 48 / 32,
              ),
              children: const [
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
          Image.asset('assets/logo.png'),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnBoardingScreen())
              );
            }, 
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bắt đầu',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Color(0xff517C3E)),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Color(0xff517C3E),)
              ],
            ) 
          ),
        ],
      ),
    );
  }
}
