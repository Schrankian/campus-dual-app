import 'package:campus_dual_android/extensions/color.dart';
import 'package:flutter/material.dart';
import "package:campus_dual_android/scripts/campus_dual_manager.models.dart";

class DayCalendar extends StatelessWidget {
  const DayCalendar({super.key, this.items, this.startHour = 7, this.endHour = 19, this.stepSize = 50, this.useFuzzyColor = true});

  final List<Lesson>? items;
  final int startHour;
  final int endHour;
  final double stepSize;
  final bool useFuzzyColor;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 10),
      physics: const ScrollPhysics(),
      child: Stack(
        children: [
          Column(
            children: [
              for (final hour in List<int>.generate(endHour - startHour + 1, (i) => i + startHour))
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text("${hour.toString().padLeft(2, '0')}:00 "),
                    Expanded(
                      child: Divider(
                        height: stepSize,
                        thickness: 1,
                      ),
                    )
                  ],
                ),
            ],
          ),
          if (items != null)
            for (final item in items!)
              Positioned(
                top: (item.start.hour - startHour) * stepSize + item.start.minute / 60 * stepSize + stepSize / 2,
                left: 50,
                right: 10,
                child: Container(
                  height: item.end.difference(item.start).inMinutes / 60 * stepSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(color: useFuzzyColor ? FuzzyColor.fromString(item.title) : Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        color: useFuzzyColor ? FuzzyColor.fromString(item.title) : Theme.of(context).colorScheme.primary,
                      ),
                      Expanded(
                        child: ListTile(
                          isThreeLine: true,
                          title: Text(item.title),
                          subtitle: Text('${item.room}\n${item.instructor}'),
                          trailing: Text(item.type),
                          // trailing : Text(item.start.toTimeDiff(item.end, showDifference: false)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
