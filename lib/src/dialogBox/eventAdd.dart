// ignore: file_names
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/event.dart';
import 'package:ipsolution/src/recurrring.dart';

import 'package:ipsolution/util/recurringTasks.dart';
import 'package:multiselect/multiselect.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../model/selection.dart';

import '../../util/checkInternet.dart';
import '../../util/conMysql.dart';
import '../../util/datetime.dart';
import 'package:http/http.dart' as http;

import '../../util/selection.dart';

class EventAdd extends StatefulWidget {
  final Event? event;
  const EventAdd({Key? key, this.event}) : super(key: key);
  @override
  State<EventAdd> createState() => _EventAddState();
}

Future<SharedPreferences> _pref = SharedPreferences.getInstance();
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class _EventAddState extends State<EventAdd> {
  final taskController = TextEditingController();
  final durationController = TextEditingController();
  final recurringController = TextEditingController();
  final remarkController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  double _animatedHeight = 0.0;
  late DateTime fromDate = DateTime.now();
  late DateTime toDate;
  DateTime? recurringDate;
  DateTime? completeDate;

  bool checkDuration = true;
  List<String> _selectedUser = [];
  String _selectedPriority = '';
  String _selectedStatus = 'Upcoming';
  String _selectedRecurring = '';
  String _selectedSite = '';
  var rng = Random();
  List<String> siteList = <String>[];
  List<Map<String, dynamic>> category = [];
  List<String> priorityList = <String>['Low', 'Moderate', 'High'];
  List<String> statusList = <String>['Upcoming', 'In Progress', 'Done'];
  List<String> recurringOption = <String>[
    'Once',
    'Daily',
    'Weekly',
    'Monthly',
    'Yearly'
  ];
  List<String> userList = [];
  bool checkUser = false;
  DbHelper dbHelper = DbHelper();
  var selectedOption = ''.obs;
  bool isTapped = false;
  List categoryData = [];
  String userPosition = '';

  TypeSelect? typeselect;
  List<TypeSelect> typeList = <TypeSelect>[];

  dynamic _selectedCategory;
  String? _selectedSubCategory;
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      final SharedPreferences sp = await _pref;
      String userRole = sp.getString("role")!;
      List functionAccess = sp.getString("position")!.split(",");
      final typeOptions =
          await Selection().typeSelection(functionAccess, userRole);
      categoryData =
          await Selection().categorySelection(functionAccess, userRole);
      userPosition = sp.getString("position")!;
      //type selection
      List typeDate = [];
      typeDate = typeOptions;

      for (int i = 0; i < typeDate.length; i++) {
        typeList.add(TypeSelect(
            id: typeDate[i]['id'],
            value: typeDate[i]['value'],
            bold: typeDate[i]['bold']));
      }

      getData();
    });

    setState(() {
      fromDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 9, 00);
      toDate = DateTime(fromDate.year, fromDate.month, fromDate.day, 17, 30);
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    durationController.dispose();
    recurringController.dispose();
    remarkController.dispose();

    super.dispose();
  }

  Future<void> getData() async {
    final data = await dbHelper.getItems();
    final SharedPreferences sp = await _pref;

    String user = sp.getString("user_name")!;
    String userRole = sp.getString("role")!;
    String currentUserSiteLead = sp.getString("siteLead")!;

    final siteOptions = await Selection().siteSelection();

    setState(() {
      userList = [];
      for (final val in siteOptions) {
        siteList = val["options"];
      }

      //

      // get person List
      _selectedUser.add(user);
      for (int i = 0; i < data.length; i++) {
        List positionList = data[i]["position"].split(",");
        List siteList = data[i]["site"].split(",");

        if (userRole == "Manager" || userRole == "Super Admin") {
          userList.add(data[i]["user_name"]);
        } else if (userRole == "Leader" && currentUserSiteLead != "-") {
          for (int y = 0; y < siteList.length; y++) {
            if ((data[i]["role"] == "Leader" || data[i]["role"] == "Staff") &&
                siteList[y] == currentUserSiteLead) {
              userList.add(data[i]["user_name"]);
            }
          }
        } else {
          for (int y = 0; y < positionList.length; y++) {
            for (int x = 0; x < functionData.length; x++) {
              if (positionList[y] == functionData[x] &&
                  (data[i]["role"] == "Leader" || data[i]["role"] == "Staff")) {
                if (userList.contains(data[i]['user_name'])) {
                } else {
                  userList.add(data[i]["user_name"]);
                }
              }
            }
          }
        }
      }

      //
    });
  }

  Future<void> pickRecurringDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: fromDate,
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
    var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/add.php';
    final isValid = _formkey.currentState!.validate();
    final SharedPreferences sp = await _pref;
    String currentUsername = sp.getString("user_name")!;
    String? color;

    if (isValid) {
      String selectedUser = _selectedUser.join(",");

      if (_selectedPriority == "Low") {
        color = "lightgreen";
      } else if (_selectedPriority == "Moderate") {
        color = "palegoldenrod";
      } else if (_selectedPriority == "High") {
        color = "lightcoral";
      }

      if (_selectedUser.isNotEmpty && _selectedUser != null) {
        for (var item in _selectedUser) {
          if (item != currentUsername) {
            Map<String, dynamic> notificationData = {
              "dataTable": "notification",
              'owner': item,
              'assigner': currentUsername,
              'type': "Recurring",
              'task': taskController.text,
              'deadline': _selectedRecurring,
              'noted': "No",
            };
            await http.post(Uri.parse(url), body: notificationData);
          }
        }
      }

      // get the correct toDate again ( to prevent user didnt click the end time )
      DateTime to_date =
          DateTime(fromDate.year, fromDate.month, fromDate.day).add(
        Duration(
          days: int.parse(durationController.text) - 1,
        ),
      );
      toDate = to_date.add(
        Duration(hours: toDate.hour, minutes: toDate.minute),
      );

      // recurring multiple tasks generate
      String rule = Rule().recurringRule(_selectedRecurring, recurringDate,
          recurringController.text, fromDate, toDate, durationController.text);

      List<DateTime> _startDate =
          SfCalendar.getRecurrenceDateTimeCollection(rule, fromDate);

      // for (int i = 0; i < _startDate.length; i++) {
      //   DateTime end_date =
      //       DateTime(_startDate[i].year, _startDate[i].month, _startDate[i].day)
      //           .add(
      //     Duration(
      //       days: int.parse(durationController.text) - 1,
      //     ),
      //   );
      //   DateTime endtime = end_date.add(
      //     Duration(hours: toDate.hour, minutes: toDate.minute),
      //   );

      //   final event = Event(
      //       category: _selectedCategory["variables"] +
      //           "|" +
      //           _selectedCategory["department"],
      //       subCategory: _selectedSubCategory!,
      //       type: typeselect!.value,
      //       site: _selectedSite,
      //       task: taskController.text,
      //       from: _startDate[i].toString(),
      //       to: endtime.toString(),
      //       person: selectedUser,
      //       // rule: 'FREQ=DAILY;INTERVAL=1;COUNT=20',
      //       // backgroundColor: calendarColor.toString(),
      //       duration: durationController.text,
      //       priority: _selectedPriority,
      //       recurringOpt: _selectedRecurring,
      //       color: color!,
      //       recurringEvery: recurringController.text.isEmpty
      //           ? '0'
      //           : recurringController.text,
      //       recurringUntil: recurringDate.toString(),
      //       remark: remarkController.text,
      //       completeDate: completeDate.toString(),
      //       status: _selectedStatus);

      //   await dbHelper.addEvent(event);
      // }
      // Navigator.pop(context);

      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (context) => const Recurring()));

      var url_add =
          'https://ipsolutions4u.com/ipsolutions/recurringMobile/add.php';
      int dependent_code = rng.nextInt(900000000) + 100000000;

      const availableChars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final unique_code = List.generate(
              6, (index) => availableChars[rng.nextInt(availableChars.length)])
          .join();

      var response;
      for (int i = 0; i < _startDate.length; i++) {
        DateTime end_date =
            DateTime(_startDate[i].year, _startDate[i].month, _startDate[i].day)
                .add(
          Duration(
            days: int.parse(durationController.text) - 1,
          ),
        );
        DateTime endtime = end_date.add(
          Duration(hours: toDate.hour, minutes: toDate.minute),
        );

        Map<String, dynamic> data = {
          "dataTable": "tasks",
          "category": _selectedCategory["variables"] +
              "|" +
              _selectedCategory["department"],
          "subCategory": _selectedSubCategory,
          "type": typeselect!.value,
          "site": _selectedSite,
          "task": taskController.text,
          "start": _startDate[i].toString(),
          "end": endtime.toString(),
          "date": DateFormat("y-M-d").format(_startDate[i]).toString(),
          "deadline": DateFormat("y-M-d").format(endtime).toString(),
          "startTime": DateFormat.Hm().format(_startDate[i]).toString(),
          "dueTime": DateFormat.Hm().format(endtime).toString(),
          "person": selectedUser,
          "duration": durationController.text,
          "priority": _selectedPriority,
          "color": color,
          // "startDate": DateFormat("yyyy-MM-dd").format(startDate).toString(),
          // "deadline": DateFormat("yyyy-MM-dd").format(due!).toString(),
          "recurringOpt": _selectedRecurring,
          "recurringEvery":
              recurringController.text.isEmpty ? '0' : recurringController.text,
          // "modify": DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
          "remark": remarkController.text,
          "uniqueNumber": unique_code.toString(),
          "dependent": dependent_code.toString(),
          "completeDate": completeDate != null
              ? DateFormat("yyyy-MM-dd").format(completeDate!).toString()
              : '',

          "status": _selectedStatus,
        };

        response = await http.post(Uri.parse(url_add), body: data);
      }
      if (response.statusCode == 200) {
        if (!mounted) return;

        FocusScope.of(context).requestFocus(FocusNode());
        await Internet.isInternet().then((connection) async {
          if (connection) {
            EasyLoading.show(
              status: 'Adding and Loading Data...',
              maskType: EasyLoadingMaskType.black,
            );
            await Controller().addRecurringToSqlite();
            if (!mounted) return;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Recurring()),
            );
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text("Event has been added."),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              action: SnackBarAction(
                label: 'Dismiss',
                disabledTextColor: Colors.white,
                textColor: Colors.blue,
                onPressed: () {
                  //Do whatever you want
                },
              ),
            ));
            EasyLoading.showSuccess('Successfully');
          }
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text("Adding Unsuccessful !"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(20),
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.blue,
            onPressed: () {
              //Do whatever you want
            },
          ),
        ));
      }
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
    Widget categoryDropdown() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<dynamic>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: _selectedCategory,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: [
              for (final item in categoryData)
                item["bold"] == true
                    ? DropdownMenuItem(
                        enabled: false,
                        child: Text(item['value'],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)))
                    : DropdownMenuItem(
                        value: item['value'],
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(item['value']['variables']),
                        ))
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
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

    Widget subCategoryDropdown() {
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
            value: _selectedCategory != null
                ? _selectedCategory['options'].contains(_selectedSubCategory)
                    ? _selectedSubCategory
                    : null
                : null,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: _selectedCategory != null
                ? [
                    for (final item in _selectedCategory['options'])
                      DropdownMenuItem(value: item, child: Text(item))
                  ]
                : [],
            onChanged: (val) {
              setState(() {
                _selectedSubCategory = val;
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

    Widget typeDropdown() {
      return Container(
        margin: const EdgeInsets.only(bottom: 30),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xFFd4dce4)),
        child: DropdownButtonHideUnderline(
          child: DropdownButtonFormField2<TypeSelect>(
            iconSize: 30,
            isExpanded: true,
            hint: const Text("Choose item"),
            value: typeselect,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: typeList.map((TypeSelect e) {
              return e.bold == "true"
                  ? DropdownMenuItem<TypeSelect>(
                      enabled: false,
                      child: Text(
                        e.value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : DropdownMenuItem<TypeSelect>(
                      value: e,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          e.value,
                        ),
                      ),
                    );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                typeselect = newValue!;
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

    Widget userTotal() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: DropdownButtonHideUnderline(
              child: DropDownMultiSelect(
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),

                options: userList,

                // whenEmpty: 'Select position',
                onChanged: (value) {
                  setState(() {
                    _selectedUser = value;
                    selectedOption.value = "";

                    for (var element in _selectedUser) {
                      selectedOption.value =
                          "${selectedOption.value}  $element";
                    }
                  });
                },
                selectedValues: _selectedUser,
              ),
            ),
          ),
        ],
      );
    }

    Widget userSite() {
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
            value: _selectedSite == '' ? null : _selectedSite,
            selectedItemHighlightColor: Colors.grey,
            validator: (value) {
              return value == null ? 'Please select' : null;
            },
            items: siteList
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
                _selectedSite = test;
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
            selectedItemHighlightColor: Colors.grey,
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
            selectedItemHighlightColor: Colors.grey,
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
            selectedItemHighlightColor: Colors.grey,
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
              boxShadow: const [
                BoxShadow(
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
                    categoryDropdown(),
                    const Text(
                      "Sub-Category :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    subCategoryDropdown(),
                    const Text(
                      "Type :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    typeDropdown(),
                    const Text(
                      "Site :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userSite(),
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
                      "Person :",
                      style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
                    ),
                    const Gap(10),
                    userTotal(),
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
                  onPressed: () async {
                    await Internet.isInternet().then((connection) async {
                      if (connection) {
                        if (!isTapped) {
                          isTapped = true;
                          await saveEvent();
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("No Internet !"),
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(20),
                          action: SnackBarAction(
                            label: 'Dismiss',
                            disabledTextColor: Colors.white,
                            textColor: Colors.blue,
                            onPressed: () {
                              //Do whatever you want
                            },
                          ),
                        ));
                      }
                    });
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
