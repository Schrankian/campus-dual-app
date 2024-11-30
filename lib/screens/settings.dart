import 'dart:ui';

import 'package:campus_dual_android/screens/other/overrides.dart';
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
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 5, right: 5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Overrides()));
                  },
                  child: Container(
                    padding: const EdgeInsets.only(top: 15, bottom: 15, left: 30, right: 30),
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      "Regeln bearbeiten",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),
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
                    showDialog<void>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Abmelden"),
                            content: const Text("Möchtest du dich wirklich abmelden? Die Einstellungen bleiben erhalten, jedoch wird der Cache gelehrt."),
                            actions: [
                              TextButton(
                                child: const Text("Zurück"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text("Abmelden"),
                                onPressed: () {
                                  mainBus.emit(event: "Logout");
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pop(context); // Close settings
                                },
                              ),
                            ],
                          );
                        });
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
}
