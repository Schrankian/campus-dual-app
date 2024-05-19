import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:campus_dual_android/widgets/sync_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ionicons/ionicons.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> with AutomaticKeepAliveClientMixin<EvaluationsPage> {
  List<MasterEvaluation>? dataCache;

  Stream<List<MasterEvaluation>> loadData() async* {
    final storage = StorageManager();
    final storedData = await storage.loadObjectList("evaluations");
    if (storedData != null) {
      yield List<MasterEvaluation>.from(storedData.map((e) => MasterEvaluation.fromJson(e)));
    }

    final cd = CampusDualManager();
    final evaluations = await cd.scrapeEvaluations();
    storage.saveObjectList("evaluations", evaluations);
    dataCache = evaluations;
    yield evaluations;
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

        final average = snapshot.data!.where((e) => e.grade != -1).map((e) => e.grade).reduce((a, b) => a + b) / snapshot.data!.where((e) => e.grade != -1).length;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Noten'),
            actions: [
              SyncIndicator(
                state: snapshot.connectionState,
                hasData: snapshot.hasData,
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: ScrollPhysics(),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 20),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3),
                    alignment: Alignment.center,
                    height: 70,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(220),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Durchschnitt",
                          style: TextStyle(
                            fontSize: 21,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        Text(
                          average.toStringAsFixed(2).replaceAll(".", ","),
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                for (final evaluation in snapshot.data!.reversed)
                  Column(
                    children: [
                      ListTile(
                        title: Text(evaluation.title),
                        trailing: Badge(
                          largeSize: 32,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          backgroundColor: evaluation.isPassed ? Colors.green : Colors.red,
                          textColor: Colors.white,
                          label: Text(evaluation.grade == -1 ? "Teilgenommen" : evaluation.grade.toString().replaceAll(".", ",")),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(evaluation.semester),
                      ),
                      for (final subEvaluation in evaluation.subEvaluations)
                        ListTile(
                          dense: true,
                          leading: Icon(Ionicons.chevron_forward_outline),
                          title: Text(subEvaluation.title),
                          trailing: Badge(
                            largeSize: 32,
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            backgroundColor: subEvaluation.isPassed ? Colors.green.withAlpha(200) : Colors.red.withAlpha(200),
                            textColor: Colors.white,
                            label: Text(subEvaluation.grade == -1 ? "Teilgenommen" : subEvaluation.grade.toString().replaceAll(".", ",")),
                          ),
                        ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
