import 'dart:convert';

import 'package:flutter/material.dart';
import '../extensions/color.dart';
import 'package:http/http.dart' as http;

class UserCredentials {
  String username;
  String hash;

  UserCredentials(this.username, this.hash);

  String authenticate(String uri) {
    return "$uri?user=$username&hash=$hash";
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

  factory Lesson.fromJson(Map<String, dynamic> json) {
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
}

class UpcomingExam {
  final DateTime begin;
  final DateTime end;
  final DateTime date;
  final String comment;
  final String instructor;
  final String moduleShort;
  final String moduleTitle;
  final String room;

  const UpcomingExam({
    required this.begin,
    required this.end,
    required this.date,
    required this.comment,
    required this.instructor,
    required this.moduleShort,
    required this.moduleTitle,
    required this.room,
  });

  factory UpcomingExam.fromJson(Map<String, dynamic> json) {
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
          moduleTitle: moduleTitle,
          room: room,
        ),
      _ => throw const FormatException('Unexpected JSON type for UpcomingExam'),
    };
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

  factory Notifications.fromJson(Map<String, dynamic> json) {
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
          upcoming: upcoming.map((e) => UpcomingExam.fromJson(e as Map<String, dynamic>)).toList(),
          latest: List.empty(),
        ),
      _ => throw const FormatException('Unexpected JSON type for Notifications'),
    };
  }
}

class CampusDualManager {
  static UserCredentials? userCreds;

  CampusDualManager();

  Future<http.Response> _fetch(String uri) async {
    final response = await http.get(Uri.parse(uri));

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception("Failed to fetch from: $uri");
    }
  }

  Future<ExamStats> fetchExamStats() async {
    final response = await _fetch(userCreds!.authenticate("https://selfservice.campus-dual.de/dash/getexamstats"));

    return ExamStats.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<int> fetchCurrentSemester() async {
    final response = await _fetch(userCreds!.authenticate("https://selfservice.campus-dual.de/dash/getfs"));

    return int.parse(response.body.replaceAll(" ", "").replaceAll("\"", ""));
  }

  Future<int> fetchCreditPoints() async {
    final response = await _fetch(userCreds!.authenticate("https://selfservice.campus-dual.de/dash/getcp"));

    return int.parse(response.body);
  }

  Future<List<Lesson>> fetchTimeTable() async {
    final response = await _fetch(userCreds!.authenticate("https://selfservice.campus-dual.de/room/json"));

    final List<dynamic> json = response.body as List<dynamic>;

    return json.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Notifications> fetchNotifications() async {
    final response = await _fetch(userCreds!.authenticate("https://selfservice.campus-dual.de/dash/getreminders"));

    return Notifications.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
