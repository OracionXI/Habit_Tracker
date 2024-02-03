import 'package:flutter/material.dart';

class MyFloatingActionButton extends StatelessWidget {
  final Function()? onPressed;
  const MyFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
