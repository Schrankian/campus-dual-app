import 'dart:convert';
import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:http_cookie_store/http_cookie_store.dart';
import 'package:html/parser.dart';
import './campus_dual_manager.models.dart';

class CampusDualManager {
  static UserCredentials? userCreds;
  CookieClient? sharedSession;

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

  CampusDualManager({bool? allowNoCreds}) {
    if ((allowNoCreds != null && !allowNoCreds) && userCreds == null) {
      throw Exception("No user credentials provided");
    }
  }

  static Future<CampusDualManager> withSharedSession() async {
    final manager = CampusDualManager();
    if (userCreds!.isDummy) return manager;
    manager.sharedSession = await manager._initAuthSession();
    return manager;
  }

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

    return parse(utf8.decode(response.bodyBytes));
  }

  /*
  * This function initializes the session cookie and therefore logs in the user
  */
  Future<CookieClient> _initAuthSession({String? username, String? password}) async {
    final Uri loginUri = Uri.parse("https://erp.campus-dual.de/sap/bc/webdynpro/sap/zba_initss?sap-client=100&sap-language=de&uri=https%3a%2f%2fselfservice.campus-dual.de%2findex%2flogin");

    CookieClient session = CookieClient();

    // Initial request to get the XSRF token and the xsrf cookie
    final initResponse = await session.get(loginUri, headers: stdHeaders);
    if (initResponse.statusCode != 200) {
      throw Exception("Failed to initialize the login session");
    }

    // Parse the response and get the XSRF token
    final doc = parse(initResponse.body);
    // Get the XSRF token. Hint: The token hides in an hidden input field
    final xsrfToken = doc.querySelector("input[name='sap-login-XSRF']")?.attributes["value"];
    if (xsrfToken == null) {
      throw Exception("Failed to get the XSRF token");
    }

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
    if (userCreds!.isDummy) return ExamStats.dummy();
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getexamstats"));

    return ExamStats.fromData(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<int> fetchCurrentSemester() async {
    if (userCreds!.isDummy) return 3;
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getfs"));

    return int.parse(response.body.replaceAll(" ", "").replaceAll("\"", ""));
  }

  Future<int> fetchCreditPoints() async {
    if (userCreds!.isDummy) return 40;
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getcp"));

    return int.parse(response.body);
  }

  Future<Map<DateTime, List<Lesson>>> fetchTimeTable(DateTime start, DateTime end) async {
    if (userCreds!.isDummy) return {};
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
    if (userCreds!.isDummy) return Notifications.dummy();
    final response = await _fetch(userCreds!.addAuthParams("https://selfservice.campus-dual.de/dash/getreminders"));

    return Notifications.fromData(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<int>> fetchGradeDistribution(String module, String year, String id) async {
    if (userCreds!.isDummy) return [6, 2, 6, 2, 0];
    final response = await _fetch(addQueryParams("https://selfservice.campus-dual.de/acwork/mscoredist", {"module": module, "peryr": year, "perid": id.padLeft(3, "0")}));

    final result = jsonDecode(response.body) as List<dynamic>;
    return result.map((e) => e["COUNT"]! as int).toList();
  }

  Future<GeneralUserData> scrapeGeneralUserData() async {
    if (userCreds!.isDummy) return GeneralUserData.dummy();
    final session = sharedSession ?? await _initAuthSession();
    final doc = await _scrape(session, "https://selfservice.campus-dual.de/index/login");

    final studInfo = doc.querySelector("#studinfo")!.querySelector("td")!;

    // Iterate over the children of the studinfo table cell
    // Form:
    // <td width="85%">
    //  <strong>Name: </strong>Schuster, Fabian (.....),
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

    final session = sharedSession ?? await _initAuthSession(username: username, password: password);
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
    if (userCreds!.isDummy) return [MasterEvaluation.dummy()];
    final session = sharedSession ?? await _initAuthSession();
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
        final credits = int.tryParse(element.children[3].text.trim());
        final isPartlyGraded = false; //TODO: Implement
        final semester = element.children.last.text.trim();
        evaluations.add(MasterEvaluation(module: module, title: title, grade: grade, isPassed: isPassed, isPartlyGraded: isPartlyGraded, semester: semester, credits: credits ?? 0, subEvaluations: <Evaluation>[]));
      } else if (!element.className.contains("head")) {
        final titleRegex = RegExp(r'^[^ ]+ (.*?)(?: ?\((.*?)\))? \((.*?)\)$');
        final match = titleRegex.firstMatch(element.children[0].text.trim());

        final title = match!.group(1)!.trim();
        final type = match.group(2)?.trim() ?? '';
        final module = match.group(3)!.trim();

        final gradeElement = element.children[1].querySelector(".mscore")!;
        final grade = double.tryParse(gradeElement.text.trim().replaceAll(",", ".")) ?? -1;
        final gradeDistribution = await fetchGradeDistribution(gradeElement.attributes["data-module"]!, gradeElement.attributes["data-peryr"]!, gradeElement.attributes["data-perid"]!);

        final isPassed = element.children[2].querySelector("img")!.attributes["src"]! == "/images/green.png";

        final splitDateGraded = element.children[4].text.split(".");
        final dateGraded = DateTime.parse(splitDateGraded[2] + splitDateGraded[1] + splitDateGraded[0]);

        final splitDateAnnounced = element.children[5].text.split(".");
        final dateAnnounced = DateTime.parse(splitDateAnnounced[2] + splitDateAnnounced[1] + splitDateAnnounced[0]);

        final isPartlyGraded = false; // TODO: implement
        final semester = element.children.last.text.trim();

        evaluations.last.subEvaluations
            .add(Evaluation(module: module, title: title, type: type, grade: grade, gradeDistribution: gradeDistribution, isPassed: isPassed, dateGraded: dateGraded, dateAnnounced: dateAnnounced, isPartlyGraded: isPartlyGraded, semester: semester));
      }
    }

    return evaluations;
  }
}
