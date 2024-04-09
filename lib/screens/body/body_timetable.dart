import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:flutter/material.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({super.key});

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  DateTime now = DateTime.now().toLocal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Stundenplan'),
        ),
        body: FutureBuilder(
            future: CampusDualManager().fetchTimeTable(DateTime(now.year, now.month, now.day, 0, 0, 0), DateTime(now.year, now.month, now.day, 23, 0, 0)),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
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
                  Text("Stundenplan:"),
                  SizedBox(
                    height: 600,
                    child: ListView.builder(
                      physics: const ScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].title),
                          subtitle: Text(snapshot.data![index].room),
                        );
                      },
                    ),
                  ),
                ],
              );
            })));
  }
}
