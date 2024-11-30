import 'package:campus_dual_android/extensions/date.dart';
import 'package:campus_dual_android/extensions/timeOfDay.dart';

import '../extensions/color.dart';
import 'package:flutter/material.dart';

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
  final bool isDummy;

  UserCredentials(this.username, this.password, this.hash, this.isDummy);

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

  static GeneralUserData dummy() {
    return const GeneralUserData(
      firstName: "Max",
      lastName: "Mustermann",
      group: "2IT20-2",
      course: "Informationstechnologie/SR Informationstechnik",
    );
  }
}

class Evaluation {
  final int pIndex;
  final String module;
  final String title;
  final String type;
  final double grade;
  final List<String> gradeDistributionArguments;
  final bool isPassed;
  final DateTime dateGraded;
  final DateTime dateAnnounced;
  final bool isPartlyGraded;
  final String semester;

  String get uniqueId {
    // create a hash out of pIndex, title, type, semeseter, module
    return "$pIndex$title$type$semester$module".hashCode.toRadixString(16);
  }

  String get typeWord {
    return switch (type) {
      "K" => "Klausur",
      "PR" => "Präsentation",
      "MF" => "Mündliches Fachgespräch",
      "MP" => "Mündliche Prüfung",
      "PA" => "Projektarbeit",
      "PE" => "Programmentwurf",
      "" => "Unbekannt",
      _ => type,
    };
  }

  Evaluation({
    required this.pIndex,
    required this.module,
    required this.title,
    required this.type,
    required this.grade,
    required this.gradeDistributionArguments,
    required this.isPassed,
    required this.dateGraded,
    required this.dateAnnounced,
    required this.isPartlyGraded,
    required this.semester,
  });

  Map<String, dynamic> toJson() {
    return {
      'pIndex': pIndex,
      'module': module,
      'title': title,
      'type': type,
      'grade': grade,
      'gradeDistributionArguments': gradeDistributionArguments,
      'isPassed': isPassed,
      'dateGraded': dateGraded.toIso8601String(),
      'dateAnnounced': dateAnnounced.toIso8601String(),
      'isPartlyGraded': isPartlyGraded,
      'semester': semester,
    };
  }

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      pIndex: json['pIndex'] as int,
      module: json['module'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      grade: json['grade'] as double,
      gradeDistributionArguments: json['gradeDistributionArguments'].cast<String>(),
      isPassed: json['isPassed'] as bool,
      dateGraded: DateTime.parse(json['dateGraded'] as String),
      dateAnnounced: DateTime.parse(json['dateAnnounced'] as String),
      isPartlyGraded: json['isPartlyGraded'] as bool,
      semester: json['semester'] as String,
    );
  }

  static Evaluation dummy() {
    return Evaluation(
      pIndex: 0,
      module: "AWP",
      title: "Algorithmen und Datenstrukturen",
      type: "K",
      grade: 1.3,
      gradeDistributionArguments: ["", "", ""],
      isPassed: true,
      dateGraded: DateTime.now(),
      dateAnnounced: DateTime.now(),
      isPartlyGraded: false,
      semester: "WS 2021/22",
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

  static MasterEvaluation dummy() {
    return MasterEvaluation(
      module: "AWP",
      title: "Algorithmen und Datenstrukturen",
      grade: 1.3,
      isPassed: true,
      isPartlyGraded: false,
      semester: "WS 2021/22",
      credits: 5,
      subEvaluations: [Evaluation.dummy(), Evaluation.dummy()],
    );
  }

  int getRepNumber(Evaluation evaluation) {
    final List<Evaluation> sameEvals = [];

    for (final subEval in subEvaluations) {
      if (subEval.pIndex == evaluation.pIndex) {
        sameEvals.add(subEval);
      }
    }

    sameEvals.sort((a, b) => a.dateGraded.compareTo(b.dateGraded));

    return sameEvals.indexOf(evaluation);
  }

  bool hasNewerSubEval(Evaluation evaluation) {
    for (final subEval in subEvaluations) {
      if (subEval != evaluation && subEval.pIndex == evaluation.pIndex && subEval.dateGraded.isAfter(evaluation.dateGraded)) {
        return true;
      }
    }
    return false;
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

  static ExamStats dummy() {
    return const ExamStats(
      exams: 10,
      success: 8,
      failure: 2,
      wpCount: 1,
      modules: 5,
      booked: 3,
      mBooked: 1,
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
          start: DateTime.fromMillisecondsSinceEpoch(start * 1000).toCet(),
          end: DateTime.fromMillisecondsSinceEpoch(end * 1000).toCet(),
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
          moduleTitle: moduleTitle.replaceAll(RegExp(r'\([^()]*\)(?!.*\([^()]*\))'), "").trim(), // Delete the last bracket of the title, which contains the type
          type: moduleTitle.endsWith(")") ? "(${moduleTitle.split("(").last}" : "(?)",
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

  static UpcomingExam dummy() {
    return UpcomingExam(
      begin: DateTime(2022, 1, 1, 8, 0),
      end: DateTime(2022, 1, 1, 10, 0),
      date: DateTime(2022, 1, 1),
      comment: "Keine Kommentare",
      instructor: "Max Mustermann",
      moduleShort: "AWP",
      moduleTitle: "Algorithmen und Datenstrukturen",
      type: "Klausur",
      room: "A123",
    );
  }
}

class LatestExam {
  final String moduleShort;
  final String moduleTitle;
  final String moduleType;
  final double grade;
  final String semester;
  final DateTime dateGraded;
  final DateTime dateBooked;
  final String examType; // TODO: maybe just bool but isPartGraded
  final String status; //TODO: maybe just bool but isPassed

  const LatestExam({
    required this.moduleShort,
    required this.moduleTitle,
    required this.moduleType,
    required this.grade,
    required this.semester,
    required this.dateGraded,
    required this.dateBooked,
    required this.examType,
    required this.status,
  });

  factory LatestExam.fromData(Map<String, dynamic> json) {
    return switch (json) {
      {
        'AWOBJECT_SHORT': String moduleShort,
        'AWOBJECT': String moduleTitle,
        'AWOTYPE': String moduleType,
        'GRADESYMBOL': String grade,
        'ACAD_SESSION': String semesterPart1,
        'ACAD_YEAR': String semesterPart2,
        'AGRDATE': String dateGraded,
        'BOOKDATE': String dateBooked,
        'AGRTYPE': String examType,
        'AWSTATUS': String status,
      } =>
        LatestExam(
          moduleShort: moduleShort,
          moduleTitle: moduleTitle,
          moduleType: moduleType,
          grade: double.parse(grade.replaceAll(",", ".")),
          semester: "${semesterPart1[0]}S ${semesterPart2.split(" ").last}",
          dateGraded: DateTime.parse(dateGraded),
          dateBooked: DateTime.parse(dateBooked),
          examType: examType,
          status: status,
        ),
      _ => throw const FormatException('Unexpected JSON type for LatestExam'),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'moduleShort': moduleShort,
      'moduleTitle': moduleTitle,
      'moduleType': moduleType,
      'grade': grade,
      'semester': semester,
      'dateGraded': dateGraded.toIso8601String(),
      'dateBooked': dateBooked.toIso8601String(),
      'examType': examType,
      'status': status,
    };
  }

  factory LatestExam.fromJson(Map<String, dynamic> json) {
    return LatestExam(
      moduleShort: json['moduleShort'] as String,
      moduleTitle: json['moduleTitle'] as String,
      moduleType: json['moduleType'] as String,
      grade: json['grade'] as double,
      semester: json['semester'] as String,
      dateGraded: DateTime.parse(json['dateGraded'] as String),
      dateBooked: DateTime.parse(json['dateBooked'] as String),
      examType: json['examType'] as String,
      status: json['status'] as String,
    );
  }

  static LatestExam dummy() {
    return LatestExam(
      moduleShort: "AWP",
      moduleTitle: "Algorithmen und Datenstrukturen",
      moduleType: "K",
      grade: 1.3,
      semester: "WS 2021/22",
      dateGraded: DateTime.now(),
      dateBooked: DateTime.now(),
      examType: "K",
      status: "Bestanden",
    );
  }
}

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
          latest: latest.map((e) => LatestExam.fromData(e as Map<String, dynamic>)).toList(),
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
      'latest': latest.map((e) => e.toJson()).toList(),
    };
  }

  factory Notifications.fromJson(Map<String, dynamic> json) {
    return Notifications(
        electives: json['electives'] as int,
        exams: json['exams'] as int,
        semester: json['semester'] as int,
        upcoming: (json['upcoming'] as List<dynamic>).map((e) => UpcomingExam.fromJson(e as Map<String, dynamic>)).toList(),
        latest: (json['latest'] as List<dynamic>).map((e) => LatestExam.fromJson(e as Map<String, dynamic>)).toList());
  }

  static Notifications dummy() {
    return Notifications(
      electives: 2,
      exams: 3,
      semester: 3,
      upcoming: [UpcomingExam.dummy()],
      latest: [LatestExam.dummy()],
    );
  }
}

// This name might be a bit missleading, but i guess it's too late to change now :/
// A better name would be "LessonRule", as this is used for Lessons and not for Evaluations
class EvaluationRule {
  String pattern;
  Color color;
  bool hide;
  TimeOfDay startTime;
  TimeOfDay endTime;
  // TODO add priority

  EvaluationRule({
    required this.pattern,
    required this.color,
    required this.hide,
    this.startTime = const TimeOfDay(hour: 0, minute: 0),
    this.endTime = const TimeOfDay(hour: 23, minute: 59),
  });

  static EvaluationRule? getMatch(List<EvaluationRule> rules, Lesson lesson) {
    for (final rule in rules) {
      if (RegExp(rule.pattern, caseSensitive: false).hasMatch(lesson.title) && lesson.start.timeOfDay <= rule.endTime && lesson.end.timeOfDay >= rule.startTime) {
        return rule;
      }
    }
    return null;
  }

  static bool shouldHide(List<EvaluationRule> rules, Lesson lesson) {
    final match = getMatch(rules, lesson);

    if (match != null) {
      return match.hide;
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'pattern': pattern,
      'color': color.toHex(),
      'hide': hide,
      'startTime': startTime.formatTime(),
      'endTime': endTime.formatTime(),
    };
  }

  factory EvaluationRule.fromJson(Map<String, dynamic> json) {
    return EvaluationRule(
      pattern: json['pattern'] as String,
      color: HexColor.fromHex(json['color'] as String),
      hide: json['hide'] as bool,
      startTime: ExtTimeOfDay.fromString(json['startTime'] as String? ?? "00:00"),
      endTime: ExtTimeOfDay.fromString(json['endTime'] as String? ?? "23:59"),
    );
  }

  static EvaluationRule dummy() {
    return EvaluationRule(
      pattern: "AWP",
      color: Color(0xFF00FF00),
      hide: false,
    );
  }
}
