import 'package:campus_dual_android/extensions/date.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:campus_dual_android/widgets/day_calendar.dart';
import 'package:campus_dual_android/widgets/day_picker.dart';
import 'package:campus_dual_android/widgets/month_calendar.dart';
import 'package:campus_dual_android/widgets/sync_indicator.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> with AutomaticKeepAliveClientMixin<TimeTable> {
  static const bufferSize = 365;
  static const includePast = true; // TODO implement

  final GlobalKey _dateSectionKey = GlobalKey();

  Map<DateTime, List<Lesson>>? dataCache;

  late DateTime currentDate;
  late DateTime nowDay;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    nowDay = now.trim();
    currentDate = nowDay;

    mainBus.onBus(event: "OpenCalendar", onEvent: _openCalendar);
  }

  @override
  void dispose() {
    mainBus.offBus(event: "OpenCalendar", callBack: _openCalendar);
    super.dispose();
  }

  Stream<Map<DateTime, List<Lesson>>> loadData() async* {
    final storage = StorageManager();
    try {
      final storedData = await storage.loadObject("timetable");
      if (storedData != null) {
        final data = storedData.map((key, value) => MapEntry(DateTime.parse(key), (value as List).map((e) => Lesson.fromJson(e)).toList())).cast<DateTime, List<Lesson>>();
        dataCache = dataCache ?? data;
        yield data;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final cd = CampusDualManager();
    final lessons = await cd.fetchTimeTable(nowDay.subtract(const Duration(days: bufferSize)), nowDay.add(const Duration(days: bufferSize)));
    storage.saveObject("timetable", lessons.map((key, value) => MapEntry(key.toIso8601String(), value.map((e) => e.toJson()).toList())));
    dataCache = lessons;
    yield lessons;
  }

  void _openCalendar(dynamic args) {
    Navigator.push(
      args,
      MaterialPageRoute(
        builder: (context) => MonthCalendar(
          startTime: currentDate,
          items: dataCache,
          onDateClicked: (date) => {
            _dateSectionKey.currentState?.setState(() {
              currentDate = date;
            })
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return StreamBuilder(
      initialData: dataCache,
      stream: loadData(),
      builder: (context, snapshot) {
        final data = snapshot.hasError ? dataCache : snapshot.data;
        final dataHasArrived = data != null;

        return Scaffold(
          appBar: AppBar(
            title: Transform.translate(
              offset: const Offset(50, 0),
              child: const Text('Stundenplan'),
            ),
            actions: [
              SyncIndicator(
                state: snapshot.connectionState,
                hasData: snapshot.hasData,
                error: snapshot.error,
              ),
            ],
          ),
          body: StatefulBuilder(
            key: _dateSectionKey,
            // TODO test if once parent rebuilds, this also rebuilds
            builder: (context, setState) {
              return Column(
                children: [
                  DayPicker(
                    currentDate: currentDate,
                    onDateChanged: (date) {
                      setState(() {
                        currentDate = date.trim();
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 10) {
                          setState(() {
                            currentDate = currentDate.subtract(const Duration(days: 1)).trim();
                          });
                        } else if (details.primaryVelocity! < -10) {
                          setState(() {
                            currentDate = currentDate.add(const Duration(days: 1)).trim();
                          });
                        }
                      },
                      child: DayCalendar(
                        items: dataHasArrived ? data[currentDate] : [],
                        startHour: 7,
                        endHour: 20,
                        stepSize: 65,
                        useFuzzyColor: true,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
