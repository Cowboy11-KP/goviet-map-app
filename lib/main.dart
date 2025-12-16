import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:goviet_map_app/views/Home/root_screen.dart.dart';
import 'package:goviet_map_app/views/Login/sign_in_screen.dart';
import 'package:goviet_map_app/views/Onboarding/onboarding_screen.dart';
// import 'package:goviet_map_app/seeding_script.dart';
import 'firebase_options.dart';

import 'package:goviet_map_app/viewmodels/location_viewmodel.dart';
import 'package:goviet_map_app/viewmodels/place_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:goviet_map_app/app_theme.dart';
import 'package:goviet_map_app/views/Onboarding/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await runSeeding();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => PlaceViewModel()..loadPlaces()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', 
      
      routes: {
        '/splash': (context) => const StartScreen(),
        '/onboarding': (context) => const OnBoardingScreen(),
        '/login': (context) => const SignInScreen(),
        '/home': (context) => const RootScreen(),
      },
    );
  }
}