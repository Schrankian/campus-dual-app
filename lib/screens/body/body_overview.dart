import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            stops: [0.7, 1],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Matrikelnummer:',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 22,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            CampusDualManager.userCreds!.username,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  border: Border.all(color: Theme.of(context).colorScheme.background, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withAlpha(70),
                      blurRadius: 10.0,
                    ),
                  ],
                ),
                child: ListView(
                  physics: const ScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FutureBuilder(
                            future: CampusDualManager().fetchCurrentSemester(),
                            builder: (context, snapshot) {
                              bool isDone = snapshot.connectionState == ConnectionState.done;
                              return Column(
                                children: [
                                  Text(
                                    'Fachsemester: ${isDone ? snapshot.data.toString() : '...'} / 6',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: LinearProgressIndicator(
                                      minHeight: 15,
                                      borderRadius: BorderRadius.circular(10),
                                      value: isDone ? snapshot.data! / 6 : 0,
                                      backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(80),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          FutureBuilder(
                            future: CampusDualManager().fetchCreditPoints(),
                            builder: (context, snapshot) {
                              bool isDone = snapshot.connectionState == ConnectionState.done;
                              return Column(
                                children: [
                                  Text(
                                    'ECTS-Credits: ${isDone ? snapshot.data.toString() : '...'} / 180',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 150,
                                    child: LinearProgressIndicator(
                                      minHeight: 15,
                                      borderRadius: BorderRadius.circular(10),
                                      value: isDone ? snapshot.data! / 180 : 0,
                                      backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(80),
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder(
                      future: CampusDualManager().fetchExamStats(),
                      builder: (context, snapshot) {
                        bool isDone = snapshot.connectionState == ConnectionState.done;
                        return Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              height: 250,
                              child: PieChart(
                                PieChartData(
                                  sections: [
                                    PieChartSectionData(
                                      color: Theme.of(context).colorScheme.secondary,
                                      value: isDone ? 0 : 1,
                                      title: "Lädt...",
                                      titleStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                                      radius: 125,
                                    ),
                                    PieChartSectionData(
                                      color: Theme.of(context).colorScheme.primary,
                                      value: isDone ? snapshot.data!.success / snapshot.data!.exams : 0,
                                      title: isDone ? "${(snapshot.data!.success / snapshot.data!.exams * 100).toStringAsFixed(0)}%" : "Lädt...",
                                      titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                      radius: 125,
                                    ),
                                    PieChartSectionData(
                                      color: Theme.of(context).colorScheme.error,
                                      value: isDone ? snapshot.data!.failure / snapshot.data!.exams : 0,
                                      title: isDone ? "${(snapshot.data!.failure / snapshot.data!.exams * 100).toStringAsFixed(0)}%" : "Lädt...",
                                      titleStyle: TextStyle(color: Theme.of(context).colorScheme.onError),
                                      radius: 125,
                                    ),
                                  ],
                                ),
                                swapAnimationDuration: Duration(milliseconds: 150),
                                swapAnimationCurve: Curves.linear,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              width: 250,
                              height: 200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Prüfungsversuche insgesamt:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('${isDone ? snapshot.data!.exams : "..."}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      Text('mit Erfolg abgeschlossen:'),
                                      Text('${isDone ? snapshot.data!.success : "..."}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 12,
                                        width: 12,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      Text('ohne Erfolg abgeschlossen:'),
                                      Text('${isDone ? snapshot.data!.failure : "..."}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Gebuchte Module:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('${isDone ? snapshot.data!.mBooked : "..."}'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Abgeschlossene Module:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text('${isDone ? snapshot.data!.modules : "..."}'),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
