import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/model/manageUser.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../model/eventDataSource.dart';
import '../provider/event_provider.dart';
import '../util/app_styles.dart';
import 'dialogBox/eventEdit.dart';

class Recurring extends StatefulWidget {
  const Recurring({super.key});

  @override
  State<Recurring> createState() => _RecurringState();
}

class _RecurringState extends State<Recurring> {
  @override
  Widget build(BuildContext context) {
    final events = Provider.of<EventProvider>(context).events;
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
            Expanded(
              child: SfCalendar(
                dataSource: EventDataSource(events),
                backgroundColor: Colors.white,
                view: CalendarView.month,
                allowedViews: const <CalendarView>[
                  CalendarView.month,
                  CalendarView.week,
                  CalendarView.day,
                ],
                initialSelectedDate: DateTime.now(),
                // controller: _calendarController,
                monthViewSettings: const MonthViewSettings(
                  showAgenda: true,
                  agendaViewHeight: 200,
                  // appointmentDisplayMode:
                  //     MonthAppointmentDisplayMode.appointment
                ),

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
            ),
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context)  {
              
                return const EventEdit();
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

    return Container(
      width: details.bounds.width,
      height: details.bounds.height,
      decoration: BoxDecoration(color: event.backgroundColor.withOpacity(0.5)),
      child: Text(
        event.from.toString(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
