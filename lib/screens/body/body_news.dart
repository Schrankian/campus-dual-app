import 'dart:convert';

import 'package:campus_dual_android/extensions/date.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:campus_dual_android/widgets/sync_indicator.dart';
import 'package:flutter/material.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> with AutomaticKeepAliveClientMixin<News> {
  Notifications? dataCache;

  Stream<Notifications> loadData() async* {
    final storage = StorageManager();
    try {
      final storedData = await storage.loadObject("notifications");
      if (storedData != null) {
        final data = Notifications.fromJson(storedData);
        dataCache = dataCache ?? data;
        yield data;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final cd = CampusDualManager();
    final notifications = await cd.fetchNotifications();
    storage.saveObject("notifications", notifications);
    dataCache = notifications;
    yield notifications;
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
          // TODO add better loading animation
          if (!dataHasArrived) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('News'),
              actions: [
                SyncIndicator(
                  state: snapshot.connectionState,
                  hasData: snapshot.hasData,
                  error: snapshot.error,
                ),
              ],
            ),
            body: SingleChildScrollView(
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
                  for (final upcomingItem in data.upcoming)
                    ListTile(
                      leading: Text(upcomingItem.date.toDateString()),
                      title: Text(upcomingItem.moduleTitle),
                      trailing: Text(upcomingItem.type),
                      subtitle: Text("Raum: ${upcomingItem.room} | ${upcomingItem.begin.toTimeDiff(upcomingItem.end)} "),
                    ),
                  if (data.upcoming.isEmpty)
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
                  for (final latestItem in data.latest)
                    ListTile(
                      trailing: Text(latestItem.dateGraded.toDateString()),
                      title: Text(latestItem.moduleTitle),
                      leading: Text(
                        latestItem.grade.toString().replaceAll(".", ","),
                        style: TextStyle(fontSize: 20),
                      ),
                      subtitle: Text(latestItem.status),
                    ),
                  if (data.latest.isEmpty)
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
            ),
          );
        });
  }
}
