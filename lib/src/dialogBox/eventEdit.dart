import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import '../../model/event.dart';
import '../../util/datetime.dart';
import '../recurrring.dart';

class EventEdit extends StatefulWidget {
  final String id;
  const EventEdit({Key? key, required this.id}) : super(key: key);

  @override
  State<EventEdit> createState() => _EventEditState();
}

final _formkey = GlobalKey<FormState>();
late DateTime fromDate = DateTime.now();
late DateTime toDate = DateTime.now();
DateTime? recurringDate;
DateTime? completeDate;
TextEditingController taskController = TextEditingController();
TextEditingController durationController = TextEditingController();
TextEditingController recurringController = TextEditingController();
final remarkController = TextEditingController();
String _selectedVal = '';
String _selectedPriority = '';
String _selectedStatus = '';
String _selectedRecurring = '';
List<Map<String, dynamic>> event_edit = [];
List<String> list = <String>['One', 'Two', 'Three', 'Four'];
List<String> priorityList = <String>['Low', 'Moderate', 'High'];
List<String> statusList = <String>['Upcoming', 'In-Progress', 'Done'];

class _EventEditState extends State<EventEdit> {
  DbHelper dbHelper = DbHelper();
  late int recurringId;
  DateTime? recurringDate;
  DateTime? completeDate;
  String _selectedStatus = '';
  @override
  void initState() {
    super.initState();

    getData(int.parse(widget.id));

    print(fromDate.toString());
  }

  Future<void> getData(int id) async {
    event_edit = await dbHelper.fetchAEvent(id);

    setState(() {
      recurringId = event_edit[0]['recurringId'];
      fromDate = DateTime.parse(event_edit[0]['fromD']);
      toDate = DateTime.parse(event_edit[0]['toD']);
      _selectedVal = event_edit[0]['category'];
      _selectedPriority = event_edit[0]['priority'];
      _selectedStatus = event_edit[0]['status'];
      print(_selectedStatus);
      taskController.text = event_edit[0]['task'];
      durationController.text = event_edit[0]['duration'];
      _selectedRecurring = event_edit[0]['recurringOpt'];
      recurringController.text = event_edit[0]['recurringEvery'];
      remarkController.text = event_edit[0]['remark'];
      recurringDate = DateTime.parse(event_edit[0]['recurringUntil']);

      if (event_edit[0]['completeDate'] != null) {
        completeDate = DateTime.parse(event_edit[0]['completeDate']);
      }
    });
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

  Future<void> updateEvent(int recurringId) async {
    final isValid = _formkey.currentState!.validate();

    if (isValid) {
      final event = Event(
          recurringId: recurringId,
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

      await dbHelper.updateEvent(event);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated Successfully!"),
        ),
      );

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Recurring()),
      );
    }
  }

  Future<void> removeEvent(int recurring_Id) async {
    await dbHelper.deleteEvent(recurring_Id);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
    ));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Recurring()),
    );
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
                      durationDay: int.parse(durationController.text) - 1);
                },
              ),
            ),
          ),
        ],
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

              if (_selectedStatus == 'Done') {
                setState(() {
                  completeDate = DateTime.now();
                });
              }
            },
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.black,
            ),
          ),
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
              boxShadow: const [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Edit Task",
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
                    userPrio(),
                    const Text(
                      "Recurring :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 20, top: 5),
                      child: Text(
                        "*****$_selectedRecurring*****",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all<EdgeInsets>(
                        const EdgeInsets.all(10),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                    ),
                    onPressed: () {
                      removeEvent(recurringId);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFd4dce4),
                          fontWeight: FontWeight.w700),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(10),
                              side: const BorderSide(
                                width: 3.0,
                                color: Color(0xFF60b4b4),
                              ),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF60b4b4),
                                fontWeight: FontWeight.w700),
                          )),
                    ),
                    TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.all(10),
                          ),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF60b4b4)),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0))),
                        ),
                        onPressed: () {
                          updateEvent(recurringId);
                        },
                        child: const Text(
                          "Update",
                          style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFFd4dce4),
                              fontWeight: FontWeight.w700),
                        )),
                  ],
                ),
              ],
            ),
          ]))
    ]);
  }
}
