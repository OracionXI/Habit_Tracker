import 'package:flutter/material.dart';
import 'package:pinboard/intro_screens/intro_page_1.dart';
import 'package:pinboard/intro_screens/intro_page_2.dart';
import 'package:pinboard/intro_screens/intro_page_3.dart';
import 'package:pinboard/services/auth/login_or_register.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              onLastPage = (index == 2);
            });
          },
          children: const [IntroPage1(), IntroPage2(), IntroPage3()],
        ),
        Container(
            alignment: const Alignment(0, 0.75),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                    onTap: () {
                      _controller.jumpToPage(2);
                    },
                    child: const Text('skip',
                        style: TextStyle(fontFamily: 'SometypeMono'))),
                SmoothPageIndicator(controller: _controller, count: 3),
                onLastPage
                    ? GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const LoginOrRegister();
                          }));
                        },
                        child: const Text('done',
                            style: TextStyle(fontFamily: 'SometypeMono')))
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeIn);
                        },
                        child: const Text('next',
                            style: TextStyle(fontFamily: 'SometypeMono')))
              ],
            ))
      ],
    ));
  }
}
