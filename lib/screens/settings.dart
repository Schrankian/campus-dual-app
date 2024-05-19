import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(mainAxisSize: MainAxisSize.max),
              Text("Darstellung"),
              Text("Abmelden"),
              FloatingActionButton(
                onPressed: () {
                  mainBus.emit(event: "Logout");
                  Navigator.pop(context);
                },
                child: Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
