import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/widgets/day_calendar.dart';
import 'package:campus_dual_android/widgets/day_picker.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> with AutomaticKeepAliveClientMixin<TimeTable> {
  static const bufferSize = 10;

  Map<DateTime, List<Lesson>>? dataCache;

  late DateTime currentDate;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    currentDate = DateTime(now.year, now.month, now.day);
  }

  Future<Map<DateTime, List<Lesson>>> fetchData() async {
    final cd = CampusDualManager();

    final lessons = await cd.fetchTimeTable(currentDate.subtract(const Duration(days: bufferSize)), currentDate.add(const Duration(days: bufferSize)));

    dataCache = lessons;
    return lessons;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stundenplan'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              iconSize: 35,
              icon: const Icon(Ionicons.home_outline),
              onPressed: () {
                setState(() {
                  DateTime now = DateTime.now();
                  currentDate = DateTime(now.year, now.month, now.day);
                });
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        initialData: dataCache,
        future: fetchData(),
        builder: ((context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred'),
            );
          }
          return Column(
            children: [
              DayPicker(
                currentDate: currentDate,
                onDateChanged: (date) {
                  setState(() {
                    currentDate = date;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 10) {
                      setState(() {
                        currentDate = currentDate.subtract(const Duration(days: 1));
                      });
                    } else if (details.primaryVelocity! < -10) {
                      setState(() {
                        currentDate = currentDate.add(const Duration(days: 1));
                      });
                    }
                  },
                  child: DayCalendar(
                    items: snapshot.data![currentDate],
                    startHour: 7,
                    endHour: 20,
                    stepSize: 65,
                    useFuzzyColor: true,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
