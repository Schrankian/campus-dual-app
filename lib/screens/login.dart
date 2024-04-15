import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<UserCredentials?> _testCredentials(String username, String password) async {
    final cd = CampusDualManager();
    final String hash;
    try {
      hash = await cd.scrapeHash(username: username, password: password);
    } catch (e) {
      print(e);
      return null;
    }
    return UserCredentials(username, password, hash);
  }

  bool buttonEnabled = true;

  bool _validateInput(String username, String password) {
    if (!buttonEnabled) {
      return false;
    }
    if (username.isNotEmpty && password.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SizedBox.expand(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                "Campus Dual",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.background,
                ),
              ),
              Container(
                width: 350,
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      keyboardType: TextInputType.numberWithOptions(decimal: false, signed: true),
                      textInputAction: TextInputAction.next,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        prefixIcon: Icon(Ionicons.person_outline),
                        labelText: "Matrikelnummer",
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        prefixIcon: Icon(Ionicons.key_outline),
                        labelText: "Passwort",
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        if (!_validateInput(_usernameController.text, _passwordController.text)) return;
                        print("Button actions started");
                        buttonEnabled = false;
                        final userCreds = await _testCredentials(_usernameController.text, _passwordController.text);
                        buttonEnabled = true;
                        if (userCreds != null) {
                          mainBus.emit(event: "Login", args: userCreds);
                        }
                        //TODO show error message
                      },
                      child: const Padding(
                        padding: EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                        child: Text(
                          "Login",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
