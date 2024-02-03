import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAlertBoxPage extends StatelessWidget {
  final TextEditingController controller;
  final TextEditingController assigneeController;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String hintText;

  MyAlertBoxPage({
    super.key,
    required this.controller,
    required this.assigneeController,
    required this.onSave,
    required this.onCancel,
    required this.hintText,
  });

  final currentUser = FirebaseAuth.instance.currentUser!;

  final textController = TextEditingController();

  void postMessage() {
    if (textController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('User Posts').add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Habit Details',
          style: TextStyle(fontFamily: "SometypeMono", color: Colors.white),
        ),
        leading: IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(onPressed: onSave, icon: const Icon(Icons.save_as))
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[800],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              "Task Title",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Assignee Email",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: assigneeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Assignee's Email",
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Notes down",
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: "Note down something...",
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                
              ],
            ),
          ],
        ),
      ),
    );
  }
}
