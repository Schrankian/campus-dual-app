import 'package:campus_dual_android/extensions/double.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:campus_dual_android/widgets/semester_evaluations.dart';
import 'package:campus_dual_android/widgets/sync_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> with AutomaticKeepAliveClientMixin<EvaluationsPage> {
  List<MasterEvaluation>? dataCache;

  @override
  void initState() {
    super.initState();
    mainBus.onBus(event: "OpenSemesterEvaluations", onEvent: _openSemesterEvaluations);
  }

  @override
  void dispose() {
    mainBus.offBus(event: "OpenSemesterEvaluations", callBack: _openSemesterEvaluations);
    super.dispose();
  }

  void _sortData(List<MasterEvaluation> data) {
    data.sort((a, b) => b.subEvaluations[0].dateAnnounced.compareTo(a.subEvaluations[0].dateAnnounced));
  }

  Stream<List<MasterEvaluation>> loadData() async* {
    final storage = StorageManager();
    try {
      final storedData = await storage.loadObjectList("evaluations");
      if (storedData != null) {
        final data = List<MasterEvaluation>.from(storedData.map((e) => MasterEvaluation.fromJson(e)));
        _sortData(data);
        dataCache = dataCache ?? data;
        yield data;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    final cd = CampusDualManager();
    final evaluations = await cd.scrapeEvaluations(); // TODO lazy load the evaluations. E.g. load as Stream (maybe only if its the first time)
    storage.saveObjectList("evaluations", evaluations);
    _sortData(evaluations);
    dataCache = evaluations;
    yield evaluations;
  }

  void _openSemesterEvaluations(dynamic args) {
    Navigator.push(
      args,
      MaterialPageRoute(
        builder: (context) => SemesterEvaluations(
          items: dataCache,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  final _successColor = Colors.green;
  final _failureColor = Colors.red;

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
            title: const Text('Noten'),
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
              children: dataHasArrived
                  ? [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        child: Container(
                          alignment: Alignment.center,
                          height: 80,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withAlpha(220),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Durchschnitt",
                                style: TextStyle(
                                  fontSize: 21,
                                ),
                              ),
                              Text(
                                (data.where((e) => e.grade != -1).map((e) => e.grade).reduce((a, b) => a + b) / data.where((e) => e.grade != -1).length).toStringAsFixed(2).replaceAll(".", ","),
                                style: const TextStyle(
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (final evaluation in data)
                        Column(
                          children: [
                            ListTile(
                              title: Text(evaluation.title),
                              trailing: Badge(
                                largeSize: 32,
                                padding: const EdgeInsets.only(left: 20, right: 20),
                                backgroundColor: evaluation.isPassed ? _successColor : _failureColor,
                                textColor: Colors.white,
                                label: Text(evaluation.grade == -1 ? "Teilgenommen" : evaluation.grade.toString().replaceAll(".", ",")),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              subtitle: Text(evaluation.semester),
                            ),
                            for (final subEvaluation in evaluation.subEvaluations)
                              StatefulBuilder(
                                builder: (context, setState) {
                                  final color = subEvaluation.isPassed ? _successColor : _failureColor;
                                  return Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          setState(() {
                                            subEvaluation.isExpanded = !subEvaluation.isExpanded;
                                          });
                                        },
                                        dense: true,
                                        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
                                        leading: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: Icon(
                                            subEvaluation.isExpanded ? Ionicons.chevron_down_outline : Ionicons.chevron_forward_outline,
                                          ),
                                        ),
                                        title: Text(subEvaluation.title),
                                        trailing: Badge(
                                          largeSize: 32,
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          backgroundColor: color.withAlpha(200),
                                          textColor: Colors.white,
                                          label: Text(subEvaluation.grade == -1 ? "Teilgenommen" : subEvaluation.grade.toString().replaceAll(".", ",")),
                                        ),
                                        subtitle: Text("${subEvaluation.typeWord} ${evaluation.isFirstTry(subEvaluation) ? '' : " (Nachprüfung)"}"),
                                      ),
                                      if (subEvaluation.isExpanded)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 15, bottom: 15, left: 25, right: 25),
                                          child: Container(
                                            padding: const EdgeInsets.only(top: 50, bottom: 10),
                                            height: 200,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Theme.of(context).colorScheme.primary.withAlpha(220),
                                                width: 1.5,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: BarChart(
                                              BarChartData(
                                                barTouchData: BarTouchData(
                                                  enabled: false,
                                                  touchTooltipData: BarTouchTooltipData(
                                                    getTooltipColor: (group) => Colors.transparent,
                                                    tooltipPadding: EdgeInsets.zero,
                                                    tooltipMargin: 8,
                                                    getTooltipItem: (
                                                      BarChartGroupData group,
                                                      int groupIndex,
                                                      BarChartRodData rod,
                                                      int rodIndex,
                                                    ) {
                                                      return BarTooltipItem(
                                                        rod.toY.round().toString(),
                                                        TextStyle(
                                                          color: subEvaluation.grade.roundBa() == groupIndex + 1 ? color : Theme.of(context).colorScheme.primary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                gridData: const FlGridData(show: false),
                                                borderData: FlBorderData(show: false),
                                                titlesData: FlTitlesData(
                                                  show: true,
                                                  bottomTitles: AxisTitles(
                                                    sideTitles: SideTitles(
                                                      showTitles: true,
                                                      reservedSize: 30,
                                                      getTitlesWidget: (double value, TitleMeta meta) {
                                                        return SideTitleWidget(
                                                          axisSide: meta.axisSide,
                                                          space: 4,
                                                          child: Text((value + 1).toInt().toString()),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  leftTitles: const AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                  topTitles: const AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                  rightTitles: const AxisTitles(
                                                    sideTitles: SideTitles(showTitles: false),
                                                  ),
                                                ),
                                                barGroups: subEvaluation.gradeDistribution
                                                    .asMap()
                                                    .entries
                                                    .map(
                                                      (e) => BarChartGroupData(
                                                        x: e.key,
                                                        barRods: [
                                                          BarChartRodData(
                                                            toY: e.value.toDouble(),
                                                            color: subEvaluation.grade.roundBa() == e.key + 1 ? color : Theme.of(context).colorScheme.primary,
                                                          ),
                                                        ],
                                                        showingTooltipIndicators: [0],
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                            ),
                          ],
                        ),
                    ]
                  : [
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: snapshot.hasError ? const Text("Ein Fehler ist aufgetreten") : const CircularProgressIndicator(),
                        ),
                      ),
                    ],
            ),
          ),
        );
      },
    );
  }
}
