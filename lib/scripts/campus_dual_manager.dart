import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/dom.dart';
import '../extensions/color.dart';
import 'package:http/http.dart' as http;
import 'package:http_cookie_store/http_cookie_store.dart';
import 'package:html/parser.dart';

String addQueryParams(String uri, Map<String, String> params) {
  // Check if the uri already has a query
  if (uri.contains("?")) {
    return "$uri&${params.entries.map((e) => "${e.key}=${e.value}").join("&")}";
  } else {
    return "$uri?${params.entries.map((e) => "${e.key}=${e.value}").join("&")}";
  }
}

class UserCredentials {
  final String username;
  final String password;
  final String hash;

  UserCredentials(this.username, this.password, this.hash);

  String addAuthParams(String uri) {
    return addQueryParams(uri, {"user": username, "userid": username, "hash": hash});
  }
}

class GeneralUserData {
  final String firstName;
  final String lastName;
  final String group;
  final String course;

  const GeneralUserData({
    required this.firstName,
    required this.lastName,
    required this.group,
    required this.course,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'group': group,
      'course': course,
    };
  }

  factory GeneralUserData.fromJson(Map<String, dynamic> json) {
    return GeneralUserData(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      group: json['group'] as String,
      course: json['course'] as String,
    );
  }
}

class Evaluation {
  final String module;
  final String title;
  final String type;
  final double grade;
  final bool isPassed;
  final DateTime dateGraded;
  final DateTime dateAnnounced;
  final bool isPartlyGraded;
  final String semester;

  const Evaluation({
    required this.module,
    required this.title,
    required this.type,
    required this.grade,
    required this.isPassed,
    required this.dateGraded,
    required this.dateAnnounced,
    required this.isPartlyGraded,
    required this.semester,
  });

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'title': title,
      'type': type,
      'grade': grade,
      'isPassed': isPassed,
      'dateGraded': dateGraded.toIso8601String(),
      'dateAnnounced': dateAnnounced.toIso8601String(),
      'isPartlyGraded': isPartlyGraded,
      'semester': semester,
    };
  }

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      module: json['module'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      grade: json['grade'] as double,
      isPassed: json['isPassed'] as bool,
      dateGraded: DateTime.parse(json['dateGraded'] as String),
      dateAnnounced: DateTime.parse(json['dateAnnounced'] as String),
      isPartlyGraded: json['isPartlyGraded'] as bool,
      semester: json['semester'] as String,
    );
  }
}

class MasterEvaluation {
  final String module;
  final String title;
  final double grade;
  final bool isPassed;
  final bool isPartlyGraded;
  final String semester;
  final int credits;
  final List<Evaluation> subEvaluations;

  const MasterEvaluation({
    required this.module,
    required this.title,
    required this.grade,
    required this.isPassed,
    required this.isPartlyGraded,
    required this.semester,
    required this.credits,
    required this.subEvaluations,
  });

  Map<String, dynamic> toJson() {
    return {
      'module': module,
      'title': title,
      'grade': grade,
      'isPassed': isPassed,
      'isPartlyGraded': isPartlyGraded,
      'semester': semester,
      'credits': credits,
      'subEvaluations': subEvaluations.map((e) => e.toJson()).toList(),
    };
  }

  factory MasterEvaluation.fromJson(Map<String, dynamic> json) {
    return MasterEvaluation(
      module: json['module'] as String,
      title: json['title'] as String,
      grade: json['grade'] as double,
      isPassed: json['isPassed'] as bool,
      isPartlyGraded: json['isPartlyGraded'] as bool,
      semester: json['semester'] as String,
      credits: json['credits'] as int,
      subEvaluations: (json['subEvaluations'] as List<dynamic>).map((e) => Evaluation.fromJson(e as Map<String, dynamic>)).toList(),
    );
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

  factory ExamStats.fromData(Map<String, dynamic> json) {
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

  Map<String, dynamic> toJson() {
    return {
      'exams': exams,
      'success': success,
      'failure': failure,
      'wpCount': wpCount,
      'modules': modules,
      'booked': booked,
      'mBooked': mBooked,
    };
  }

  factory ExamStats.fromJson(Map<String, dynamic> json) {
    return ExamStats(
      exams: json['exams'] as int,
      success: json['success'] as int,
      failure: json['failure'] as int,
      wpCount: json['wpCount'] as int,
      modules: json['modules'] as int,
      booked: json['booked'] as int,
      mBooked: json['mBooked'] as int,
    );
  }
}

class Lesson {
  final String title;
  final DateTime start;
  final DateTime end;
  final bool allDay;
  final String description;
  final Color color;
  final bool editable;
  final String room;
  final String sRoom;
  final String instructor;
  final String sInstructor;
  final String remarks;
  final String type = "Vorlesung";

  const Lesson({
    required this.title,
    required this.start,
    required this.end,
    required this.allDay,
    required this.description,
    required this.color,
    required this.editable,
    required this.room,
    required this.sRoom,
    required this.instructor,
    required this.sInstructor,
    required this.remarks,
  });

  factory Lesson.fromData(Map<String, dynamic> json) {
    return switch (json) {
      {
        'title': String title,
        'start': int start,
        'end': int end,
        'allDay': bool allDay,
        'description': String description,
        'color': String color,
        'editable': bool editable,
        'room': String room,
        'sroom': String sRoom,
        'instructor': String instructor,
        'sinstructor': String sInstructor,
        'remarks': String remarks,
      } =>
        Lesson(
          title: title,
          start: DateTime.fromMillisecondsSinceEpoch(start * 1000),
          end: DateTime.fromMillisecondsSinceEpoch(end * 1000),
          allDay: allDay,
          description: description,
          color: HexColor.fromHex(color),
          editable: editable,
          room: room,
          sRoom: sRoom,
          instructor: instructor,
          sInstructor: sInstructor,
          remarks: remarks,
        ),
      _ => throw const FormatException('Unexpected JSON type for Lesson'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'allDay': allDay,
      'description': description,
      'color': color.toHex(),
      'editable': editable,
      'room': room,
      'sRoom': sRoom,
      'instructor': instructor,
      'sInstructor': sInstructor,
      'remarks': remarks,
    };
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      allDay: json['allDay'] as bool,
      description: json['description'] as String,
      color: HexColor.fromHex(json['color'] as String),
      editable: json['editable'] as bool,
      room: json['room'] as String,
      sRoom: json['sRoom'] as String,
      instructor: json['instructor'] as String,
      sInstructor: json['sInstructor'] as String,
      remarks: json['remarks'] as String,
    );
  }
}

class UpcomingExam {
  final DateTime begin;
  final DateTime end;
  final DateTime date;
  final String comment;
  final String instructor;
  final String moduleShort;
  final String moduleTitle;
  final String type;
  final String room;

  const UpcomingExam({
    required this.begin,
    required this.end,
    required this.date,
    required this.comment,
    required this.instructor,
    required this.moduleShort,
    required this.moduleTitle,
    required this.type,
    required this.room,
  });

  factory UpcomingExam.fromData(Map<String, dynamic> json) {
    return switch (json) {
      {
        'BEGUZ': String begin,
        'ENDUZ': String end,
        'EVDAT': String date,
        'COMMENT': String comment,
        'INSTRUCTOR': String instructor,
        'SM_SHORT': String moduleShort,
        'SM_STEXT': String moduleTitle,
        'SROOM': String room,
      } =>
        UpcomingExam(
          begin: DateTime.parse('$date $begin'),
          end: DateTime.parse('$date $end'),
          date: DateTime.parse(date),
          comment: comment,
          instructor: instructor,
          moduleShort: moduleShort,
          moduleTitle: moduleTitle.endsWith(")") ? moduleTitle.split(" ").sublist(0, moduleTitle.split(" ").length - 1).join(" ") : moduleTitle,
          type: moduleTitle.endsWith(")") ? moduleTitle.split(" ").last : "(?)",
          room: room,
        ),
      _ => throw const FormatException('Unexpected JSON type for UpcomingExam'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'begin': begin.toIso8601String(),
      'end': end.toIso8601String(),
      'date': date.toIso8601String(),
      'comment': comment,
      'instructor': instructor,
      'moduleShort': moduleShort,
      'moduleTitle': moduleTitle,
      'type': type,
      'room': room,
    };
  }

  factory UpcomingExam.fromJson(Map<String, dynamic> json) {
    return UpcomingExam(
      begin: DateTime.parse(json['begin'] as String),
      end: DateTime.parse(json['end'] as String),
      date: DateTime.parse(json['date'] as String),
      comment: json['comment'] as String,
      instructor: json['instructor'] as String,
      moduleShort: json['moduleShort'] as String,
      moduleTitle: json['moduleTitle'] as String,
      type: json['type'] as String,
      room: json['room'] as String,
    );
  }
}

class LatestExam {}

class Notifications {
  final int electives;
  final int exams;
  final int semester;
  final List<UpcomingExam> upcoming;
  final List<LatestExam> latest;

  const Notifications({
    required this.electives,
    required this.exams,
    required this.semester,
    required this.upcoming,
    required this.latest,
  });

  factory Notifications.fromData(Map<String, dynamic> json) {
    return switch (json) {
      {
        'ELECTIVES': int electives,
        'EXAMS': int exams,
        'SEMESTER': int semester,
        'UPCOMING': List<dynamic> upcoming,
        'LATEST': List<dynamic> latest,
      } =>
        Notifications(
          electives: electives,
          exams: exams,
          semester: semester,
          upcoming: upcoming.map((e) => UpcomingExam.fromData(e as Map<String, dynamic>)).toList(),
          latest: List.empty(),
        ),
      _ => throw const FormatException('Unexpected JSON type for Notifications'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'electives': electives,
      'exams': exams,
      'semester': semester,
      'upcoming': upcoming.map((e) => e.toJson()).toList(),
      'latest': List.empty(),
    };
  }

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
      electives: json['electives'] as int,
      exams: json['exams'] as int,
      semester: json['semester'] as int,
      upcoming: (json['upcoming'] as List<dynamic>).map((e) => UpcomingExam.fromJson(e as Map<String, dynamic>)).toList(),
      latest: List.empty(),
    );
  }
}

class CampusDualManager {
  static UserCredentials? userCreds;

  static const Map<String, String> stdHeaders = {
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7",
    "Accept-Language": "de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7",
    "Cache-Control": "max-age=0",
    "Connection": "keep-alive",
    "origin": "https://erp.campus-dual.de",
    "Referer": "https://erp.campus-dual.de/sap/bc/webdynpro/sap/zba_initss?sap-client=100&sap-language=de&uri=https%3a%2f%2fselfservice.campus-dual.de%2findex%2flogin",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "same-site",
    "Sec-Fetch-User": "?1",
    "Upgrade-Insecure-Requests": "1",
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
    "sec-ch-ua": '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
    "sec-ch-ua-mobile": "?0",
    "sec-ch-ua-platform": "Windows"
  };

  CampusDualManager();

  Future<http.Response> _fetch(String uri) async {
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("Failed to fetch from: $uri");
    }
  }

  Future<Document> _scrape(CookieClient session, String uri) async {
    final response = await session.get(Uri.parse(uri), headers: stdHeaders);

    if (response.statusCode != 200) {
      throw Exception("Failed to scrape from: $uri");
    }

    return parse(response.body);
  }

  /*
  * This function initializes gets the session cookie and therefore logs in the user
  */
  Future<CookieClient> _initAuthSession({String? username, String? password}) async {
    final Uri loginUri = Uri.parse("https://erp.campus-dual.de/sap/bc/webdynpro/sap/zba_initss?sap-client=100&sap-language=de&uri=https%3a%2f%2fselfservice.campus-dual.de%2findex%2flogin");

    CookieClient session = CookieClient();

    // Initial request to get the XSRF token and the xsrf cookie
    final initResponse = await session.get(loginUri, headers: stdHeaders);
    if (initResponse.statusCode != 200) {
      throw Exception("Failed to fetch from: $loginUri");
    }

    // Parse the response and get the XSRF token
    final doc = parse(initResponse.body);
    // Get the XSRF token. Hint: The token hides in an hidden input field
    final xsrfToken = doc.querySelector("input[name='sap-login-XSRF']")?.attributes["value"];

    // Request to login and get the session cookie
    final loginResponse = await session.post(
      loginUri,
      headers: stdHeaders,
      body: {
        "FOCUS_ID": "sap-user",
        "sap-system-login-oninputprocessing": "onLogin",
        "sap-urlscheme": "",
        "sap-system-login": "onLogin",
        "sap-system-login-basic_auth": "",
        "sap-client": "100",
        "sap-language": "DE",
        "sap-accessibility": "",
        "sap-login-XSRF": xsrfToken,
        "sap-system-login-cookie_disabled": "",
        "sap-user": username ?? userCreds!.username,
        "sap-password": password ?? userCreds!.password,
        "SAPEVENTQUEUE": "Form_Submit~E002Id~E004SL__FORM~E003~E002ClientAction~E004submit~E005ActionUrl~E004~E005ResponseData~E004full~E005PrepareScript~E004~E003~E002~E003"
      },
    );

    if (loginResponse.statusCode != 302 || loginResponse.body.contains("loginForm")) {
      throw Exception("Failed to login");
    }

    return session;
  }

  Future<ExamStats> fetchExamStats() async {
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getexamstats"));

    return ExamStats.fromData(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<int> fetchCurrentSemester() async {
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getfs"));

    return int.parse(response.body.replaceAll(" ", "").replaceAll("\"", ""));
  }

  Future<int> fetchCreditPoints() async {
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getcp"));

    return int.parse(response.body);
  }

  Future<Map<DateTime, List<Lesson>>> fetchTimeTable(DateTime start, DateTime end) async {
    final response = await _fetch(addQueryParams(userCreds!.addAuthParams("https://selfservice.campus-dual.de/room/json"), {
      "start": (start.millisecondsSinceEpoch / 1000).toString(),
      "end": (end.millisecondsSinceEpoch / 1000).toString(),
    }));

    final List<dynamic> json = jsonDecode(response.body) as List<dynamic>;

    // // Filter out every item in json, which is not in the timeframe start to end
    // json.removeWhere((element) {
    //   final DateTime elStart = DateTime.fromMillisecondsSinceEpoch((element["start"] as int) * 1000);
    //   final DateTime elEnd = DateTime.fromMillisecondsSinceEpoch((element["end"] as int) * 1000);

    //   return elStart.isBefore(start) || elEnd.isAfter(end);
    // });

    final Map<DateTime, List<Lesson>> lessons = {};
    for (final element in json) {
      final lesson = Lesson.fromData(element as Map<String, dynamic>);
      final date = DateTime(lesson.start.year, lesson.start.month, lesson.start.day);

      if (lessons.containsKey(date)) {
        lessons[date]!.add(lesson);
      } else {
        lessons[date] = [lesson];
      }
    }

    return lessons;
  }

  Future<Notifications> fetchNotifications() async {
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getreminders"));

    return Notifications.fromData(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<GeneralUserData> scrapeGeneralUserData() async {
    final session = await _initAuthSession();
    final doc = await _scrape(session, "https://selfservice.campus-dual.de/index/login");

    final studInfo = doc.querySelector("#studinfo")!.querySelector("td")!;

    // Iterate over the children of the studinfo table cell
    // Form:
    // <td width="85%">
    //  <strong>Name: </strong>Schuster, Fabian (3004717),
    //  <strong> Seminargruppe: </strong> 3IT22-1
    //  <br>Studiengang Informationstechnologie/SR Informationstechnik
    // </td>
    String? group;
    String? course;
    String? firstName;
    String? lastName;
    for (int i = 0; i < studInfo.nodes.length; i++) {
      final child = studInfo.nodes[i].text!.trim();

      if (child.contains("Studiengang")) {
        course = child.replaceAll("Studiengang ", "");
        continue;
      }
      switch (child) {
        case "Name:":
          {
            final nameList = studInfo.nodes[i + 1].text!.trim().split(" ");
            lastName = nameList[0].trim().replaceAll(",", "");
            firstName = nameList[1].trim();
            break;
          }
        case "Seminargruppe:":
          {
            group = studInfo.nodes[i + 1].text!.trim();
            break;
          }
      }
    }

    return GeneralUserData(
      firstName: firstName ?? "",
      lastName: lastName ?? "",
      group: group ?? "",
      course: course ?? "",
    );
  }

  Future<String> scrapeHash({String? username, String? password}) async {
    if ((username == null || password == null) && userCreds == null) {
      throw Exception("No user credentials provided");
    }

    final session = await _initAuthSession(username: username, password: password);
    final doc = await _scrape(session, "https://selfservice.campus-dual.de/index/login");

    final scriptTag = doc.querySelector("#main")?.querySelector("script")!.innerHtml;

    final hashRegExp = RegExp(r'hash="([^"]*)"');
    final match = hashRegExp.firstMatch(scriptTag!);

    if (match != null && match.groupCount > 0) {
      final hash = match.group(1)!;
      return hash;
    } else {
      throw Exception("Failed to scrape hash");
    }
  }

  Future<List<MasterEvaluation>> scrapeEvaluations() async {
    final session = await _initAuthSession();
    final doc = await _scrape(session, "https://selfservice.campus-dual.de/acwork/index");

    final table = doc.querySelector("#acwork")!.querySelector("tbody")!;

    final evaluations = <MasterEvaluation>[];

    for (final element in table.children) {
      if (element.className.contains("child-of-node-0")) {
        final moduleTitleString = element.children[0].querySelector("strong")!.text.trim().split(" ");
        final module = moduleTitleString[moduleTitleString.length - 1].replaceAll(r'\(|\)', "");
        final title = moduleTitleString.sublist(0, moduleTitleString.length - 1).join(" ");

        final grade = double.tryParse(element.children[1].querySelector("#none")!.text.trim().replaceAll(",", ".")) ?? -1;
        final isPassed = element.children[2].querySelector("img")!.attributes["src"]! == "/images/green.png";
        final credits = int.parse(element.children[3].text.trim());
        final isPartlyGraded = false; //TODO: Implement
        final semester = element.children.last.text.trim();
        evaluations.add(MasterEvaluation(module: module, title: title, grade: grade, isPassed: isPassed, isPartlyGraded: isPartlyGraded, semester: semester, credits: credits, subEvaluations: <Evaluation>[]));
      } else if (!element.className.contains("head")) {
        final moduleTitleTypeString = element.children[0].text.trim().split(" ");
        final module = moduleTitleTypeString[moduleTitleTypeString.length - 1].replaceAll(r'\(|\)', "");
        final title = moduleTitleTypeString.sublist(0, moduleTitleTypeString.length - 2).join(" ");
        final type = moduleTitleTypeString[moduleTitleTypeString.length - 2].replaceAll(r'\(|\)', "");

        final grade = double.tryParse(element.children[1].querySelector(".mscore")!.text.trim().replaceAll(",", ".")) ?? -1;
        final isPassed = element.children[2].querySelector("img")!.attributes["src"]! == "/images/green.png";

        final splitDateGraded = element.children[4].text.split(".");
        final dateGraded = DateTime.parse(splitDateGraded[2] + splitDateGraded[1] + splitDateGraded[0]);

        final splitDateAnnounced = element.children[5].text.split(".");
        final dateAnnounced = DateTime.parse(splitDateAnnounced[2] + splitDateAnnounced[1] + splitDateAnnounced[0]);

        final isPartlyGraded = false; // TODO: implement
        final semester = element.children.last.text.trim();

        evaluations.last.subEvaluations.add(Evaluation(module: module, title: title, type: type, grade: grade, isPassed: isPassed, dateGraded: dateGraded, dateAnnounced: dateAnnounced, isPartlyGraded: isPartlyGraded, semester: semester));
      }
    }

    return evaluations;
  }
}
