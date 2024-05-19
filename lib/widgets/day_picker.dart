import 'package:flutter/material.dart';

class DayPicker extends StatefulWidget {
  const DayPicker({super.key, required this.currentDate, this.onDateChanged});

  final DateTime currentDate;
  final void Function(DateTime)? onDateChanged;

  @override
  State<DayPicker> createState() => _DayPickerState();
}

class _DayPickerState extends State<DayPicker> {
  static const weekDays = ['_Err_', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const month = ['_Err_', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];

  late DateTime currentDateState;

  @override
  void initState() {
    currentDateState = widget.currentDate;
    super.initState();
  }

  @override
  void didUpdateWidget(DayPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDate != oldWidget.currentDate) {
      setState(() {
        currentDateState = widget.currentDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Column(
        children: [
          Text("${month[currentDateState.month]} ${currentDateState.year}"),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 10) {
                  setState(() {
                    currentDateState = currentDateState.subtract(const Duration(days: 7));
                  });
                } else if (details.primaryVelocity! < -10) {
                  setState(() {
                    currentDateState = currentDateState.add(const Duration(days: 7));
                  });
                }
              },
              child: ListView.separated(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final diff = index + 1 - currentDateState.weekday;
                  final date = currentDateState.add(Duration(days: diff));

                  return GestureDetector(
                    onTap: () {
                      if (widget.onDateChanged != null) {
                        widget.onDateChanged!(date);
                      }
                      setState(() {
                        currentDateState = date;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: date.compareTo(widget.currentDate) == 0 ? Theme.of(context).colorScheme.primary.withAlpha(80) : Colors.transparent,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              date.day.toString(),
                            ),
                            Text(
                              weekDays[date.weekday],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const VerticalDivider(
                    color: Colors.black,
                    thickness: 1,
                    width: 0,
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
