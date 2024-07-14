import 'package:campus_dual_android/extensions/color.dart';
import 'package:campus_dual_android/extensions/date.dart';
import 'package:campus_dual_android/scripts/campus_dual_manager.models.dart';
import 'package:flutter/material.dart';

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({super.key, this.items, this.rules, required this.startTime, this.onDateClicked, this.useFuzzyColor = true});

  final Map<DateTime, List<Lesson>>? items;
  final List<EvaluationRule>? rules;
  final DateTime startTime;
  final bool useFuzzyColor;
  final void Function(DateTime)? onDateClicked;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  static const weekDays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  static const month = ['_Err_', 'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];

  final dateNow = DateTime.now().trim();

  late DateTime selectedDate = DateTime(widget.startTime.year, widget.startTime.month, 1);

  @override
  Widget build(BuildContext context) {
    final filteredItems = {
      for (final key in widget.items!.keys)
        if (key.year == selectedDate.year && key.month == selectedDate.month) key: widget.items![key]
    };
    final months = DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kalendar"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
                  });
                },
              ),
              Text("${month[selectedDate.month]} ${selectedDate.year.toString()}"),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 2),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final day in weekDays) Text(day),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 10) {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month - 1, 1);
                  });
                } else if (details.primaryVelocity! < -10) {
                  setState(() {
                    selectedDate = DateTime(selectedDate.year, selectedDate.month + 1, 1);
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      itemCount: months + selectedDate.weekday - 1, // Add Padding, because the first day of the month is not always on Monday
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisSpacing: 3,
                        crossAxisSpacing: 3,
                        crossAxisCount: 7,
                        mainAxisExtent: constraints.maxHeight / 6 - 3,
                      ),
                      itemBuilder: (context, index) {
                        index -= selectedDate.weekday - 1;
                        if (index < 0) {
                          return const Text("");
                        }

                        final date = DateTime(selectedDate.year, selectedDate.month, index + 1);
                        final items = filteredItems[date];
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => {
                            if (widget.onDateClicked != null) widget.onDateClicked!(date),
                            Navigator.of(context).pop(),
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: date == widget.startTime ? Theme.of(context).colorScheme.error.withAlpha(200) : Colors.transparent,
                                width: 2,
                              ),
                              color: Theme.of(context).colorScheme.primary.withAlpha(date == dateNow ? 150 : 50),
                            ),
                            child: Column(
                              children: [
                                Text("${index + 1}"),
                                if (items != null)
                                  for (final item in items.take(6))
                                    EvaluationRule.shouldHide(widget.rules ?? [], item.title)
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.only(left: 2, bottom: 1, top: 1, right: 2),
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 3, top: 1, bottom: 1, right: 3),
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: BaColor.fromRule(widget.rules ?? [], item.title, widget.useFuzzyColor, context),
                                                borderRadius: BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                item.title,
                                                style: TextStyle(
                                                  color: BaColor.fromSurface(BaColor.fromRule(widget.rules ?? [], item.title, widget.useFuzzyColor, context)),
                                                  fontSize: 8,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
