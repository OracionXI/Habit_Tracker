import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinboard/onboarding_screen.dart';
import 'package:pinboard/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (FirebaseAuth.instance.currentUser != null) {
            return const HomePage();
          } else {
            return const OnBoardingScreen();
          }
        },
      ),
    );
  }
}
