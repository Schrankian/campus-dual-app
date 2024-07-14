import 'dart:ui';

import 'package:campus_dual_android/scripts/campus_dual_manager.models.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:campus_dual_android/scripts/storage_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<List<EvaluationRule>> _loadRules() async {
    final storage = StorageManager();
    final storedRules = await storage.loadObjectList("evaluationRules");
    if (storedRules != null) {
      return storedRules.map((e) => EvaluationRule.fromJson(e)).toList();
    }
    return [];
  }

  Future<bool> _loadUseFuzzyColor() async {
    final storage = StorageManager();
    final isFuzzyColor = await storage.loadBool("useFuzzyColor");

    return isFuzzyColor ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Divider(
                height: 40,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Text(
                " Stundenplan",
                style: TextStyle(fontSize: 24),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Benutze zufällige Farben"),
                    FutureBuilder(
                        future: _loadUseFuzzyColor(),
                        initialData: false,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          bool useFuzzyColor = snapshot.data as bool;
                          return StatefulBuilder(builder: (context, setState) {
                            return Switch(
                              value: useFuzzyColor,
                              onChanged: (value) {
                                setState(() {
                                  useFuzzyColor = value;
                                });
                                mainBus.emit(event: "UpdateUseFuzzyColor", args: useFuzzyColor);
                              },
                            );
                          });
                        }),
                  ],
                ),
              ),
              Text(
                " Überschreibungen",
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: FutureBuilder(
                  future: _loadRules(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    List<EvaluationRule> rules = snapshot.data as List<EvaluationRule>;
                    final _newRuleTextController = TextEditingController();
                    return StatefulBuilder(builder: (context, setState) {
                      return Column(
                        children: [
                          GridView(
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                            ),
                            children: _generateRules(rules),
                          ),
                          Divider(
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
                                  decoration: InputDecoration(
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
                                    color: Theme.of(context).colorScheme.primary.withAlpha(30),
                                    border: Border.all(
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    });
                  },
                ),
              ),
              Divider(
                height: 40,
                thickness: 1,
                color: Theme.of(context).colorScheme.primary,
              ),
              const Text(
                " Account",
                style: TextStyle(fontSize: 24),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 5, right: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    mainBus.emit(event: "Logout");
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    child: Text(
                      "Abmelden",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _generateRules(List<EvaluationRule> rules) {
    List<Widget> widgets = [
      const Text(
        "Muster",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        "Farbe",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        "Verstecken",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        "Löschen",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ];
    for (final rule in rules) {
      widgets.add(
        Align(
          alignment: Alignment.centerLeft,
          child: Text(rule.pattern),
        ),
      );
      widgets.add(
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            if (rule.hide) return;

            Color pickerColor = rule.color;
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
                        setState(() => rule.color = pickerColor);
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
              color: rule.hide ? null : rule.color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.grey,
              ),
              gradient: rule.hide
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.surface,
                        Theme.of(context).colorScheme.onSurface,
                        Theme.of(context).colorScheme.surface,
                      ],
                      stops: [
                        0.49,
                        0.5,
                        0.51,
                      ],
                      transform: GradientRotation(0.5),
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
            ),
          ),
        ),
      );
      widgets.add(
        Switch(
          value: rule.hide,
          onChanged: (value) {
            setState(() {
              rule.hide = value;
              mainBus.emit(event: "UpdateRules", args: rules);
            });
          },
        ),
      );
      widgets.add(
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            setState(() {
              rules.remove(rule);
              mainBus.emit(event: "UpdateRules", args: rules);
            });
          },
          child: Icon(
            size: 35,
            Icons.delete,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
    return widgets;
  }
}
