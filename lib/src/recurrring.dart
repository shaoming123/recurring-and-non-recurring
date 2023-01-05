//@dart=2.9
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/src/dialogBox/eventEdit.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:ipsolution/src/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../databaseHandler/DbHelper.dart';
import '../model/eventDataSource.dart';
import '../util/app_styles.dart';
import 'dialogBox/eventAdd.dart';

class Recurring extends StatefulWidget {
  const Recurring({
    Key key,
  }) : super(key: key);

  @override
  State<Recurring> createState() => _RecurringState();
}

List<Event> allEvents = [];
List<String> personList = [];
List<String> functionList = [];
List<String> siteList = <String>[];
List<String> functionData = [];
List<String> currentUserSite = [];
DbHelper dbHelper = DbHelper();
List<String> userList = [];

class _RecurringState extends State<Recurring> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  String _selectedUser = '';
  String _selectedFunction = '';
  String _selectedSite = '';
  String userRole = 'Staff';
  @override
  void initState() {
    super.initState();
    _refreshEvent();
  }

  Future<void> _refreshEvent() async {
    final data = await dbHelper.fetchAllEvent();
    final userData = await dbHelper.getItems();

    final SharedPreferences sp = await _pref;

    _selectedFunction = "All";
    _selectedSite = "All";
    allEvents = [];
    functionList = [];
    userList = [];
    siteList = [];
    setState(() {
      String username = sp.getString("user_name");
      userRole = sp.getString("role");
      functionData = sp.getString("position").split(",");
      String currentUserSiteLead = sp.getString("siteLead");

      currentUserSite = sp.getString("site").split(",");

      _selectedUser = username;

      userList.add("All");

      siteList = currentUserSite;

      for (int i = 0; i < data.length; i++) {
        personList = [];
        personList = data[i]["person"].split(',');

        for (int x = 0; x < personList.length; x++) {
          if (personList[x] == _selectedUser) {
            allEvents.add(Event.fromMap(data[i]));
          }
        }
      }
      for (final item in userData) {
        List siteData = item["site"].split(",");
        List positionList = item["position"].split(",");
        if (userRole == "Manager" || userRole == "Super Admin") {
          functionList = functionData;
          userList.add(item['user_name']);

          siteList = [
            'HQ',
            'CRZ',
            'PR8',
            'PCR',
            'AD2',
            'SKE',
            'SKP',
            'SPP',
            'ALL SITE'
          ];
        } else if (userRole == "Leader" && currentUserSiteLead != "-") {
          functionList = [
            "Community Management",
            "Maintenance Management",
            "Defect",
            "Operations",
            "Financial Management",
            "Procurement",
            "Statistic"
          ];

          for (int y = 0; y < siteData.length; y++) {
            if ((item["role"] == "Leader" || item["role"] == "Staff") &&
                siteData[y] == currentUserSiteLead) {
              userList.add(item["user_name"]);
            }
          }
        } else {
          functionList = functionData;

          for (int i = 0; i < positionList.length; i++) {
            for (int x = 0; x < functionData.length; x++) {
              if (positionList[i] == functionData[x] &&
                  (item["role"] == "Leader" || item["role"] == "Staff")) {
                if (userList.contains(item['user_name'])) {
                } else {
                  userList.add(item["user_name"]);
                }
              }
            }
          }
        }
      }

      // userList.insert(0, "All");
      functionList.insert(0, "All");
      if (userRole == 'Super Admin' || userRole == 'Manager') {
        functionList.insert(1, "Manager");
      }
      siteList.insert(0, "All");
    });
  }

  Future runFilter() async {
    final data = await dbHelper.fetchAllEvent();
    allEvents = [];
    if (mounted) {
      setState(() {
        if (siteList.length == 2) {
          _selectedSite = siteList[1];
        }

        if (functionList.length == 2) {
          _selectedFunction = functionList[1];
        }

        for (int i = 0; i < data.length; i++) {
          personList = [];

          personList = data[i]["person"].split(',');
          String functionCategory = data[i]['category'].split('|')[1];

          for (int x = 0; x < personList.length; x++) {
            if (userList.contains(personList[x])) {
              // if (!allEvents.contains(Event.fromMap(data[i]))) {
              if (_selectedSite == data[i]['site'] &&
                  _selectedUser == personList[x] &&
                  _selectedFunction == functionCategory) {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedUser == 'All' &&
                  _selectedFunction == 'All' &&
                  _selectedSite == data[i]['site']) {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedUser == 'All' &&
                  _selectedFunction == functionCategory &&
                  _selectedSite == 'All') {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedUser == personList[x] &&
                  _selectedFunction == 'All' &&
                  _selectedSite == 'All') {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedUser == personList[x] &&
                  _selectedFunction == functionCategory &&
                  _selectedSite == 'All') {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedUser == personList[x] &&
                  _selectedFunction == 'All' &&
                  _selectedSite == data[i]['site']) {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedUser == 'All' &&
                  _selectedFunction == functionCategory &&
                  _selectedSite == data[i]['site']) {
                allEvents.add(Event.fromMap(data[i]));
              } else if (_selectedSite == 'All' &&
                  _selectedUser == 'All' &&
                  _selectedFunction == 'All') {
                allEvents.add(Event.fromMap(data[i]));
              }
            }
            // }
          }
        }
        allEvents = removeDuplicates(allEvents);
      });
    }
  }

  List<Event> removeDuplicates(List<Event> items) {
    List<Event> uniqueItems = [];
    var uniqueIDs = items
        .map((e) => e.recurringId)
        .toSet(); //list if UniqueID to remove duplicates
    for (var e in uniqueIDs) {
      uniqueItems.add(items.firstWhere((i) => i.recurringId == e));
    }
    return uniqueItems;
  }

  @override
  void dispose() {
    super.dispose();

    allEvents = [];
  }

  @override
  Widget build(BuildContext context) {
    // final CalendarController _calendarController = CalendarController();
    GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    // void calendarTapped(CalendarTapDetails calendarTapDetails) {
    //   if (_calendarController.view == CalendarView.month &&
    //       calendarTapDetails.targetElement == CalendarElement.calendarCell) {
    //     _calendarController.view = CalendarView.day;
    //   } else if ((_calendarController.view == CalendarView.week ||
    //           _calendarController.view == CalendarView.workWeek) &&
    //       calendarTapDetails.targetElement == CalendarElement.viewHeader) {
    //     _calendarController.view = CalendarView.day;
    //   }
    // }

    return Scaffold(
      backgroundColor: Styles.bgColor,
      key: scaffoldKey,
      drawer: const Navbar(), //set gobal key defined above
      body: SingleChildScrollView(
        child: Container(
            height: height - height * 0.08,
            margin: EdgeInsets.only(
                top: height * 0.08, left: width * 0.02, right: width * 0.02),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Appbar(title: "Recurring", scaffoldKey: scaffoldKey),

                  // const Gap(20),
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

                  userRole != 'Staff'
                      ? Container(
                          height: 30,
                          margin: const EdgeInsets.only(bottom: 10, top: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              iconSize: 25,
                              isExpanded: true,
                              value: _selectedUser == '' ? null : _selectedUser,
                              selectedItemHighlightColor: Colors.grey,
                              hint: const Text(
                                'User',
                                style: TextStyle(fontSize: 12),
                              ),
                              // value: ,
                              dropdownMaxHeight: 300,
                              items: userList
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) async {
                                if (mounted) {
                                  setState(() {
                                    _selectedUser = val;
                                  });
                                  await runFilter();
                                }
                              },
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            height: 30,
                            margin: const EdgeInsets.only(bottom: 10, right: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                dropdownMaxHeight: 300,
                                iconSize: 25,
                                isExpanded: true,
                                value: _selectedFunction == ''
                                    ? null
                                    : _selectedFunction,
                                selectedItemHighlightColor: Colors.grey,
                                hint: const Text(
                                  'Function',
                                  style: TextStyle(fontSize: 12),
                                ),
                                // value: ,
                                items: functionList
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (mounted) {
                                    setState(() {
                                      _selectedFunction = val;
                                      runFilter();
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 30,
                            margin: const EdgeInsets.only(bottom: 10, left: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1),
                                borderRadius: BorderRadius.circular(5),
                                color: Colors.white),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                dropdownMaxHeight: 300,
                                iconSize: 25,
                                isExpanded: true,
                                hint: const Text(
                                  'Site',
                                  style: TextStyle(fontSize: 12),
                                ),
                                value:
                                    _selectedSite == '' ? null : _selectedSite,
                                selectedItemHighlightColor: Colors.grey,
                                items: siteList
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(
                                          e,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (mounted) {
                                    setState(() {
                                      _selectedSite = val;
                                      runFilter();
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),

                  Expanded(
                    child: SfCalendar(
                      resourceViewSettings:
                          const ResourceViewSettings(size: 120),
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

                      timeSlotViewSettings: TimeSlotViewSettings(
                        timelineAppointmentHeight: height / 5,
                      ),

                      monthViewSettings: MonthViewSettings(
                        showAgenda: true,
                        agendaItemHeight: height / 5.5,
                        monthCellStyle: const MonthCellStyle(
                            textStyle: TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 10,
                                color: Colors.black)),

                        // appointmentDisplayMode:
                        //     MonthAppointmentDisplayMode.appointment
                      ),

                      scheduleViewSettings: ScheduleViewSettings(
                        hideEmptyScheduleWeek: true,
                        appointmentItemHeight: height / 5,
                      ),

                      // onTap: calendarTapped,
                      todayHighlightColor: Styles.buttonColor,
                      todayTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 12),
                      cellBorderColor: Colors.black26,

                      selectionDecoration: BoxDecoration(
                        border: Border.all(color: Styles.buttonColor, width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        shape: BoxShape.rectangle,
                      ),
                      appointmentBuilder: appointBuilder,
                      // onLongPress: (details) {
                      //   final provider =
                      //       Provider.of<EventProvider>(context, listen: false);

                      //   provider.setDate(details.date!);

                      //   // showModalBottomSheet(
                      //   //     context: context, builder: (context) => RecurringEvent());
                      // },
                    ),
                  )
                ])),
      ),
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

  // Widget appointBuilder(
  //     BuildContext context, CalendarAppointmentDetails details) {
  //   final event = details.appointments.first;

  //   return GestureDetector(
  //     onTap: () {
  //       showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return EventEdit(id: event.recurrenceId);
  //           });
  //     },
  //     child: Container(
  //       // width: details.bounds.width,

  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         color: event.color,
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(10),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //               spreadRadius: 2,
  //               blurRadius: 10,
  //               color: Colors.black.withOpacity(0.1),
  //               offset: const Offset(0, 10))
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: [
  //           Expanded(
  //             flex: 1,
  //             child: Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: Text(event.recurrenceId,
  //                   style: TextStyle(
  //                       fontSize: 16,
  //                       color: Styles.textColor,
  //                       fontWeight: FontWeight.w700)),
  //             ),
  //           ),
  //           Expanded(
  //             flex: 1,
  //             child: Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: Text(
  //                   DateFormat('hh:mm a').format(event.startTime) +
  //                       ' - ' +
  //                       DateFormat('hh:mm a').format(event.endTime),
  //                   maxLines: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                       fontSize: 16,
  //                       color: Styles.textColor,
  //                       fontWeight: FontWeight.w700)),
  //             ),
  //           ),
  //           Expanded(
  //             flex: 3,
  //             child: Padding(
  //               padding: const EdgeInsets.all(5.0),
  //               child: Text(event.notes,
  //                   style: TextStyle(
  //                       fontSize: 16,
  //                       color: Styles.textColor,
  //                       fontWeight: FontWeight.w700)),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Widget appointBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final event = details.appointments.first;
    Color cardColor;

    if (event.status == "Done") {
      cardColor = Colors.grey;
    } else if (event.color == "lightcoral") {
      cardColor = const Color(0xFFf08080);
    } else if (event.color == "palegoldenrod") {
      cardColor = const Color(0xFFeee8aa);
    } else {
      cardColor = const Color(0xFF94ec94);
    }

    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return EventEdit(
                  id: event.recurringId.toString(), user_list: userList);
            });
      },
      child: Container(
        // width: details.bounds.width,

        padding: const EdgeInsets.all(10),

        decoration: BoxDecoration(
          border: Border.all(
              color: darken(cardColor, .2),
              width: 4.0,
              style: BorderStyle.solid),
          color: cardColor,
          borderRadius: const BorderRadius.all(
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
                child: SizedBox.expand(
                  child: Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceBetween,
                    children: <Widget>[
                      Text("(" + event.status + ")",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5b5b5c),
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic)),
                      Text(
                        '${DateFormat('d/M/y').format(DateTime.parse(event.from))} - ${DateFormat('d/M/y').format(DateTime.parse(event.to))}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Styles.textColor,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 2.0, left: 2.0, top: 4.0),
                child: Text(
                    '${DateFormat('hh:mm a').format(DateTime.parse(event.from))} - ${DateFormat('hh:mm a').format(DateTime.parse(event.to))}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12,
                        color: Styles.textColor,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(event.task,
                    style: TextStyle(
                        fontSize: 14,
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
