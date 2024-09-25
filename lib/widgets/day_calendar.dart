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
  List<List<Lesson>> itemsStacked = [[]];

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
  void didUpdateWidget(covariant DayCalendar oldWidget) {
    // On external change
    itemsStacked = [[]];
    if (widget.items != null) {
      for (final item in widget.items!) {
        if (EvaluationRule.shouldHide(widget.rules ?? [], item.title)) {
          continue;
        }
        if (itemsStacked.last.isEmpty) {
          itemsStacked.last.add(item);
        } else if (itemsStacked.last.last.end.isBefore(item.start)) {
          itemsStacked.add([item]);
        } else {
          itemsStacked.last.add(item);
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      // Stack for the time indicator
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 10),
            // Stack for the actual calendar
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
                for (final items in itemsStacked)
                  for (final item in items)
                    Positioned(
                      top: (item.start.hour - widget.startHour) * widget.stepSize + item.start.minute / 60 * widget.stepSize + widget.stepSize / 2,
                      left: 50 + items.indexOf(item) * 15,
                      right: 10 + items.indexOf(item) * -5,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            itemsStacked = itemsStacked.map((items) {
                              if (items.isNotEmpty) {
                                final lastItem = items.removeLast();
                                items.insert(0, lastItem);
                              }
                              return items;
                            }).toList();
                          });
                        },
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
                    ),
              ],
            ),
          ),
          widget.showTimeIndicator
              ? Positioned(
                  top: (currentTime.hour - widget.startHour) * widget.stepSize + currentTime.minute / 60 * widget.stepSize + widget.stepSize / 2,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: const Offset(0, -15),
                    child: Row(
                      children: [
                        CustomPaint(
                          size: const Size(15, 30),
                          painter: TrianglePainter(context),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(220),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(50),
                                  spreadRadius: Theme.of(context).brightness == Brightness.light ? 1 : 0.4,
                                  blurRadius: 2,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final BuildContext context;

  TrianglePainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(220)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(0, size.height);
    path.close();

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Theme.of(context).colorScheme.onPrimaryContainer.withAlpha(50)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
