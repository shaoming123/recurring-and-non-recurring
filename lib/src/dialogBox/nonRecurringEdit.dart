import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../model/manageUser.dart';
import '../../model/nonRecurring.dart';
import '../../util/datetime.dart';
import '../non_recurring.dart';

class editNonRecurring extends StatefulWidget {
  final String id;
  const editNonRecurring({super.key, required this.id});

  @override
  State<editNonRecurring> createState() => _editNonRecurringState();
}

class _editNonRecurringState extends State<editNonRecurring> {
  final _formkey = GlobalKey<FormState>();
  DateTime due = DateTime.now();
  DateTime startDate = DateTime.now();
  String _selectedVal = '';
  String _selectedUser = '';
  String _selectedSite = '';
  DateTime? completeDate;
  DateTime? modify;
  List<Map<String, dynamic>> nonRecurring_edit = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  List<String> list = <String>['One', 'Two', 'Three', 'Four'];
  List<String> siteList = <String>[
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
  List<dynamic> user = [];
  List<int> userid = [];
  @override
  void initState() {
    super.initState();

    getDataDetails(int.parse(widget.id));
    getUserData();
  }

  Future<void> getDataDetails(int id) async {
    nonRecurring_edit = await dbHelper.fetchANonRecurring(id);

    setState(() {
      startDate = DateTime.parse(nonRecurring_edit[0]['startDate']);
      due = DateTime.parse(nonRecurring_edit[0]['due']);
      modify = DateTime.parse(nonRecurring_edit[0]['modify']);
      _selectedVal = nonRecurring_edit[0]['category'];
      _selectedSite = nonRecurring_edit[0]['site'];
      _selectedUser = nonRecurring_edit[0]['owner'];
      statusController.text = nonRecurring_edit[0]['status'];
      taskController.text = nonRecurring_edit[0]['task'];
      remarkController.text = nonRecurring_edit[0]['remark'];

      if (nonRecurring_edit[0]['completeDate'] != null) {
        completeDate = DateTime.parse(nonRecurring_edit[0]['completeDate']);
      }
    });
  }

  Future<void> getUserData() async {
    final data = await dbHelper.getItems();
    setState(() {
      for (int i = 0; i < data.length; i++) {
        user.add(
            {'userId': data[i]["user_id"], 'username': data[i]["user_name"]});
      }
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
      final nonrecurring = nonRecurring(
          nonRecurringId: id,
          category: _selectedVal,
          subCategory: _selectedVal,
          type: _selectedVal,
          site: _selectedSite,
          task: taskController.text,
          owner: _selectedUser,
          startDate: startDate.toString(),
          due: due.toString(),
          modify: DateTime.now().toString(),
          remark: remarkController.text,
          completeDate: completeDate.toString(),
          status: statusController.text);

      await dbHelper.updateNonRecurring(nonrecurring);

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
                validator: (value) {
                  return value == null ? 'Please select' : null;
                },
                items: List.generate(
                  user.length,
                  (index) => DropdownMenuItem(
                    value: user[index]["userId"].toString(),
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
                due == null ? 'dd/mm/yy' : Utils.toDate(due),
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
                Utils.toDate(startDate),
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
                dropdownList("Category"),
                dropdownList("Sub-Category"),
                dropdownList("Type"),
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
                  onPressed: () {
                    updateNonRecurring(int.parse(widget.id));
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
