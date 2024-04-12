import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:flutter/material.dart';

class EvaluationsPage extends StatefulWidget {
  const EvaluationsPage({super.key});

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> with AutomaticKeepAliveClientMixin<EvaluationsPage>{

  List<MasterEvaluation>? dataCache;

  Future<List<MasterEvaluation>> loadData() async {
    final cd = CampusDualManager();
    final evaluations = await cd.scrapeEvaluations();

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

            if(snapshot.connectionState == ConnectionState.done){
            dataCache = snapshot.data;
            }

            return SingleChildScrollView(
              physics:  ScrollPhysics(),
              child: Column(
                children: [
                  for(final evaluation in snapshot.data!)
                    ListTile(
                          title: Text(evaluation.title),
                          subtitle: Text(evaluation.grade.toString()),
                        ),
                ],
              ),
            );
          },
        ),
      );
  }
}
