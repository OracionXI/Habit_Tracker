import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final CollectionReference habitCollection =
  FirebaseFirestore.instance.collection('Habits');

  Future<String> addHabit(String habitName, bool completed, String userEmail,
      List<String> assignees, DateTime createdAt) async {
    try {
      final docRef = await habitCollection.add({
        'habitName': habitName,
        'completed': completed,
        'userEmail': userEmail,
        'assignees': assignees,
        'createdAt': createdAt,
      });

      final habitId = docRef.id;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .update({
        'tasks_admin': FieldValue.arrayUnion([habitId]),
      });
      return habitId;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateHabit(
      String habitId, Map<String, dynamic> updateData) async {
    try {
      await habitCollection.doc(habitId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(String habitId, String userEmail) async {
    try {
      await habitCollection.doc(habitId).delete();
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .update({
        'tasks_admin': FieldValue.arrayRemove([habitId]),
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> fetchHabitStream(String userEmail) {
    try {
      return FirebaseFirestore.instance
          .collection('Users')
          .doc(userEmail)
          .snapshots()
          .asyncMap((userDoc) async {
        List<dynamic> tasksAdmin = userDoc.data()?['tasks_admin'] ?? [];

        if (tasksAdmin.isNotEmpty) {
          final querySnapshot = await habitCollection
              .where(FieldPath.documentId, whereIn: tasksAdmin)
              .get();

          return querySnapshot.docs
              .map((doc) => {
            'id': doc.id,
            'habitName': doc['habitName'],
            'completed': doc['completed'],
            'userEmail': doc['userEmail'],
            'assignees': doc['assignees'] ?? [],
            'createdAt': doc['createdAt'],
          })
              .toList();
        } else {
          return [];
        }
      });
    } catch (e) {
      rethrow;
    }
  }
}
