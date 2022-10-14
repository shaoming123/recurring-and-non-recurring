import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:ipsolution/model/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

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

  // @override
  // String getRecurrenceRule(int index) => 'FREQ=DAILY;INTERVAL=1';

  String getSubCategory(int index) => getEvent(index).subCategory;

  String getType(int index) => getEvent(index).type;

  String getSite(int index) => getEvent(index).site;

  String getTask(int index) => getEvent(index).task;

  String getPriority(int index) => getEvent(index).priority;

  @override
  Color getColor(int index) {
    late Color color;
    if (getEvent(index).priority == "High") {
      color = Colors.redAccent;
    } else if (getEvent(index).priority == "Moderate") {
      color = Colors.yellowAccent;
    } else {
      color = Colors.greenAccent;
    }

    return color;
  }
}
