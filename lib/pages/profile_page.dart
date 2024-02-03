import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinboard/components/text_box.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  //all users
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );

    //update in firestore
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Profile Page',
          style: TextStyle(fontFamily: "SometypeMono", color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Icon(
                  Icons.person,
                  size: 72,
                ),
                const SizedBox(height: 10),
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                MyTextBox(
                    sectionName: 'Username',
                    text: userData['username'],
                    onPressed: () => editField('username')),
                MyTextBox(
                    sectionName: 'Bio',
                    text: userData['bio'],
                    onPressed: () => editField('bio')),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Text(
                    'Habit Track',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                SingleChildScrollView(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("Users")
                        .doc(currentUser.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        List<dynamic> tasksAdmin =
                            userData['tasks_admin'] ?? [];

                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Wrap(
                            spacing: 8.0,
                            runSpacing: 16.0,
                            children: tasksAdmin.map<Widget>((taskAdmin) {
                              return FutureBuilder<DocumentSnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("Habits")
                                    .doc(taskAdmin)
                                    .get(),
                                builder: (context, taskSnapshot) {
                                  if (taskSnapshot.hasData) {
                                    final habitData = taskSnapshot.data!.data()
                                        as Map<String, dynamic>;

                                    // Create a container for each task
                                    return Container(
                                      width: MediaQuery.of(context).size.width /
                                              3 -
                                          16,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.0,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          habitData['habitName'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  } else if (taskSnapshot.hasError) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width /
                                              3 -
                                          16,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[600],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Error: ${taskSnapshot.error}',
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    );
                                  }
                                  // Loading indicator while fetching habit data
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3 -
                                            16,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Text('Error ${snapshot.error}'),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
