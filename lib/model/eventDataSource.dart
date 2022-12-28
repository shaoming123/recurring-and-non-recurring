import 'package:flutter/material.dart';
import 'package:ipsolution/model/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

// get the difference between two days
int daysBetween(DateTime from, DateTime to) {
  from = DateTime(from.year, from.month, from.day);
  to = DateTime(to.year, to.month, to.day);
  return (to.difference(from).inHours / 24).round();
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<Event> sources) {
    appointments = sources;
  }

  Event getEvent(int index) => appointments![index];

  @override
  DateTime getStartTime(int index) => DateTime.parse(getEvent(index).from);

  @override
  DateTime getEndTime(int index) => DateTime.parse(getEvent(index).to);

  @override
  String getSubject(int index) => getEvent(index).category;

  @override
  String getRecurrenceId(int index) => getEvent(index).recurringId.toString();

  String getRecurringOption(int index) => getEvent(index).recurringOpt;

  // String getRecurringDate(int index) => getEvent(index).recurringUntil!;

  String getRecurringEvery(int index) {
    return getEvent(index).recurringEvery;
  }

  // @override
  // String getRecurrenceRule(int index) {
  //   String freq = getEvent(index).recurringOpt.toUpperCase();
  //   String recurringDate = DateFormat('yyyyMMdd')
  //       .format(DateTime.parse(getEvent(index).recurringUntil));
  //   String recurringEvery = getEvent(index).recurringEvery.toString();
  //   // print(getEvent(index).recurringId);
  //   late String rule;
  //   print(getEvent(index).recurringEvery);

  //   // Once
  //   if (getEvent(index).recurringOpt == 'Once') {
  //     String difference = daysBetween(DateTime.parse(getEvent(index).to),
  //             DateTime.parse(getEvent(index).recurringUntil))
  //         .toString();

  //     rule = 'FREQ=DAILY;INTERVAL=$difference;UNTIL=$recurringDate';

  //     //Daily
  //   } else if (getEvent(index).recurringOpt == 'Daily') {
  //     int dailyInterval = int.parse(getEvent(index).duration) +
  //         int.parse(getEvent(index).recurringEvery);

  //     rule = 'FREQ=$freq;INTERVAL=$dailyInterval;UNTIL=$recurringDate';

  //     //Weekly
  //   } else if (getEvent(index).recurringOpt == 'Weekly') {
  //     String weekday = DateFormat('EEEE')
  //         .format(DateTime.parse(getEvent(index).from))
  //         .toUpperCase();

  //     rule =
  //         'FREQ=$freq;INTERVAL=$recurringEvery;BYDAY=$weekday;UNTIL=$recurringDate';

  //     // Monthly
  //   } else if (getEvent(index).recurringOpt == 'Monthly') {
  //     String dateNumber =
  //         DateFormat('dd').format(DateTime.parse(getEvent(index).from));

  //     rule =
  //         'FREQ=$freq;BYMONTHDAY=$dateNumber;INTERVAL=$recurringEvery;UNTIL=$recurringDate';

  //     // Yearly
  //   } else if (getEvent(index).recurringOpt == 'Yearly') {
  //     //  rule = 'FREQ=YEARLY;BYMONTHDAY=17;BYMONTH=10;INTERVAL=1;UNTIL=20231229';
  //   }

  //   return rule;

  //   return _recurrenceRule;
  // }

  String getSubCategory(int index) => getEvent(index).subCategory;

  String getPerson(int index) => getEvent(index).person;

  String getType(int index) => getEvent(index).type;

  String getDuration(int index) => getEvent(index).duration;

  String getSite(int index) => getEvent(index).site;

  String getNotes(int index) => getEvent(index).task;

  String getPriority(int index) => getEvent(index).priority;

  String getStatus(int index) => getEvent(index).status;

  String getColors(int index) => getEvent(index).color;

  @override
  bool isAllDay(int index) {
    return false;
  }

  @override
  Color getColor(int index) {
    late Color color;
    if (getEvent(index).status == "Done") {
      color = Colors.grey;
    } else if (getEvent(index).color == "lightcoral") {
      color = Colors.redAccent;
    } else if (getEvent(index).color == "palegoldenrod") {
      color = Colors.yellow;
    } else {
      color = Colors.greenAccent;
    }

    return color;
  }
}
