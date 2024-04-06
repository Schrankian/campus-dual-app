import 'package:http/http.dart' as http;

class UserCredentials {
  String username;
  String hash;

  UserCredentials(this.username, this.hash);

  String getAuthUri(String uri) {
    return "$uri?username=$username&hash=$hash";
  }
}

class ExamStats {
  final int exams;
  final int success;
  final int failure;
  final int wpCount;
  final int modules;
  final int booked;
  final int mBooked;

  const ExamStats({
    required this.exams,
    required this.success,
    required this.failure,
    required this.wpCount,
    required this.modules,
    required this.booked,
    required this.mBooked,
  });

  factory ExamStats.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'EXAMS': int exams,
        'SUCCESS': int success,
        'FAILURE': int failure,
        'WPCOUNT': int wpCount,
        'MODULES': int modules,
        'BOOKED': int booked,
        'MBOOKED': int mBooked,
      } =>
        ExamStats(exams: exams, success: success, failure: failure, wpCount: wpCount, modules: modules, booked: booked, mBooked: mBooked),
      _ => throw const FormatException('Unexpected JSON type for ExamStats'),
    };
  }
}

class CampusDualManager {
  UserCredentials userCreds;

  CampusDualManager(this.userCreds);

  Future<http.Response> _fetch(String uri) async {
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("Failed to fetch from: $uri");
    }
  }

  Future<ExamStats> fetchExamStats() async {
    final response = await _fetch(userCreds.getAuthUri("https://selfservice.campus-dual.de/dash/getexamstats"));

    return ExamStats.fromJson(response.body as Map<String, dynamic>);
  }
}
