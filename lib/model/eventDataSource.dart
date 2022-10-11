import 'package:flutter/animation.dart';
import 'package:ipsolution/model/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
 
  EventDataSource(List<Event> appointments) {
    this.appointments = appointments;
  }

  Event getEvent(int index) => appointments![index];

  @override
  DateTime getStartTime(int index) => getEvent(index).from as DateTime;

  @override
  DateTime getEndTime(int index) => getEvent(index).to as DateTime;

  @override
  String getSubject(int index) => getEvent(index).category;

  String getSubCategory(int index) => getEvent(index).subCategory;

  String getType(int index) => getEvent(index).type;

  String getSite(int index) => getEvent(index).site;

  String getTask(int index) => getEvent(index).task;

  String getPriority(int index) => getEvent(index).priority;

  // @override
  // String getRecurrenceRule(int index) => getEvent(index).rule;

  // @override
  // Color getColor(int index) => getEvent(index).backgroundColor as Color;
}
