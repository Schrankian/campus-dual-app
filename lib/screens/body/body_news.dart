import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:flutter/material.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News'),
      ),
      body: FutureBuilder(
          future: CampusDualManager().fetchNotifications(),
          builder: (context, snapshot) {
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
                Text("Anstehende Prüfungen:"),
                SizedBox(
                  height: 350,
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    itemCount: snapshot.data!.upcoming.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data!.upcoming[index].moduleTitle),
                        subtitle: Text(snapshot.data!.upcoming[index].date.toString()),
                      );
                    },
                  ),
                ),
                Text("Letzte Ergebnisse:"),
                SizedBox(
                  height: 350,
                  child: ListView.builder(
                    physics: const ScrollPhysics(),
                    itemCount: snapshot.data!.latest.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data!.latest[index].toString()),
                        subtitle: Text(snapshot.data!.latest[index].toString()),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
    );
  }
}
