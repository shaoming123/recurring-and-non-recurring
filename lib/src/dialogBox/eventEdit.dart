// ignore: file_names
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/event.dart';
import 'package:provider/provider.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

import '../../model/manageUser.dart';
import '../../provider/event_provider.dart';
import '../../util/datetime.dart';

class EventEdit extends StatefulWidget {
  final Event? event;
  const EventEdit({Key? key, this.event}) : super(key: key);
  @override
  State<EventEdit> createState() => _EventEditState();
}

String _selectedVal = "Choose";
List<String> list = <String>['Choose', 'One', 'Two', 'Three', 'Four'];
final _formkey = GlobalKey<FormState>();

class _EventEditState extends State<EventEdit> {
  late DateTime fromDate;
  late DateTime toDate;
  late Color calendarColor;
  // final fromtime = Duration(hours: 9, minutes: 30);
  final taskController = TextEditingController();
  final durationController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.event == null) {
      fromDate = DateTime.now();
      toDate = DateTime.now();

      // toDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 17, 30);

      calendarColor =
          Colors.primaries[Random().nextInt(Colors.primaries.length)];
    } else {
      final event = widget.event;

      DateTime fromEvent = event!.from as DateTime;
      DateTime toEvent = event.to as DateTime;
      Color backgroundColor = event.backgroundColor as Color;

      _selectedVal = event.category;
      taskController.text = event.task;
      durationController.text = event.duration.toString();
      // calendarColor = backgroundColor;
      fromDate = fromEvent;
      toDate = toEvent;
    }
  }

  @override
  void dispose() {
    taskController.dispose();
    super.dispose();
  }

  Future pickFromDateTime({required bool pickdate}) async {
    final date = await pickDateTime(fromDate, pickdate: pickdate);
    if (date == null) return;

    setState(() {
      fromDate = date;
    });
  }

  Future pickToDateTime({required bool pickdate, int? durationDay}) async {
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
        final date = DateTime(toDate.year, toDate.month, toDate.day)
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
    //Title 1

    final isValid = _formkey.currentState!.validate();

    if (isValid) {
      String from = '$fromDate';
      String to = '$toDate';
      final event = Event(
          category: _selectedVal,
          subCategory: _selectedVal,
          type: _selectedVal,
          site: _selectedVal,
          task: taskController.text,
          from: from,
          to: to,
          // rule: 'FREQ=DAILY;INTERVAL=1;COUNT=20',
          // backgroundColor: calendarColor.toString(),
          duration: durationController.text,
          priority: _selectedVal);

      final isEditing = widget.event != null;
      final provider = Provider.of<EventProvider>(context, listen: false);

      if (isEditing) {
        provider.editEvent(event, widget.event!);
      } else {
        provider.addEvent(event);
      }
      Navigator.of(context).pop();
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
            hint: Text("Choose item"),
            value: _selectedVal == 'Choose' ? null : _selectedVal,
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
              setState(() {
                _selectedVal = val as String;
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
        margin: const EdgeInsets.only(bottom: 30),
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
                  pickToDateTime(
                      pickdate: false,
                      durationDay: int.parse(durationController.text));
                },
              ),
            ),
          ),
        ],
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
                    user(),
                    const Text(
                      "Status :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    user(),
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
