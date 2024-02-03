import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinboard/components/datetime/date_time.dart';
import 'package:pinboard/components/drawer.dart';
import 'package:pinboard/components/monthly_summary.dart';
import 'package:pinboard/components/my_alert_box.dart';
import 'package:pinboard/components/my_fab.dart';
import 'package:pinboard/components/new_habit_box.dart';
import 'package:pinboard/pages/profile_page.dart';
import 'package:pinboard/pages/wall_page.dart';
import 'package:pinboard/services/auth/auth_gate.dart';
import 'package:pinboard/services/local_database.dart';

import '../components/habit_tile.dart';
import '../services/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final currentUser = FirebaseAuth.instance.currentUser!;
  final DatabaseService _databaseService = DatabaseService();
  HabitDatabase db = HabitDatabase();
  String startDate = todaysDateFormatted();

  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  List<Map<String, dynamic>> todaysHabitList = [];

  @override
  void initState() {
    super.initState();
    fetchUserCreatedAt();
    fetchHabits();
    db.createDefaultData();
  }

  Future<void> _onRefresh() async {
    fetchUserCreatedAt();
    fetchHabits();
  }

  //FETCHING USERDATA
  void fetchUserCreatedAt() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();

      if (userDoc.exists) {
        setState(() {
          startDate = userDoc['createdAt'];
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch User data. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
  }

  void fetchHabits() {
    try {
      _databaseService.fetchHabitStream(currentUser.email!).listen(
          (List<Map<String, dynamic>> habits) {
        if (!mounted) return;
        setState(() {
          db.todaysHabitList = habits;
        });
        db.updateDatabase();
      }, onError: (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not fetch data. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not fetch data. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  //CHECKBOX BOOL
  void checkBoxTapped(bool? value, int index) async {
    final habitId = db.todaysHabitList[index]['id'];

    try {
      await _databaseService.updateHabit(habitId, {'completed': value});
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating habit. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      db.todaysHabitList[index]['completed'] = value;
    });
    db.updateDatabase();
  }

  final _newHabitNameController = TextEditingController();
  final _newHabitAssigneeController = TextEditingController();

  //CREATING NEW HABIT
  void saveNewHabit() async {
    DateTime creationDate = DateTime.now();
    if (_newHabitNameController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Habit name cannot be empty.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      var newHabitId = await _databaseService.addHabit(
          _newHabitNameController.text,
          false,
          currentUser.email!,
          (_newHabitAssigneeController.text.isNotEmpty &&
                  _newHabitAssigneeController.text != currentUser.email &&
                  _newHabitAssigneeController.text.contains('@'))
              ? [_newHabitAssigneeController.text]
              : [],
          creationDate);

      if (mounted) {
        setState(() {
          db.todaysHabitList.add({
            'id': newHabitId,
            'habitName': _newHabitNameController.text,
            'completed': false,
            'userEmail': currentUser.email,
            'assignees': (_newHabitAssigneeController.text.isNotEmpty &&
                    _newHabitAssigneeController.text != currentUser.email &&
                    _newHabitAssigneeController.text.contains('@'))
                ? [_newHabitAssigneeController.text]
                : [],
            'createdAt': creationDate
          });
        });
        db.updateDatabase();

        _newHabitNameController.clear();
        _newHabitAssigneeController.clear();

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New task has been created!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'An error occurred'),
          ),
        );
      }
    }
  }

  //MODIFYING HABIT
  void saveExistingHabit(int index) async {
    final habitId = db.todaysHabitList[index]['id'];

    // Check if the assignee email is the same as the current user's email
    if (_newHabitAssigneeController.text == currentUser.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User cannot assign a task to themselves.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Assignee update
    if (_newHabitAssigneeController.text.isNotEmpty &&
        _newHabitAssigneeController.text.contains('@')) {
      final assigneeEmail = _newHabitAssigneeController.text;

      var usersCollection = FirebaseFirestore.instance.collection('Users');
      var doc = await usersCollection.doc(assigneeEmail).get();

      if (!mounted) return;

      if (doc.exists) {
        await _databaseService.updateHabit(habitId, {
          'assignees': FieldValue.arrayUnion([assigneeEmail])
        });

        usersCollection.doc(assigneeEmail).update({
          'tasks_admin': FieldValue.arrayUnion([habitId])
        });

        setState(() {
          db.todaysHabitList[index]['assignees'].add(assigneeEmail);
        });

        _showSnackBar('Habit updated successfully!');
      } else {
        _showSnackBar('Invalid assignee email. User does not exist.');
        return;
      }
    }

    // Habit name update
    if (_newHabitNameController.text.isNotEmpty) {
      await _databaseService.updateHabit(habitId, {
        'habitName': _newHabitNameController.text,
      });

      setState(() {
        db.todaysHabitList[index]['habitName'] = _newHabitNameController.text;
      });
    }
    db.updateDatabase();

    _newHabitNameController.clear();
    _newHabitAssigneeController.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  //DELETING HABIT
  void deleteHabit(int index) async {
    final habitId = db.todaysHabitList[index]['id'];

    try {
      await _databaseService.deleteHabit(habitId, currentUser.email!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting habit. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      db.todaysHabitList.removeAt(index);
    });
    db.updateDatabase();
  }

  void cancelDialogBox() {
    _newHabitNameController.clear();
    _newHabitAssigneeController.clear();
    Navigator.of(context).pop();
  }

  void createNewHabit() {
    showDialog(
      context: context,
      builder: (context) {
        return EnterNewHabit(
          controller: _newHabitNameController,
          hintText: "Enter Task Title",
          onSave: saveNewHabit,
          onCancel: cancelDialogBox,
        );
      },
    );
  }

  void openHabitSettings(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyAlertBoxPage(
          controller: _newHabitNameController,
          assigneeController: _newHabitAssigneeController,
          hintText: db.todaysHabitList[index]['habitName'],
          onSave: () => saveExistingHabit(index),
          onCancel: cancelDialogBox,
        ),
      ),
    );
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void goToWallPage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WallPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      floatingActionButton: MyFloatingActionButton(onPressed: createNewHabit),
      appBar: AppBar(
        title: const Text(
          'Pinboard',
          style: TextStyle(fontFamily: "SometypeMono", color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
        onWall: goToWallPage,
      ),
      body: Column(
        children: [
          MonthlySummary(
            datasets: db.heatMapDataSet,
            startDate: startDate,
          ),
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _onRefresh,
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _databaseService.fetchHabitStream(currentUser.email!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "Add daily tasks...",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    );
                  } else {
                    List<Map<String, dynamic>> habitList = snapshot.data!;
                    return SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: habitList.length,
                        itemBuilder: (context, index) {
                          return HabitTile(
                            habitName: habitList[index]['habitName'],
                            habitCompleted: habitList[index]['completed'],
                            onChanged: (value) => checkBoxTapped(value, index),
                            settingsTapped: (context) =>
                                openHabitSettings(index),
                            deleteTapped: (context) => deleteHabit(index),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
