import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

enum ValidationState {
  valid,
  empty,
  loading,
  wrong,
  lastWrong,
  error,
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _forceMode = false;

  Future<UserCredentials?> _testCredentials(String username, String password) async {
    if (username == "11111" && password == "11111") {
      return UserCredentials(username, password, "hashy", true);
    }
    final cd = CampusDualManager(allowNoCreds: true);
    final String hash;
    try {
      hash = await cd.scrapeHash(username: username, password: password);
    } catch (e) {
      debugPrint(e.toString());
      if (!e.toString().contains("Failed to login")) {
        // We take "Failed to login" as the default error for wrong credentials
        // Anything else is considered a connection error and enables the force mode
        setState(() {
          _forceMode = true;
        });
      }
      return null;
    }
    return UserCredentials(username, password, hash, false);
  }

  bool isLoading = false;
  bool passwordVisible = false;
  List<Map<String, String>> lastErrors = [];

  ValidationState _validateInput(String username, String password) {
    for (final entry in lastErrors) {
      if (entry["username"] == username && entry["password"] == password) {
        // check, if the current entry is the newest in the list
        if (lastErrors.indexOf(entry) == lastErrors.length - 1) {
          return ValidationState.wrong;
        }
        return ValidationState.lastWrong;
      }
    }

    if (isLoading) {
      return ValidationState.loading;
    }
    if (username.isNotEmpty && password.isNotEmpty) {
      return ValidationState.valid;
    }
    return ValidationState.empty;
  }

  void _login(bool force) async {
    setState(() {
      isLoading = true;
    });

    FocusManager.instance.primaryFocus?.unfocus();
    final stopwatch = Stopwatch()..start();
    if (force) {
      CampusDualManager.insecureMode = true;
    }
    final userCreds = await _testCredentials(_usernameController.text, _passwordController.text);
    final elapsed = stopwatch.elapsed;

    // Make sure the loading spinner is shown for at least 1 second
    if (elapsed < const Duration(seconds: 1)) {
      await Future.delayed(const Duration(seconds: 1) - elapsed);
    }

    setState(() {
      isLoading = false;
    });

    if (userCreds != null) {
      mainBus.emit(event: "Login", args: userCreds);
      return;
    }

    setState(() {
      lastErrors.add({
        "username": _usernameController.text,
        "password": _passwordController.text,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ValidationState state = _validateInput(_usernameController.text, _passwordController.text);
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.inverseSurface : Theme.of(context).colorScheme.primary,
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
                  color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).colorScheme.onInverseSurface : Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Container(
                width: 350,
                height: 400,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                      onChanged: (value) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: true),
                      textInputAction: TextInputAction.next,
                      controller: _usernameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        prefixIcon: const Icon(Ionicons.person_outline),
                        labelText: "Matrikelnummer",
                        errorText: state == ValidationState.wrong
                            ? "Falsche Anmeldeinformationen"
                            : state == ValidationState.lastWrong
                                ? "Bereits falsch eingegeben"
                                : null,
                      ),
                    ),
                    TextField(
                      onChanged: (value) => setState(() {}),
                      obscureText: !passwordVisible,
                      textInputAction: TextInputAction.done,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        filled: true,
                        prefixIcon: const Icon(Ionicons.key_outline),
                        labelText: "Passwort",
                        errorText: state == ValidationState.wrong
                            ? "Falsche Anmeldeinformationen"
                            : state == ValidationState.lastWrong
                                ? "Bereits falsch eingegeben"
                                : null,
                        suffixIcon: IconButton(
                          icon: Icon(passwordVisible ? Ionicons.eye_off_outline : Ionicons.eye_outline),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    _forceMode && (state == ValidationState.wrong || state == ValidationState.lastWrong)
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : () => {
                                      showDialog<void>(
                                        context: context,
                                        barrierDismissible: false, // user must tap button!
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Login erzwingen'),
                                            content: const SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text('Möchtest du den Login wirklich erzwingen?'),
                                                  SizedBox(height: 10),
                                                  Text('Damit wird das SSL-Zertifikat des Campus Dual Servers nicht mehr überprüft. Dies kann ein Sicherheitsrisiko darstellen.'),
                                                  SizedBox(height: 10),
                                                  Text('Beachte außerdem, dass die wiederholte Eingabe falscher Anmeldeinformationen zu einer Sperrung deines Accounts führen kann.'),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Abbrechen'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Bestätigen'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _login(true);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
                                      "Login erzwingen",
                                      style: TextStyle(fontSize: 20),
                                    ),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: state == ValidationState.valid ? () => _login(false) : null,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                              child: isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text(
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
