import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Overview extends StatefulWidget {
  const Overview({super.key});

  @override
  State<Overview> createState() => _OverviewState();
}

class BodyOverviewData {
  GeneralUserData generalUserData;
  int currentSemester;
  int creditPoints;
  ExamStats examStats;

  BodyOverviewData({
    required this.generalUserData,
    required this.currentSemester,
    required this.creditPoints,
    required this.examStats,
  });
}

class _OverviewState extends State<Overview> with AutomaticKeepAliveClientMixin<Overview>{

  BodyOverviewData? dataCache;

  Future<BodyOverviewData> loadData() async {
    final cd = CampusDualManager();
    print("loading............................................data");
    final generalUserData = await cd.scrapeGeneralUserData();
    final currentSemester = await cd.fetchCurrentSemester();
    final creditPoints = await cd.fetchCreditPoints();
    final examStats = await cd.fetchExamStats();

    return BodyOverviewData(generalUserData: generalUserData, currentSemester: currentSemester, creditPoints: creditPoints, examStats: examStats);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: FutureBuilder(
        initialData: dataCache,
        future: loadData(),
        builder: (context, snapshot) {
          final dataHasArrived =  snapshot.hasData;

          if(snapshot.connectionState == ConnectionState.done){
            dataCache = snapshot.data;
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                stops: const [0.7, 1],
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
                                'Hey, ${snapshot.connectionState == ConnectionState.done ? "Finished" : "loading..."}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                      dataHasArrived ? "${snapshot.data!.generalUserData.firstName} (${CampusDualManager.userCreds!.username})" : '... (${CampusDualManager.userCreds!.username})',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onPrimary,
                                        fontSize: 22,
                                      ),
                                    ),
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
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
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
                              Column(
                                    children: [
                                      Text(
                                        'Fachsemester: ${dataHasArrived ? snapshot.data!.currentSemester.toString() : '...'} / 6',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: LinearProgressIndicator(
                                          minHeight: 15,
                                          borderRadius: BorderRadius.circular(10),
                                          value: dataHasArrived ? snapshot.data!.currentSemester / 6 : 0,
                                          backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(80),
                                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                              Column(
                                    children: [
                                      Text(
                                        'ECTS-Credits: ${dataHasArrived ? snapshot.data!.creditPoints.toString() : '...'} / 180',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: LinearProgressIndicator(
                                          minHeight: 15,
                                          borderRadius: BorderRadius.circular(10),
                                          value: dataHasArrived ? snapshot.data!.creditPoints / 180 : 0,
                                          backgroundColor: Theme.of(context).colorScheme.secondary.withAlpha(80),
                                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                                        ),
                                      ),
                                    ],
                                  ),
                            ],
                          ),
                        ),
                        Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 30),
                                  height: 250,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          color: Theme.of(context).colorScheme.secondary,
                                          value: dataHasArrived ? 0 : 1,
                                          title: "Lädt...",
                                          titleStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                                          radius: 125,
                                        ),
                                        PieChartSectionData(
                                          color: Theme.of(context).colorScheme.primary,
                                          value: dataHasArrived ? snapshot.data!.examStats.success / snapshot.data!.examStats.exams : 0,
                                          title: dataHasArrived ? "${(snapshot.data!.examStats.success / snapshot.data!.examStats.exams * 100).toStringAsFixed(0)}%" : "Lädt...",
                                          titleStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                          radius: 125,
                                        ),
                                        PieChartSectionData(
                                          color: Theme.of(context).colorScheme.error,
                                          value: dataHasArrived ? snapshot.data!.examStats.failure / snapshot.data!.examStats.exams : 0,
                                          title: dataHasArrived ? "${(snapshot.data!.examStats.failure / snapshot.data!.examStats.exams * 100).toStringAsFixed(0)}%" : "Lädt...",
                                          titleStyle: TextStyle(color: Theme.of(context).colorScheme.onError),
                                          radius: 125,
                                        ),
                                      ],
                                    ),
                                    swapAnimationDuration: const Duration(milliseconds: 150),
                                    swapAnimationCurve: Curves.linear,
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  width: 250,
                                  height: 200,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Prüfungsversuche insgesamt:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('${dataHasArrived ? snapshot.data!.examStats.exams : "..."}'),
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
                                          const Text('mit Erfolg abgeschlossen:'),
                                          Text('${dataHasArrived ? snapshot.data!.examStats.success : "..."}'),
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
                                          const Text('ohne Erfolg abgeschlossen:'),
                                          Text('${dataHasArrived ? snapshot.data!.examStats.failure : "..."}'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Gebuchte Module:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('${dataHasArrived ? snapshot.data!.examStats.mBooked : "..."}'),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Abgeschlossene Module:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text('${dataHasArrived ? snapshot.data!.examStats.modules : "..."}'),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}
