import 'package:campus_dual_android/extensions/date.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:flutter/material.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> with AutomaticKeepAliveClientMixin<News> {
  Notifications? dataCache;

  Future<Notifications> loadData() async {
    final cd = CampusDualManager();
    final notifications = await cd.fetchNotifications();

    dataCache = notifications;
    return notifications;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: FutureBuilder(
          initialData: dataCache,
          future: loadData(),
          builder: (context, snapshot) {
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

            return SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                    child: Text(
                      "Anstehende Prüfungen:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (final upcomingItem in snapshot.data!.upcoming)
                    ListTile(
                      leading: Text(upcomingItem.date.toDateString()),
                      title: Text(upcomingItem.moduleTitle),
                      trailing: Text(upcomingItem.type),
                      subtitle: Text("Raum: ${upcomingItem.room} | ${upcomingItem.begin.toTimeDiff(upcomingItem.end)} "),
                    ),
                  if (snapshot.data!.upcoming.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: Center(
                        child: Text(
                          "Keine Anstehenden Prüfungen",
                        ),
                      ),
                    ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                    child: Text(
                      "Letzte Ergebnisse:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  for (final latestItem in snapshot.data!.latest)
                    ListTile(
                      title: Text(latestItem.toString()),
                      subtitle: Text(latestItem.toString()),
                    ),
                  if (snapshot.data!.latest.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                      child: Center(
                        child: Text(
                          "Keine letzten Ergebnisse",
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
    );
  }
}
