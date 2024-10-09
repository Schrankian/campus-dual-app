import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:campus_dual_android/widgets/sync_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

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

class _OverviewState extends State<Overview> with AutomaticKeepAliveClientMixin<Overview> {
  BodyOverviewData? dataCache;

  Stream<BodyOverviewData?> loadData() async* {
    final storage = StorageManager();
    try {
      final storedGeneralUserData = await storage.loadObject("generalUserData");
      final storedCurrentSemester = await storage.loadInt("currentSemester");
      final storedCreditPoints = await storage.loadInt("creditPoints");
      final storedExamStats = await storage.loadObject("examStats");

      if (storedGeneralUserData != null && storedCurrentSemester != null && storedCreditPoints != null && storedExamStats != null) {
        final data = BodyOverviewData(
          generalUserData: GeneralUserData.fromJson(storedGeneralUserData),
          currentSemester: storedCurrentSemester,
          creditPoints: storedCreditPoints,
          examStats: ExamStats.fromJson(storedExamStats),
        );
        dataCache = dataCache ?? data;
        yield data;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final cd = await CampusDualManager.withSharedSession();
    final generalUserData = await cd.scrapeGeneralUserData();
    storage.saveObject("generalUserData", generalUserData);
    final currentSemester = await cd.fetchCurrentSemester();
    storage.saveInt("currentSemester", currentSemester);
    final creditPoints = await cd.fetchCreditPoints();
    storage.saveInt("creditPoints", creditPoints);
    final examStats = await cd.fetchExamStats();
    storage.saveObject("examStats", examStats);

    final data = BodyOverviewData(
      generalUserData: generalUserData,
      currentSemester: currentSemester,
      creditPoints: creditPoints,
      examStats: examStats,
    );
    dataCache = data;
    yield data;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Color primaryOverride = Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.primary;
    Color onPrimaryOverride = Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onInverseSurface : Theme.of(context).colorScheme.onPrimary;

    return StreamBuilder(
      initialData: dataCache,
      stream: loadData(),
      builder: (context, snapshot) {
        final data = snapshot.hasError ? dataCache : snapshot.data;
        final dataHasArrived = data != null;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: const [0.7, 1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryOverride,
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: Stack(
                      alignment: AlignmentDirectional.topStart,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Hey",
                                    style: TextStyle(
                                      color: onPrimaryOverride,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    dataHasArrived ? "${data.generalUserData.firstName} (${CampusDualManager.userCreds!.username})" : '...',
                                    style: TextStyle(
                                      color: onPrimaryOverride,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Seminargruppe:",
                                    style: TextStyle(
                                      color: onPrimaryOverride,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    dataHasArrived ? data.generalUserData.group : '...',
                                    style: TextStyle(
                                      color: onPrimaryOverride,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: SyncIndicator(
                            state: snapshot.connectionState,
                            hasData: snapshot.hasData,
                            error: snapshot.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
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
                        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        child: Text(
                          dataHasArrived ? data.generalUserData.course : '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Fachsemester: ${dataHasArrived ? data.currentSemester.toString() : '...'} / 6',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: LinearProgressIndicator(
                                    minHeight: 15,
                                    borderRadius: BorderRadius.circular(6),
                                    value: dataHasArrived ? data.currentSemester / 6 : 0,
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryOverride),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'ECTS-Credits: ${dataHasArrived ? data.creditPoints.toString() : '...'} / 180',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: LinearProgressIndicator(
                                    minHeight: 15,
                                    borderRadius: BorderRadius.circular(6),
                                    value: dataHasArrived ? data.creditPoints / 180 : 0,
                                    valueColor: AlwaysStoppedAnimation<Color>(primaryOverride),
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
                                    color: primaryOverride,
                                    value: dataHasArrived ? 0 : 1,
                                    title: "Lädt...",
                                    titleStyle: TextStyle(color: onPrimaryOverride),
                                    radius: 125,
                                  ),
                                  PieChartSectionData(
                                    color: primaryOverride,
                                    value: dataHasArrived ? data.examStats.success / data.examStats.exams : 0,
                                    title: dataHasArrived ? "${(data.examStats.success / data.examStats.exams * 100).toStringAsFixed(0)}%" : "Lädt...",
                                    titleStyle: TextStyle(color: onPrimaryOverride),
                                    radius: 125,
                                  ),
                                  PieChartSectionData(
                                    color: Theme.of(context).colorScheme.error,
                                    value: dataHasArrived ? data.examStats.failure / data.examStats.exams : 0,
                                    title: dataHasArrived ? "${(data.examStats.failure / data.examStats.exams * 100).toStringAsFixed(0)}%" : "Lädt...",
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
                                    Text('${dataHasArrived ? data.examStats.exams : "..."}'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 12,
                                      color: primaryOverride,
                                    ),
                                    const Text('mit Erfolg abgeschlossen:'),
                                    Text('${dataHasArrived ? data.examStats.success : "..."}'),
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
                                    Text('${dataHasArrived ? data.examStats.failure : "..."}'),
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
                                    Text('${dataHasArrived ? data.examStats.mBooked : "..."}'),
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
                                    Text('${dataHasArrived ? data.examStats.modules : "..."}'),
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
      },
    );
  }
}
