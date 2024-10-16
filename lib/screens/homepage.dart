import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:campus_dual_android/screens/body/body_evaluations.dart';
import 'package:campus_dual_android/screens/body/body_news.dart';
import 'package:campus_dual_android/widgets/sync_starter.dart';
import 'package:flutter/scheduler.dart';
import 'package:preload_page_view/preload_page_view.dart';
import '../widgets/settings_popup.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'body/body_overview.dart';
import 'body/body_timetable.dart';
import 'settings.dart';
import '../scripts/event_bus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;
  bool settingIsActive = false;
  late PreloadPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PreloadPageController(initialPage: _currentIndex);

    // Generate keys for all pages and asign them
    keys = List.generate(4, (index) => GlobalKey());
    body = [
      News(key: keys[0]),
      EvaluationsPage(key: keys[1]),
      Overview(key: keys[2]),
      TimeTable(key: keys[3]),
    ];
    mainBus.onBus(event: "SetMainNavigationIndex", onEvent: _setMainNavigationIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    mainBus.offBus(event: "SetMainNavigationIndex", callBack: _setMainNavigationIndex);
    super.dispose();
  }

  void _setMainNavigationIndex(dynamic args) {
    if (args < body.length) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = args;
          _pageController.animateToPage(args, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        });
      });
    }
  }

  // The list for all possible pages together with their keys. Is initialized in initState
  late final List<GlobalKey> keys;
  late final List<Widget> body;
  // The list for the icons in the bottom navigation bar. Should match the body list
  List<IconData> icons = [
    Ionicons.notifications_outline,
    Ionicons.book_outline,
    Ionicons.home_outline,
    Ionicons.calendar_outline,
  ];
  //This contains all actions which always popup if settings has been pressed
  List<Map<String, dynamic>> settingIcons = [
    {
      'icon': Ionicons.musical_note,
      'function': (context) {
        mainBus.emit(event: 'ToggleTheme');
      },
    },
    {
      'icon': Ionicons.settings_outline,
      'function': (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Settings()),
        );
      }
    }
  ];

  //These are extra actions which only popup on the specific size (index in list correspond to the slide it pops up)
  List<List<Map<String, dynamic>>> extraSettingIcons = [
    [],
    [
      {
        'icon': Ionicons.albums_outline,
        'function': (context) {
          mainBus.emit(event: 'OpenSemesterEvaluations', args: context);
        },
      }
    ],
    [],
    [
      {
        'icon': Ionicons.calendar_outline,
        'function': (context) {
          mainBus.emit(event: 'OpenCalendar', args: context);
        },
      },
    ],
  ];

  @override
  Widget build(BuildContext context) {
    settingIcons[0]['icon'] = Theme.of(context).brightness == Brightness.dark ? Ionicons.sunny_outline : Ionicons.moon_outline;
    return Scaffold(
      body: SyncStarter(
        onSync: () {
          for (final key in keys) {
            key.currentState?.setState(() {});
          }
        },
        child: PreloadPageView(
          preloadPagesCount: body.length,
          physics: const NeverScrollableScrollPhysics(),
          pageSnapping: true,
          controller: _pageController,
          onPageChanged: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
          children: body,
        ),
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        backgroundColor: Theme.of(context).colorScheme.surface,
        height: 75,
        elevation: 10,
        splashRadius: 0,
        itemCount: body.length + 1,
        hideAnimationCurve: Curves.elasticOut,
        splashSpeedInMilliseconds: 0,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        tabBuilder: (index, isActive) {
          if (index != body.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    icons[index],
                    size: 30,
                    color: isActive ? Theme.of(context).colorScheme.primary : null,
                  ),
                  Text(
                    isActive ? '•' : ' ',
                    style: TextStyle(
                      fontSize: 20,
                      color: isActive ? Theme.of(context).colorScheme.primary : null,
                      fontFamily: 'roboto',
                    ),
                  )
                ],
              ),
            );
          } else {
            return SettingsPopup(
              icons: (extraSettingIcons[_currentIndex].map((e) => e['icon'] as IconData).toList()) + (settingIcons.map((e) => e['icon'] as IconData).toList()),
              onIconTapped: (index) {
                (extraSettingIcons[_currentIndex].map((e) => e['function']).toList() + settingIcons.map((e) => e['function']).toList())[index](context);
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Icon(
                  Ionicons.ellipsis_horizontal,
                  size: 27,
                  color: isActive ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            );
          }
        },
        gapLocation: GapLocation.none,
        notchSmoothness: NotchSmoothness.sharpEdge,
        activeIndex: _currentIndex,
        onTap: (index) => setState(() {
          if (index < body.length) {
            _currentIndex = index;
            _pageController.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
          }
        }),
      ),
    );
  }
}
