import 'package:campus_dual_android/scripts/campus_dual_manager.dart';
import 'package:campus_dual_android/scripts/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

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

  Future<UserCredentials?> _testCredentials(String username, String password) async {
    if (username == "1111" && password == "1111") {
      return UserCredentials(username, password, "hashy", true);
    }
    final cd = CampusDualManager(allowNoCreds: true);
    final String hash;
    try {
      hash = await cd.scrapeHash(username: username, password: password);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return UserCredentials(username, password, hash, false);
  }

  bool isLoading = true;
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

    if (!isLoading) {
      return ValidationState.loading;
    }
    if (username.isNotEmpty && password.isNotEmpty) {
      return ValidationState.valid;
    }
    return ValidationState.empty;
  }

  @override
  Widget build(BuildContext context) {
    ValidationState state = _validateInput(_usernameController.text, _passwordController.text);
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
                  color: Theme.of(context).colorScheme.surface,
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
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: state == ValidationState.valid
                          ? () async {
                              setState(() {
                                isLoading = false;
                              });

                              FocusManager.instance.primaryFocus?.unfocus();
                              final stopwatch = Stopwatch()..start();
                              final userCreds = await _testCredentials(_usernameController.text, _passwordController.text);
                              final elapsed = stopwatch.elapsed;

                              // Make sure the loading spinner is shown for at least 2 second
                              if (elapsed < const Duration(seconds: 2)) {
                                await Future.delayed(const Duration(seconds: 2) - elapsed);
                              }

                              setState(() {
                                isLoading = true;
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
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40, top: 15, bottom: 15),
                        child: state == ValidationState.loading
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
