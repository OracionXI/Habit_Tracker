import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage2 extends StatefulWidget {
  const IntroPage2({super.key});

  @override
  State<IntroPage2> createState() => _IntroPage2State();
}

class _IntroPage2State extends State<IntroPage2> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color.fromARGB(255, 244, 243, 242),
        Color.fromARGB(255, 231, 221, 189),
        Color.fromARGB(255, 224, 205, 163)
      ], transform: GradientRotation(40))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 350,
              height: 300,
              child: Lottie.asset('assets/animations/calendar4.json')),
          const SizedBox(height: 20),
          const Text(
            'Make a to-do list',
            style: TextStyle(fontFamily: 'SometypeMono', fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Track down your activities"',
            style: TextStyle(fontFamily: 'SometypeMono'),
          )
        ],
      ),
    );
  }
}
