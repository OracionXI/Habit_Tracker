import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:pinboard/components/datetime/date_time.dart';

final _myBox = Hive.box('Habit_Database');

class HabitDatabase {
  List<Map<String, dynamic>> todaysHabitList = [];
  Map<DateTime, int> heatMapDataSet = {};

  void createDefaultData() {
    _myBox.put("START_DATE", todaysDateFormatted());
  }

  void updateDatabase() {
    calculateHabitPercentage();
    loadHeatMap();
  }

  void calculateHabitPercentage() {
    int countCompleted = 0;
    for (int i = 0; i < todaysHabitList.length; i++) {
      if (todaysHabitList[i]['completed'] == true) {
        countCompleted++;
      }
    }
    String percentage = todaysHabitList.isEmpty
        ? '0.0'
        : (countCompleted / todaysHabitList.length).toStringAsFixed(1);
    _myBox.put("PECENTAGE_SUMMARY_${todaysDateFormatted()}", percentage);
  }

  void loadHeatMap() {
    DateTime startDate = createDateTimeObject(_myBox.get("START_DATE"));
    int daysInBetween = DateTime.now().difference(startDate).inDays;

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd = convertDateTimeToString(
        startDate.add(Duration(days: i)),
      );

      double strength = double.parse(
        _myBox.get("PECENTAGE_SUMMARY_$yyyymmdd") ?? 0.0,
      );

      int year = startDate.add(Duration(days: i)).year;
      int month = startDate.add(Duration(days: i)).month;
      int day = startDate.add(Duration(days: i)).day;

      final percentForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strength).toInt(),
      };

      heatMapDataSet.addEntries(percentForEachDay.entries);
    }
  }

  Future<void> saveToFirebase(String date, String percentage) async {
    try {
      await FirebaseFirestore.instance.collection('Heatmap').doc(date).set({
        'summary': "PECENTAGE_SUMMARY_$date",
        'percent': percentage,
      });
    } catch (e) {
      //will show error
    }
  }
}
