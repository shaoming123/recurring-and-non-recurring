// ignore: file_names
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/src/recurrring.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:provider/provider.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

import '../../model/manageUser.dart';
import '../../provider/event_provider.dart';
import '../../util/datetime.dart';

class EventAdd extends StatefulWidget {
  final Event? event;
  const EventAdd({Key? key, this.event}) : super(key: key);
  @override
  State<EventAdd> createState() => _EventAddState();
}

class _EventAddState extends State<EventAdd> {
  double _animatedHeight = 0.0;
  late DateTime fromDate;
  late DateTime toDate;
  DateTime? recurringDate;
  DateTime? completeDate;
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  final recurringController = TextEditingController();
  final remarkController = TextEditingController();
  bool checkDuration = true;

  String _selectedVal = '';
  String _selectedPriority = '';
  String _selectedStatus = 'Upcoming';
  String _selectedRecurring = '';
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  List<String> priorityList = <String>['Low', 'Moderate', 'High'];
  List<String> statusList = <String>['Upcoming', 'In-Progress', 'Done'];
  List<String> recurringOption = <String>[
    'Once',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
  ];

  final _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    fromDate = DateTime.now();
    toDate = DateTime.now();

    // toDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 17, 30);
  }

  @override
  void dispose() {
    taskController.dispose();
    durationController.dispose();
    recurringController.dispose();
    remarkController.dispose();

    super.dispose();
  }

  Future pickRecurringDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: fromDate,
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        recurringDate = picked;
      });
    }
  }

  Future pickCompleteDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: fromDate,
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        completeDate = picked;
      });
    }
  }

  Future pickFromDateTime({required bool pickdate}) async {
    final date = await pickDateTime(fromDate, pickdate: pickdate);
    if (date == null) return;

    setState(() {
      fromDate = date;
    });
  }

  Future pickToDateTime(
      {required bool pickdate, required int durationDay}) async {
    final date = await pickDateTime(toDate,
        pickdate: pickdate, durationDay: durationDay);
    if (date == null) return;

    setState(() {
      toDate = date;
    });
  }

  // Future pickToTime({required int durationDay}) async {
  //   final timeSelect = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.fromDateTime(fromDate),
  //   );

  //   final dateDuration =
  //       fromDate.add(Duration(days: int.parse(durationDay.toString())));

  //   final date =
  //       DateTime(dateDuration.year, dateDuration.month, dateDuration.day);
  //   final time = Duration(hours: timeSelect!.hour, minutes: timeSelect.minute);

  //   date.add(time);

  //   if (time == null) return;

  //   setState(() {
  //     toDate = date;
  //     print(toDate);
  //   });
  // }

  //Put date and time format together in one object
  Future<DateTime?> pickDateTime(
    DateTime initialDate, {
    required bool pickdate,
    int? durationDay,
    DateTime? firstDate,
  }) async {
    if (pickdate) {
      final date = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate ?? DateTime(2015, 8),
          lastDate: DateTime(2101));

      if (date == null) return null;

      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);

      return date.add(time);
    } else {
      final timeofDay = await showTimePicker(
          context: context, initialTime: TimeOfDay.fromDateTime(initialDate));

      if (timeofDay == null) return null;

      if (durationDay != null) {
        final date = DateTime(fromDate.year, fromDate.month, fromDate.day)
            .add(Duration(days: durationDay));
        final time = Duration(hours: timeofDay.hour, minutes: timeofDay.minute);
        return date.add(time);
      } else {
        final date =
            DateTime(initialDate.year, initialDate.month, initialDate.day);
        final time = Duration(hours: timeofDay.hour, minutes: timeofDay.minute);

        return date.add(time);
      }
    }
  }

  Future saveEvent() async {
    final isValid = _formkey.currentState!.validate();

    if (isValid) {
      final event = Event(
          category: _selectedVal,
          subCategory: _selectedVal,
          type: _selectedVal,
          site: _selectedVal,
          task: taskController.text,
          from: fromDate.toString(),
          to: toDate.toString(),
          // rule: 'FREQ=DAILY;INTERVAL=1;COUNT=20',
          // backgroundColor: calendarColor.toString(),
          duration: durationController.text,
          priority: _selectedPriority,
          recurringOpt: _selectedRecurring,
          recurringEvery: recurringController.text,
          recurringUntil: recurringDate.toString(),
          remark: remarkController.text,
          completeDate: completeDate.toString(),
          status: _selectedStatus);

      await dbHelper.addEvent(event);

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Recurring()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  contentBox(context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Widget user() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedVal == '' ? null : _selectedVal,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: list
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val as String;
              setState(() {
                _selectedVal = test;
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    Widget userPrio() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedPriority == '' ? null : _selectedPriority,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: priorityList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val as String;
              setState(() {
                _selectedPriority = test;
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    Widget userStatus() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedStatus == '' ? null : _selectedStatus,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: statusList
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val as String;
              setState(() {
                _selectedStatus = test;
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    Widget recurringOpt() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<String>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedRecurring == '' ? null : _selectedRecurring,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: recurringOption
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              String test = val as String;
              setState(() {
                _selectedRecurring = test;
                if (_selectedRecurring == 'Once') {
                  _animatedHeight = 75.0;
                } else {
                  _animatedHeight = 150.0;
                }
              });
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
        ),
      );
    }

    Widget TaskText() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: TextFormField(
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 14),
          maxLines: 8, //or null
          decoration: const InputDecoration(hintText: 'Description...'),
          onFieldSubmitted: (_) {},
          controller: taskController,
          validator: (task) {
            return task != null && task.isEmpty ? 'Task cannot be empty' : null;
          },
        ),
      );
    }

    Widget DurationField() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: TextFormField(
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter your day'),
          onFieldSubmitted: (_) {},
          controller: durationController,
          validator: (duration) {
            return duration != null && duration.isEmpty
                ? 'Duration cannot be empty'
                : null;
          },
        ),
      );
    }

    Widget FromDateSelect() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: ListTile(
          title: Text(
            Utils.toDate(fromDate),
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(
            Icons.calendar_month,
            color: Colors.black,
            size: 20,
          ),
          onTap: () {
            pickFromDateTime(pickdate: true);
          },
        ),
      );
    }

    Widget TimeSelect() {
      return Row(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFd4dce4)),
              child: ListTile(
                title: Text(
                  Utils.toTime(fromDate),
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(
                  Icons.access_time,
                  color: Colors.black,
                  size: 20,
                ),
                onTap: () {
                  pickFromDateTime(pickdate: false);
                },
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: const Text(
              "to",
              style: TextStyle(
                fontSize: 14,
                color: Color(0XFFd4dce4),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFd4dce4)),
              child: ListTile(
                title: Text(
                  Utils.toTime(toDate),
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(
                  Icons.access_time,
                  color: Colors.black,
                  size: 20,
                ),
                onTap: () {
                  if (durationController.text.isEmpty) {
                    setState(() {
                      checkDuration = false;
                    });
                  } else {
                    setState(() {
                      checkDuration = true;
                    });
                    pickToDateTime(
                        pickdate: false,
                        durationDay: int.parse(durationController.text) - 1);
                  }
                },
              ),
            ),
          ),
        ],
      );
    }

    Widget completedDate() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: ListTile(
          title: Text(
            completeDate == null ? 'dd/mm/yy' : Utils.toDate(completeDate!),
            style: const TextStyle(fontSize: 14),
          ),
          trailing: const Icon(
            Icons.calendar_month,
            color: Colors.black,
            size: 20,
          ),
          onTap: () {
            pickCompleteDate();
          },
        ),
      );
    }

    Widget remarkField() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: TextFormField(
          cursorColor: Colors.black,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(hintText: 'Additional Remark.....'),
          onFieldSubmitted: (_) {},
          controller: remarkController,
        ),
      );
    }

    Widget recurringDetail() {
      return AnimatedContainer(
        height: _animatedHeight,
        color: Colors.transparent,
        width: width,
        duration: const Duration(milliseconds: 120),
        child: Column(
          children: [
            _selectedRecurring == 'Once'
                ? Container()
                : Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Every : ",
                          style:
                              TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFd4dce4)),
                          child: TextFormField(
                            cursorColor: Colors.black,
                            style: const TextStyle(fontSize: 14),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '1',
                            ),
                            onFieldSubmitted: (_) {},
                            controller: recurringController,
                            validator: (data) {
                              return data == null &&
                                      data!.isEmpty &&
                                      _selectedRecurring != 'Once'
                                  ? 'Field cannot be empty'
                                  : null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
            Row(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    " Until : ",
                    style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(0),
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFd4dce4)),
                    child: ListTile(
                      title: Text(
                        recurringDate == null
                            ? 'dd/mm/yy'
                            : Utils.toDate(recurringDate!),
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.black,
                        size: 30,
                      ),
                      onTap: () {
                        pickRecurringDate();
                      },
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }

    return Stack(children: <Widget>[
      Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: const Color(0xFF384464),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                const BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Add Task",
                    style: TextStyle(
                        color: Color(0xFFd4dce4),
                        fontSize: 26,
                        fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: Color(0XFFd4dce4),
                    size: 30,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Gap(20),
            Form(
              key: _formkey,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Category :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    user(),
                    const Text(
                      "Sub-Category :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    user(),
                    const Text(
                      "Type :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    user(),
                    const Text(
                      "Site :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    user(),
                    const Text(
                      "Task :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    TaskText(),
                    const Text(
                      "Date :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    FromDateSelect(),
                    const Text(
                      "Duration :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    DurationField(),
                    checkDuration != true
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 30),
                            child: const Text(
                              "Please enter your duration !",
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.only(bottom: 30),
                          ),

                    const Text(
                      "Time :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    TimeSelect(),
                    const Text(
                      "Priority :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userPrio(),
                    const Text(
                      "Recurring :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    recurringOpt(),
                    const Gap(10),
                    // extend recurring
                    recurringDetail(),
                    const Gap(10),
                    const Text(
                      "Remark :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    remarkField(),
                    const Text(
                      "Completed Date : ",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Text(
                      "( autofill when status is Done )",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const Gap(10),
                    completedDate(),
                    const Text(
                      "Status :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userStatus(),
                  ]),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      const EdgeInsets.all(10),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF60b4b4)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                  ),
                  onPressed: () {
                    saveEvent();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFFd4dce4),
                        fontWeight: FontWeight.w700),
                  )),
            ),
          ]))
    ]);
  }
}
