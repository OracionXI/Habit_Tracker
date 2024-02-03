import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinboard/components/datetime/date_time.dart';
import 'package:pinboard/components/my_button.dart';
import 'package:pinboard/components/my_textfield.dart';
import 'package:pinboard/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();

  final passwordTextController = TextEditingController();
  final confirmPasswordTextController = TextEditingController();

  String now = todaysDateFormatted();

  void signUp() async {
    showDialog(
        context: context,
        builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ));
    if (passwordTextController.text != confirmPasswordTextController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password do not match!'),
        ),
      );
      return;
    }
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailTextController.text,
              password: passwordTextController.text);

      //Database
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailTextController.text.split('@')[0],
        'email': userCredential.user!.email,
        'bio': 'Empty bio',
        'tasks_admin': [],
        'createdAt': now,
      });

      if (context.mounted) Navigator.pop(context);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 50),
              const Icon(Icons.lock, size: 100),
              const SizedBox(height: 50),
              const Text(
                "Let's create an account for you!",
                style: TextStyle(),
              ),
              const SizedBox(height: 25),
              MyTextField(
                  controller: emailTextController,
                  hintText: 'Email',
                  obscureText: false),
              const SizedBox(height: 10),
              MyTextField(
                  controller: passwordTextController,
                  hintText: 'Password',
                  obscureText: true),
              const SizedBox(height: 10),
              MyTextField(
                  controller: confirmPasswordTextController,
                  hintText: 'Confirm Password',
                  obscureText: true),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.grey[600]),
                  )
                ]),
              ),
              const SizedBox(
                height: 25,
              ),
              MyButton(
                onTap: signUp,
                text: 'Sign Up',
              ),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already a member?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ]),
          ),
        ),
      ),
    );
  }
}
