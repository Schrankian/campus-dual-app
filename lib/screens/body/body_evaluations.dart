import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> with AutomaticKeepAliveClientMixin<EvaluationsPage> {
  List<MasterEvaluation>? dataCache;

  Future<List<MasterEvaluation>> loadData() async {
    final cd = CampusDualManager();
    final evaluations = await cd.scrapeEvaluations();

    dataCache = evaluations;
    return evaluations;
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noten'),
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
            physics: ScrollPhysics(),
            child: Column(
              children: [
                for (final evaluation in snapshot.data!.reversed)
                  Column(
                    children: [
                      ListTile(
                        title: Text(evaluation.title),
                        trailing: Badge(
                          largeSize: 32,
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          backgroundColor: evaluation.isPassed ? Colors.green : Colors.red,
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
          );
        },
      ),
    );
  }
}
