import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/manageUser.dart';
import 'package:ipsolution/src/dialogBox/eventEdit.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../model/eventDataSource.dart';
import '../provider/event_provider.dart';
import '../util/app_styles.dart';
import 'dialogBox/eventAdd.dart';

class Recurring extends StatefulWidget {
  const Recurring({super.key});

  @override
  State<Recurring> createState() => _RecurringState();
}

List<Event> allEvents = [];
List<String> personList = [];

class _RecurringState extends State<Recurring> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    _refreshEvent();
  }

  Future<void> _refreshEvent() async {
    final data = await dbHelper.fetchAllEvent();

    final SharedPreferences sp = await _pref;
    String username = sp.getString("user_name")!;
    allEvents = [];
    setState(() {
      for (int i = 0; i < data.length; i++) {
        personList = [];
        personList = data[i]["person"].split(',');

        for (int x = 0; x < personList.length; x++) {
          if (personList[x] == username) {
            allEvents.add(Event.fromMap(data[i]));
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    personList = [];
    allEvents = [];
  }

  @override
  Widget build(BuildContext context) {
    final CalendarController _calendarController = CalendarController();
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    void calendarTapped(CalendarTapDetails calendarTapDetails) {
      if (_calendarController.view == CalendarView.month &&
          calendarTapDetails.targetElement == CalendarElement.calendarCell) {
        _calendarController.view = CalendarView.day;
      } else if ((_calendarController.view == CalendarView.week ||
              _calendarController.view == CalendarView.workWeek) &&
          calendarTapDetails.targetElement == CalendarElement.viewHeader) {
        _calendarController.view = CalendarView.day;
      }
    }

    return Scaffold(
      backgroundColor: Styles.bgColor,
      key: scaffoldKey,
      drawer: const Navbar(), //set gobal key defined above
      body: Container(
          margin: EdgeInsets.only(
              top: height * 0.08, left: width * 0.02, right: width * 0.02),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.black),
                  onPressed: () => scaffoldKey.currentState!.openDrawer(),
                ),
                Text("Recurring", style: Styles.title),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.black),
                  onPressed: () => {},
                ),
              ],
            ),
            const Gap(20),
            // Expanded(
            //     child: FutureBuilder<List>(
            //         future: dbHelper.fetchAllEvent(),
            //         builder: (context, snapshot) {
            //           List<Event> collection = <Event>[];

            //           if (snapshot.data != null) {
            //             return ListView.builder(
            //                 itemCount: 1,
            //                 itemBuilder: (context, int position) {
            //                   var item = snapshot.data![position];

            //                   for (int i = 0; i < snapshot.data!.length; i++) {
            //                     collection.add(
            //                       Event(
            //                           category: item.category,
            //                           subCategory: item.subCategory,
            //                           task: item.task,
            //                           duration: item.duration,
            //                           from: item.from,
            //                           to: item.to,
            //                           priority: item.priority,
            //                           site: item.site,
            //                           type: item.type,
            //                           recurringId: item.recurringId,
            //                           backgroundColor: item.backgroundColor),
            //                     );
            //                   }

            //                   return SfCalendar(
            //                     dataSource: EventDataSource(collection),
            //                     backgroundColor: Colors.white,
            //                     view: CalendarView.month,
            //                     allowedViews: const <CalendarView>[
            //                       CalendarView.month,
            //                       CalendarView.week,
            //                       CalendarView.day,
            //                     ],
            //                     initialSelectedDate: DateTime.now(),
            //                     // controller: _calendarController,
            //                     monthViewSettings: const MonthViewSettings(
            //                       showAgenda: true,
            //                       agendaViewHeight: 200,
            //                       // appointmentDisplayMode:
            //                       //     MonthAppointmentDisplayMode.appointment
            //                     ),

            //                     onTap: calendarTapped,
            //                     todayHighlightColor: Styles.buttonColor,
            //                     todayTextStyle: const TextStyle(
            //                         color: Colors.black,
            //                         fontWeight: FontWeight.w700),
            //                     cellBorderColor: Colors.black26,

            //                     selectionDecoration: BoxDecoration(
            //                       border: Border.all(
            //                           color: Styles.buttonColor, width: 2),
            //                       borderRadius: const BorderRadius.all(
            //                           Radius.circular(4)),
            //                       shape: BoxShape.rectangle,
            //                     ),
            //                     appointmentBuilder: appointBuilder,
            //                     onLongPress: (details) {
            //                       final provider = Provider.of<EventProvider>(
            //                           context,
            //                           listen: false);

            //                       provider.setDate(details.date!);

            //                       // showModalBottomSheet(
            //                       //     context: context, builder: (context) => RecurringEvent());
            //                     },
            //                   );
            //                 });
            //           } else {
            //             return const CircularProgressIndicator();
            //           }
            //         }))
            Expanded(
              child: SfCalendar(
                dataSource: EventDataSource(allEvents),
                backgroundColor: Colors.white,
                view: CalendarView.month,
                allowViewNavigation: true,
                showDatePickerButton: true,
                allowedViews: const <CalendarView>[
                  CalendarView.month,
                  CalendarView.timelineWeek,
                  CalendarView.day,
                  CalendarView.schedule
                ],
                initialSelectedDate: DateTime.now(),
                timeSlotViewSettings:
                    TimeSlotViewSettings(timelineAppointmentHeight: height / 5),
                // controller: _calendarController,
                monthViewSettings: MonthViewSettings(
                  showAgenda: true,
                  agendaItemHeight: height / 5,

                  // appointmentDisplayMode:
                  //     MonthAppointmentDisplayMode.appointment
                ),
                scheduleViewSettings: ScheduleViewSettings(
                    hideEmptyScheduleWeek: true,
                    appointmentItemHeight: height / 5),

                onTap: calendarTapped,
                todayHighlightColor: Styles.buttonColor,
                todayTextStyle: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700),
                cellBorderColor: Colors.black26,

                selectionDecoration: BoxDecoration(
                  border: Border.all(color: Styles.buttonColor, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
                appointmentBuilder: appointBuilder,
                onLongPress: (details) {
                  final provider =
                      Provider.of<EventProvider>(context, listen: false);

                  provider.setDate(details.date!);

                  // showModalBottomSheet(
                  //     context: context, builder: (context) => RecurringEvent());
                },
              ),
            )
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return const EventAdd();
              });
        },
        backgroundColor: Styles.buttonColor,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget appointBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final event = details.appointments.first;

    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return EventEdit(id: event.recurrenceId);
            });
      },
      child: Container(
        // width: details.bounds.width,

        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: event.color,
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
                spreadRadius: 2,
                blurRadius: 10,
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(event.recurrenceId,
                    style: TextStyle(
                        fontSize: 16,
                        color: Styles.textColor,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                    DateFormat('hh:mm a').format(event.startTime) +
                        ' - ' +
                        DateFormat('hh:mm a').format(event.endTime),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 16,
                        color: Styles.textColor,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(event.notes,
                    style: TextStyle(
                        fontSize: 16,
                        color: Styles.textColor,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
