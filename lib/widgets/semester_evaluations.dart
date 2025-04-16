import 'package:campus_dual_android/scripts/campus_dual_manager.models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SemesterEvaluations extends StatefulWidget {
  const SemesterEvaluations({super.key, this.items});

  final List<MasterEvaluation>? items;

  @override
  State<SemesterEvaluations> createState() => _SemesterEvaluationsState();
}

class _SemesterEvaluationsState extends State<SemesterEvaluations> {
  final Map<String, List<Evaluation>> _groupedItems = {};

  double calculateAverage(List<Evaluation> evaluations) {
    final validEvaluations = evaluations.where((evaluation) => evaluation.grade != -1);
    final sum = validEvaluations.fold(0.0, (total, evaluation) => total + evaluation.grade);
    return sum / validEvaluations.length;
  }

  @override
  void initState() {
    for (final MasterEvaluation master in widget.items ?? []) {
      for (final Evaluation item in master.subEvaluations) {
        if (master.hasNewerSubEval(item)) {
          continue;
        }
        if (!_groupedItems.containsKey(item.semester)) {
          _groupedItems[item.semester] = [];
        }
        _groupedItems[item.semester]!.add(item);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Semester"),
      ),
      body: SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            children: [
              for (final semester in _groupedItems.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 25),
                  child: Column(
                    children: [
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              border: Border.fromBorderSide(BorderSide(color: Theme.of(context).colorScheme.primary)),
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                            ),
                            child: Text(
                              calculateAverage(semester.value).toStringAsFixed(2).replaceAll(".", ","),
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                          Text(
                            "${(_groupedItems.keys.toList().reversed.toList().indexOf(semester.key) + 1).toString()} > ${semester.key}",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      for (final evaluation in semester.value)
                        ListTile(
                          title: Text(evaluation.title),
                          subtitle: Text(evaluation.typeWord),
                          leading: Text(
                            evaluation.grade == -1 ? " T" : evaluation.grade.toString().replaceAll(".", ","),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
