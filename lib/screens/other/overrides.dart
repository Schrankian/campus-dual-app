import 'package:campus_dual_android/extensions/timeOfDay.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.models.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Overrides extends StatefulWidget {
  const Overrides({super.key});

  @override
  State<Overrides> createState() => _OverridesState();
}

class _OverridesState extends State<Overrides> {
  Future<List<EvaluationRule>> _loadRules() async {
    final storage = StorageManager();
    final storedRules = await storage.loadObjectList("evaluationRules");
    if (storedRules != null) {
      return storedRules.map((e) => EvaluationRule.fromJson(e)).toList();
    }
    return [];
  }

  final _newRuleTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Überschreibungen"),
        ),
        body: FutureBuilder(
          future: _loadRules(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            List<EvaluationRule> rules = snapshot.data as List<EvaluationRule>;
            return StatefulBuilder(builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Muster",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Farbe | Verstecken | Löschen",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: rules.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.only(left: 5, right: 5, top: 3, bottom: 3),
                            margin: const EdgeInsets.only(top: 4, bottom: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Text(
                                          rules[index].pattern,
                                          style: const TextStyle(
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30,
                                      width: 60,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(10),
                                        onTap: () {
                                          if (rules[index].hide) return;

                                          Color pickerColor = rules[index].color;
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text("Farbe auswählen"),
                                                content: SingleChildScrollView(
                                                  child: HueRingPicker(
                                                    enableAlpha: true,
                                                    pickerColor: pickerColor,
                                                    onColorChanged: (color) {
                                                      setState(() {
                                                        pickerColor = color;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    child: const Text('Bestätigen'),
                                                    onPressed: () {
                                                      setState(() => rules[index].color = pickerColor);
                                                      mainBus.emit(event: "UpdateRules", args: rules);
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: rules[index].hide ? null : rules[index].color,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            gradient: rules[index].hide
                                                ? LinearGradient(
                                                    colors: [
                                                      Theme.of(context).colorScheme.surface,
                                                      Theme.of(context).colorScheme.onSurface,
                                                      Theme.of(context).colorScheme.surface,
                                                    ],
                                                    stops: const [
                                                      0.49,
                                                      0.5,
                                                      0.51,
                                                    ],
                                                    transform: const GradientRotation(0.5),
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 10),
                                      child: Switch(
                                        value: rules[index].hide,
                                        onChanged: (value) {
                                          setState(() {
                                            rules[index].hide = value;
                                            mainBus.emit(event: "UpdateRules", args: rules);
                                          });
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        setState(() {
                                          rules.remove(rules[index]);
                                          mainBus.emit(event: "UpdateRules", args: rules);
                                        });
                                      },
                                      child: Icon(
                                        size: 35,
                                        Icons.delete,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Text(
                                    "Gültig von ${rules[index].startTime.format(context)} bis ${rules[index].endTime.format(context)}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.primary.withAlpha(150),
                                    ),
                                  ),
                                ),
                                RangeSlider(
                                  values: RangeValues(rules[index].startTime.toDouble(), rules[index].endTime.toDouble()),
                                  min: 0,
                                  max: 24,
                                  divisions: 96,
                                  onChanged: (values) {
                                    setState(() {
                                      rules[index].startTime = ExtTimeOfDay.fromDouble(values.start);
                                      rules[index].endTime = ExtTimeOfDay.fromDouble(values.end);
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    mainBus.emit(event: "UpdateRules", args: rules);
                                  },
                                  labels: RangeLabels(
                                    rules[index].startTime.format(context),
                                    rules[index].endTime.format(context),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Column(
                      children: [
                        const Divider(
                          height: 40,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 200,
                              child: TextField(
                                controller: _newRuleTextController,
                                decoration: const InputDecoration(
                                  labelText: "Neues Muster",
                                ),
                              ),
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(15),
                              onTap: () {
                                setState(() {
                                  rules.add(EvaluationRule(pattern: _newRuleTextController.text, color: Theme.of(context).colorScheme.primary, hide: false));
                                  _newRuleTextController.clear();
                                });
                                mainBus.emit(event: "UpdateRules", args: rules);
                              },
                              child: Container(
                                width: 100,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Theme.of(context).colorScheme.primary.withAlpha(50),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
          },
        ));
  }
}
