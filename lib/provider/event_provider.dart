import 'package:flutter/cupertino.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/manageUser.dart';

class EventProvider extends ChangeNotifier {
  final List<Event> _events = <Event>[];

  List<Event> get events => _events;

  // select the lastly clicked date
  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventsOfSelectedDate => _events;

  void addEvent(Event event) async {
    DbHelper dbHelper = DbHelper();

    await dbHelper.addEvent(event);

    notifyListeners();
  }

  void editEvent(Event newEvent, Event oldEvent) {
    final index = _events.indexOf(oldEvent);
    _events[index] = newEvent;

    notifyListeners();
  }

  // Future<Map<String, dynamic>> mapEventData (){

  // }
}
