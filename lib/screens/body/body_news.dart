
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:flutter/material.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> with AutomaticKeepAliveClientMixin<News>{
  Notifications? dataCache;

  Future<Notifications> loadData() async {
    final cd = CampusDualManager();
    final notifications = await cd.fetchNotifications();

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

            if(snapshot.connectionState == ConnectionState.done){
            dataCache = snapshot.data;
            }

            return SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                children: [
                  const Text("Anstehende Prüfungen:"),
                  for(final upcomingItem in snapshot.data!.upcoming)
                    ListTile(
                          leading: Text("${upcomingItem.begin.hour}->${upcomingItem.end.hour}"),
                          title: Text(upcomingItem.moduleTitle),
                          trailing: Text("(${upcomingItem.instructor})"),
                          subtitle: Text("${upcomingItem.date} Raum: ${upcomingItem.room}"),
                        ),
                  const Text("Letzte Ergebnisse:"),
                  for(final latestItem in snapshot.data!.latest)
                    ListTile(
                          title: Text(latestItem.toString()),
                          subtitle: Text(latestItem.toString()),
                        ),
                ],
              ),
            );
          }),
    );
  }
}
