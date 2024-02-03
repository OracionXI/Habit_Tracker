import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntroPage3 extends StatelessWidget {
  const IntroPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromARGB(255, 244, 243, 242),
          Color.fromARGB(255, 231, 221, 189),
          Color.fromARGB(255, 224, 205, 163)
        ], transform: GradientRotation(70))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text(
            'Task Completed!',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'SometypeMono',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '"Highlight completions on calendar"',
            style: TextStyle(fontFamily: "SometypeMono"),
          ),
          const SizedBox(height: 15),
          Lottie.asset('assets/animations/calendar3.json'),
        ]));
  }
}
