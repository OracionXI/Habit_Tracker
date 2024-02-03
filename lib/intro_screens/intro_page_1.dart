import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage1 extends StatefulWidget {
  const IntroPage1({super.key});

  @override
  State<IntroPage1> createState() => _IntroPage1State();
}

class _IntroPage1State extends State<IntroPage1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 244, 243, 242),
        Color.fromARGB(255, 231, 221, 189),
        Color.fromARGB(255, 224, 205, 163)
      ], transform: GradientRotation(70))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to Pinboard',
            style: TextStyle(
              fontSize: 23,
              fontFamily: 'SometypeMono',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Plan your way of life"',
            style: TextStyle(fontFamily: "SometypeMono"),
          ),
          const SizedBox(height: 30),
          Lottie.asset('assets/animations/calendar1.json'),
        ],
      ),
    );
  }
}
