import 'package:campus_dual_android/extensions/color.dart';
import 'package:campus_dual_android/extensions/date.dart';
import 'package:flutter/material.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

class DayCalendar extends StatefulWidget {
  const DayCalendar({super.key, this.items, this.rules, this.startHour = 7, this.endHour = 19, this.stepSize = 50, this.useFuzzyColor = true, this.showTimeIndicator = false});

  final List<Lesson>? items;
  final List<EvaluationRule>? rules;
  final int startHour;
  final int endHour;
  final double stepSize;
  final bool useFuzzyColor;
  final bool showTimeIndicator;

  @override
  State<DayCalendar> createState() => _DayCalendarState();
}

class _DayCalendarState extends State<DayCalendar> {
  DateTime currentTime = DateTime.now();
  late bool isMounted;

  Future<void> updateTime() async {
    while (isMounted) {
      await Future.delayed(const Duration(seconds: 30));
      setState(() {
        currentTime = DateTime.now();
      });
    }
  }

  @override
  void initState() {
    isMounted = true;
    if (widget.showTimeIndicator) {
      updateTime();
    }
    super.initState();
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 10),
      physics: const ScrollPhysics(),
      child: Stack(
        children: [
          Column(
            children: [
              for (final hour in List<int>.generate(widget.endHour - widget.startHour + 1, (i) => i + widget.startHour))
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("${hour.toString().padLeft(2, '0')}:00 "),
                    Expanded(
                      child: Divider(
                        height: widget.stepSize,
                        thickness: 1,
                      ),
                    )
                  ],
                ),
            ],
          ),
          if (widget.items != null)
            for (final item in widget.items!)
              EvaluationRule.shouldHide(widget.rules ?? [], item.title)
                  ? const SizedBox.shrink()
                  : Positioned(
                      top: (item.start.hour - widget.startHour) * widget.stepSize + item.start.minute / 60 * widget.stepSize + widget.stepSize / 2,
                      left: 50,
                      right: 10,
                      child: Container(
                        height: item.end.difference(item.start).inMinutes / 60 * widget.stepSize,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: BaColor.fromRule(widget.rules ?? [], item.title, widget.useFuzzyColor, context),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              color: BaColor.fromRule(widget.rules ?? [], item.title, widget.useFuzzyColor, context),
                            ),
                            Expanded(
                              child: ListTile(
                                isThreeLine: true,
                                title: Text(item.title, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                                subtitle: Text('${item.room} \n${item.instructor}'),
                                // trailing: Text(item.type), // TODO maybe add later but there is no clear type given, so it will be a bit more complex to derive it from context
                                trailing: Text(item.start.toTimeDiff(item.end, showDifference: false)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
          widget.showTimeIndicator
              ? Positioned(
                  top: (currentTime.hour - widget.startHour) * widget.stepSize + currentTime.minute / 60 * widget.stepSize + widget.stepSize / 2,
                  left: 40,
                  right: 0,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.red,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text("hfe"),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
