import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ipsolution/model/selection.dart';
import 'package:ipsolution/util/selection.dart';
import 'package:multiselect/multiselect.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/manageUser.dart';
import '../../model/nonRecurring.dart';
import '../../util/checkInternet.dart';
import '../../util/datetime.dart';
import '../non_recurring.dart';

class editNonRecurring extends StatefulWidget {
  final String id;
  const editNonRecurring({super.key, required this.id});

  @override
  State<editNonRecurring> createState() => _editNonRecurringState();
}

late List<dynamic> user = [];
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

class _editNonRecurringState extends State<editNonRecurring> {
  final _formkey = GlobalKey<FormState>();
  DateTime? due;
  DateTime startDate = DateTime.now();
  String _selectedVal = '';
  String _selectedUser = '';
  String _selectedSite = '';
  String _selectedType = '';
  DateTime? completeDate;
  DateTime? modify;
  List<Map<String, dynamic>> nonRecurring_edit = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  List<String> siteList = <String>[];

  List<String> checkUserList = [];
  List<String> _selectedCheckUser = [];
  var selectedCheckUser = ''.obs;
  bool check = false;
  List<int> userid = [];
  List categoryData = [];
  List<TypeSelect> typeList = <TypeSelect>[];
  TypeSelect? typeselect;
  dynamic _selectedCategory;
  String? _selectedSubCategory;
  List _selectedData = [];
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final SharedPreferences sp = await _pref;
      List functionAccess = sp.getString("position")!.split(",");
      String userRole = sp.getString("role")!;
      final typeOptions =
          await Selection().typeSelection(functionAccess, userRole);
      categoryData =
          await Selection().categorySelection(functionAccess, userRole);

      //type selection
      setState(() async {
        List typeDate = [];
        typeDate = typeOptions;
        for (int i = 0; i < typeDate.length; i++) {
          typeList.add(TypeSelect(
              id: typeDate[i]['id'],
              value: typeDate[i]['value'],
              bold: typeDate[i]['bold']));
        }
        await getDataDetails(int.parse(widget.id));

        for (final val in typeList) {
          if (val.value == _selectedType) {
            setState(() {
              typeselect = val;
            });

            break;
          }
        }

        for (final item in categoryData) {
          // print(item['value']);
          if (item['bold'] == false &&
              item['value']['department'] == _selectedData[1] &&
              item['value']['variables'] == _selectedData[0]) {
            _selectedCategory = item['value'];
          }
        }
      });
    });

    super.initState();
  }

  Future<void> getDataDetails(int id) async {
    nonRecurring_edit = await dbHelper.fetchANonRecurring(id);
    final data = await dbHelper.getItems();
    var url = 'http://192.168.1.111/testdb/read.php';
    var response =
        await http.post(Uri.parse(url), body: {"tableName": "user_details"});

    List userData = json.decode(response.body);
    final siteOptions = await Selection().siteSelection();

    setState(() {
      //site options
      for (final val in siteOptions) {
        siteList = val["options"];
      }

      for (int i = 0; i < data.length; i++) {
        if (data[i]["role"] != "Staff") {
          checkUserList.add(data[i]["user_name"]);
        }
      }

      if (nonRecurring_edit[0]['checked'] != '-' &&
          nonRecurring_edit[0]['personCheck'] != '-') {
        check = true;
      }

      user = userData;

      _selectedData = nonRecurring_edit[0]['category'].split("|");
      _selectedSubCategory = nonRecurring_edit[0]['subCategory'];
      _selectedType = nonRecurring_edit[0]['type'];
      _selectedSite = nonRecurring_edit[0]['site'];
      _selectedUser = nonRecurring_edit[0]['owner'];
      statusController.text = nonRecurring_edit[0]['status'];
      taskController.text = nonRecurring_edit[0]['task'];
      remarkController.text = nonRecurring_edit[0]['remark'];
      due = DateTime.parse(nonRecurring_edit[0]['due']);

      if (nonRecurring_edit[0]['personCheck'] != '-') {
        _selectedCheckUser = nonRecurring_edit[0]['personCheck'].split(",");
      }
      if (nonRecurring_edit[0]['completeDate'] != null &&
          nonRecurring_edit[0]['completeDate'].isNotEmpty) {
        completeDate = DateTime.parse(nonRecurring_edit[0]['completeDate']);
      }
      if (nonRecurring_edit[0]['startDate'] != null &&
          nonRecurring_edit[0]['startDate'].isNotEmpty) {
        startDate = DateTime.parse(nonRecurring_edit[0]['startDate']);
      }

      if (nonRecurring_edit[0]['modify'] != null &&
          nonRecurring_edit[0]['modify'].isNotEmpty) {
        modify = DateTime.parse(nonRecurring_edit[0]['modify']);
      }

      // for (final val in categoryData) {
      //   print(val['value']);
      //   if (val['value']['variable'] == _selectedData[0] &&
      //       val['value'] == _selectedData[1]) {}
      // }

      // for (int i = 0; i < userData.length; i++) {
      //   if (_selectedUser != userData[i]["username"]) {
      //     user.add({
      //       'userId': userData[i]["id"],
      //       'username': userData[i]["username"]
      //     });
      //   }
      // }
    });
  }

  Future pickDueDate() async {
    final duepicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (duepicked != null) {
      setState(() {
        due = duepicked;
      });
    }
  }

  Future pickStartDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future pickCompleteDate() async {
    final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));

    if (picked != null) {
      setState(() {
        completeDate = picked;
      });
    }
  }

  Future updateNonRecurring(int id) async {
    final isValid = _formkey.currentState!.validate();

    if (statusController.text.toString() == '100') {
      setState(() {
        completeDate = DateTime.now();
      });
    }

    if (isValid) {
      var url = 'http://192.168.1.111/testdb/edit.php';
      // final nonrecurring = nonRecurring(
      //     nonRecurringId: id,
      //     category: _selectedVal,
      //     subCategory: _selectedVal,
      //     type: _selectedVal,
      //     site: _selectedSite,
      //     task: taskController.text,
      //     owner: _selectedUser,
      //     startDate: startDate.toString(),
      //     due: due.toString(),
      //     modify: DateTime.now().toString(),
      //     remark: remarkController.text,
      //     completeDate: completeDate.toString(),
      //     status: statusController.text);

      // await dbHelper.updateNonRecurring(nonrecurring);

      Map<String, dynamic> data = {
        "dataTable": "nonrecurring",
        "nonRecurringId": id.toString(),
        "category": _selectedCategory["variables"] +
            "|" +
            _selectedCategory["department"],
        "subCategory": _selectedSubCategory,
        "type": _selectedType,
        "site": _selectedSite,
        "task": taskController.text,
        "owner": _selectedUser,
        "startDate": DateFormat("yyyy-MM-dd").format(startDate).toString(),
        "due": DateFormat("yyyy-MM-dd").format(due!).toString(),
        "modify": DateFormat("yyyy-MM-dd").format(DateTime.now()).toString(),
        "remark": remarkController.text,
        "completeDate": completeDate != null
            ? DateFormat("yyyy-MM-dd").format(completeDate!).toString()
            : '',
        "status": statusController.text
      };
      print(data);

      final response = await http.post(Uri.parse(url), body: data);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Updated Successfully!"),
          ),
        );
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NonRecurring()),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Updated Unsuccessful !")));
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

    Widget buildTextField(String labelText, String placeholder,
        TextEditingController? controllerText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: TextFormField(
                maxLines: labelText == "Task" ? 8 : null,
                cursorColor: Colors.black,
                style: const TextStyle(fontSize: 14),
                keyboardType:
                    labelText == "Status" ? TextInputType.number : null,
                decoration: InputDecoration(hintText: placeholder),
                onFieldSubmitted: (_) {},
                controller: controllerText,
                validator: labelText != "Remark"
                    ? (data) {
                        return data != null && data.isEmpty
                            ? 'Field cannot be empty'
                            : null;
                      }
                    : null),
          ),
        ],
      );
    }

    Widget dropdownList(String labelText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelText,
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                    ? _selectedCategory['options']
                            .contains(_selectedSubCategory)
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
          ),
        ],
      );
    }

    Widget dropdownCategory() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Category',
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)))
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
          ),
        ],
      );
    }

    Widget dropdownType() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Type',
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                value: typeselect != null ? typeselect : null,
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
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : DropdownMenuItem<TypeSelect>(
                          value: e,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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
          ),
        ],
      );
    }

    Widget dropdownSite() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Site',
            style: const TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
          ),
        ],
      );
    }

    Widget dropdownOwner() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Owner",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
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
                value: _selectedUser == '' ? null : _selectedUser,
                selectedItemHighlightColor: Colors.grey,
                validator: (value) {
                  return value == null ? 'Please select' : null;
                },
                items: List.generate(
                  user.length,
                  (index) => DropdownMenuItem(
                    value: user[index]["username"].toString(),
                    child: Text(
                      user[index]["username"].toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                onChanged: (val) {
                  String test = val as String;
                  setState(() {
                    _selectedUser = test;
                  });
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      );
    }

    Widget checkRequest() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text(
                "Required Checking?",
                style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
              ),
              Gap(10),
              Container(
                padding: EdgeInsets.all(0),
                width: 14,
                height: 14,
                color: Colors.white,
                child: Checkbox(
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                  value: check,
                  onChanged: (value) {
                    setState(() {
                      check = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: check == true ? Color(0xFFd4dce4) : Colors.grey),
            child: DropdownButtonHideUnderline(
              child: DropDownMultiSelect(
                enabled: check == true ? true : false,
                decoration: InputDecoration(border: InputBorder.none),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
                ),
                options: checkUserList,

                // whenEmpty: 'Select position',
                onChanged: (value) {
                  setState(() {
                    _selectedCheckUser = value;
                    selectedCheckUser.value = "";

                    _selectedCheckUser.forEach((element) {
                      selectedCheckUser.value =
                          selectedCheckUser.value + "  " + element;
                    });

                    // if (selectedPosition.isNotEmpty) {
                    //   checkFunctionAccess = true;
                    // }
                  });
                },
                selectedValues: _selectedCheckUser,
              ),
            ),
          ),
        ],
      );
    }

    Widget deadlineSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Deadline",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: ListTile(
              title: Text(
                due == null ? 'dd/mm/yy' : Utils.toDate(due!),
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                pickDueDate();
              },
            ),
          ),
        ],
      );
    }

    Widget createdOn() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Created On",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Text(
            "( autofill )",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFd4dce4)),
            child: ListTile(
              title: Text(
                startDate == null ? 'dd/mm/yy' : Utils.toDate(startDate),
                style: const TextStyle(fontSize: 14),
              ),
              trailing: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                pickStartDate();
              },
            ),
          ),
        ],
      );
    }

    Widget completedDateSelect() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Completed Date",
            style: TextStyle(color: Color(0xFFd4dce4), fontSize: 14),
          ),
          const Text(
            "( autofill when status = 100 )",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Gap(10),
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                Icons.arrow_drop_down,
                color: Colors.black,
                size: 30,
              ),
              onTap: () {
                pickCompleteDate();
              },
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
              child: Column(children: <Widget>[
                dropdownCategory(),
                dropdownList("Sub-Category"),
                dropdownType(),
                dropdownSite(),
                buildTextField("Task", "description", taskController),
                dropdownOwner(),
                deadlineSelect(),
                buildTextField("Status", "0", statusController),
                buildTextField(
                    "Remark", "Additional Remark...", remarkController),
                Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.all(20.0),
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.white)),
                    child: Column(
                      children: [
                        createdOn(),
                        completedDateSelect(),
                        checkRequest()
                      ],
                    )),
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
                        await updateNonRecurring(int.parse(widget.id));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No Internet !")));
                      }
                    });
                  },
                  child: const Text(
                    "Update",
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
