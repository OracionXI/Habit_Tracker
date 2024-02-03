import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinboard/components/wall_post.dart';

class WallPage extends StatelessWidget {
  WallPage({super.key});

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

  void cancelWall() {
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'The Wall',
          style: TextStyle(fontFamily: "SometypeMono", color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .orderBy(
                          "TimeStamp",
                          descending: true,
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = snapshot.data!.docs[index];
                            return WallPost(
                              message: post['Message'],
                              user: post['UserEmail'],
                              postId: post.id,
                              likes: List<String>.from(post["Likes"] ?? []),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      color: Colors.grey[200],
                      child: TextField(
                        controller: textController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          hintText: "Share your day...",
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(Icons.arrow_circle_up),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text("Logged in as: ${currentUser.email}"),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
