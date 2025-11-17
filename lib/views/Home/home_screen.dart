import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 500,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff80B966),
                  Color(0xff71A759),
                  Color(0xff6CA155),
                  Color(0xff588D40),
                  Color(0xff4D8235),
                ],
                stops: [0.0, 0.29, 0.44, 0.75, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter 
              )
            ),
          )
        ],
      ),
    );
  }
}