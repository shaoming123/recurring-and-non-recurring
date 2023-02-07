//@dart=2.9
import 'package:flutter/material.dart';

import 'package:gap/gap.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../model/eventDataSource.dart';
import '../../util/app_styles.dart';
import '../../util/checkInternet.dart';
import '../dialogBox/nonRecurringAdd.dart';
import '../dialogBox/nonRecurringEdit.dart';
import '../nonRecurringTask.dart';
import '../search/nonRecurring.dart';

class Task extends StatefulWidget {
  List<Map<String, dynamic>> foundNonRecurring;
  List<Map<String, dynamic>> latenonRecurring;
  List<Map<String, dynamic>> activenonRecurring;
  List<Map<String, dynamic>> completednonRecurring;

  Task({
    Key key,
    this.foundNonRecurring,
    this.latenonRecurring,
    this.activenonRecurring,
    this.completednonRecurring,
  }) : super(key: key);
  @override
  State<Task> createState() => _TaskState();
}

class _TaskState extends State<Task> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> foundNonRecurring;
  List<Map<String, dynamic>> latenonRecurring;
  List<Map<String, dynamic>> activenonRecurring;
  List<Map<String, dynamic>> completednonRecurring;
  String selectedUser = "";
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  TextEditingController textcontroller;
  double screenHeight;

  bool _isExpanded = false;
  AnimationController _animationController;
  double currentPageValue = 0;
  PageController controller = PageController();
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    textcontroller = TextEditingController();
    foundNonRecurring = widget.foundNonRecurring;
    latenonRecurring = widget.latenonRecurring;
    activenonRecurring = widget.activenonRecurring;
    completednonRecurring = widget.completednonRecurring;
    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });

    getUserId();
  }

  Future<void> getUserId() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      selectedUser = sp.getString("user_name");
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenHeight = MediaQuery.of(context).size.height;
  }

  int _curr = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> pageViewItem = <Widget>[
      page('Late', screenHeight, latenonRecurring),
      page('Active', screenHeight, activenonRecurring),
      page('Completed', screenHeight, completednonRecurring),
      page('All', screenHeight, foundNonRecurring),
      // page(screenHeight)
    ];

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Styles.bgColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isExpanded ? width / 1.5 : 50,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Styles.secondColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: 'Search...',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                List<List<Map<String, dynamic>>> results =
                                    Search().searchResult(
                                        value,
                                        widget.foundNonRecurring,
                                        widget.activenonRecurring,
                                        widget.latenonRecurring,
                                        widget.completednonRecurring);

                                setState(() {
                                  latenonRecurring = results[0];
                                  activenonRecurring = results[1];
                                  completednonRecurring = results[2];
                                  foundNonRecurring = results[3];
                                });
                              },
                            ))
                        : const Center(
                            child: Icon(
                              Icons.search,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                  ),
                ),
                const Gap(10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Styles.bgColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: (() {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return addNonRecurring(
                              userName: selectedUser, task: true);
                        });
                  }),
                  child: Ink(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Styles.secondColor,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Add Task",
                          style: TextStyle(
                              color: Styles.textColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              onPageChanged: (num) {
                setState(() {
                  _curr = num;
                });
              },
              children: pageViewItem,
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> deleteNonRecurring(String id, context) async {
  var url = 'https://ipsolutions4u.com/ipsolutions/recurringMobile/delete.php';
  final response = await http.post(Uri.parse(url), body: {
    "dataTable": "nonrecurring",
    "id": id,
  });
  if (response.statusCode == 200) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NonRecurring()),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted!'),
    ));
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text("Delete Unsuccessful !"),
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

Future<void> deleteItem(BuildContext context, String id) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Are you sure you want to delete this item?',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.red[600],
                      ),
                    ),
                    onPressed: () async {
                      await deleteNonRecurring(id, context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget page(label, screenHeight, nonRecurring) {
  return Container(
    color: Styles.bgColor,
    child: Container(
      decoration: BoxDecoration(
        color: Styles.secondColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      width: double.infinity,
      height: screenHeight,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    width: 20,
                    height: 20,
                    color: label == 'Late'
                        ? Styles.latedotColor
                        : label == 'Active'
                            ? Styles.activedotColor
                            : label == 'Completed'
                                ? Styles.completeddotColor
                                : Styles.alldotColor,
                  ),
                ),
                const Gap(10),
                Text(
                  "$label (${nonRecurring.length})",
                  style: Styles.subtitle,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
                child: Container(
              height: screenHeight / 1.8,
              margin: const EdgeInsets.only(left: 20, right: 20),
              padding: const EdgeInsets.only(bottom: 20),
              child: ListView.builder(
                itemCount: nonRecurring.length,
                itemBuilder: (BuildContext context, int index) {
                  final dayLeft = daysBetween(DateTime.now(),
                      DateTime.parse(nonRecurring[index]["deadline"]));
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          // ignore: prefer_const_constructors
                          offset:
                              const Offset(0, 2), // changes position of shadow
                        ),
                      ],
                    ),
                    child: nonRecurring.isNotEmpty
                        ? Column(
                            children: [
                              ExpansionTile(
                                leading: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                ),
                                title: Text(
                                  nonRecurring[index]['task'],
                                  // overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                trailing: Container(
                                    width: 90,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: dayLeft.isNegative
                                          ? Styles.lateColor
                                          : dayLeft == 0
                                              ? Styles.todayColor
                                              : Styles.activeColor,
                                    ),
                                    child: Center(
                                        child: dayLeft.isNegative
                                            ? Text(
                                                "${dayLeft.abs()} DAYS LATE",
                                                style: Styles.dayLeftLate,
                                              )
                                            : dayLeft == 0
                                                ? Text(
                                                    "DUE TODAY",
                                                    style: Styles.dayLeftToday,
                                                  )
                                                : Text(
                                                    "$dayLeft DAYS LEFT",
                                                    style: Styles.dayLeftActive,
                                                  ))),
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.all(10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.edit_outlined,
                                                  size: 20),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return editNonRecurring(
                                                        id: nonRecurring[index]
                                                                ["id"]
                                                            .toString(),
                                                      );
                                                    });
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20),
                                              onPressed: () async {
                                                await Internet.isInternet()
                                                    .then((connection) async {
                                                  if (connection) {
                                                    // await deleteNonRecurring(
                                                    //     nonRecurring[index]
                                                    //         ["id"],
                                                    //     context);

                                                    await deleteItem(
                                                        context,
                                                        nonRecurring[index]
                                                                ["id"]
                                                            .toString());
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(SnackBar(
                                                      content: const Text(
                                                          "No Internet !"),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      margin:
                                                          const EdgeInsets.all(
                                                              20),
                                                      action: SnackBarAction(
                                                        label: 'Dismiss',
                                                        disabledTextColor:
                                                            Colors.white,
                                                        textColor: Colors.blue,
                                                        onPressed: () {
                                                          //Do whatever you want
                                                        },
                                                      ),
                                                    ));
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        const Gap(10),
                                        buildField(
                                            'Category',
                                            nonRecurring[index]['category']
                                                .split("|")[0]),
                                        const Gap(20),
                                        buildField('Sub-Category	',
                                            nonRecurring[index]['subcategory']),
                                        const Gap(20),
                                        buildField('Type',
                                            nonRecurring[index]['type']),
                                        const Gap(20),
                                        buildField('Site',
                                            nonRecurring[index]['site']),
                                        const Gap(20),
                                        buildField('Due',
                                            nonRecurring[index]['deadline']),
                                        const Gap(20),
                                        buildField('Stages',
                                            nonRecurring[index]['status']),
                                        const Gap(20),
                                        buildField('Remark',
                                            nonRecurring[index]['remarks']),
                                        const Gap(20),
                                        buildField('Last Mod',
                                            nonRecurring[index]['lastMod']),
                                        const Gap(10),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        : const Text('No data found!'),
                  );
                },
              ),
            )),
          ),
        ],
      ),
    ),
  );
}

Widget buildField(String labelText, String content) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Container(
            width: 80, child: Text('$labelText:', style: Styles.label)),
      ),
      const Gap(10),
      Flexible(
        child: Container(
          width: 150,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
          ),
          child: Center(
              child: labelText != 'Stages'
                  ? Text(content, style: Styles.labelData)
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: LinearPercentIndicator(
                          barRadius: const Radius.circular(5),
                          // width: 100.0,
                          lineHeight: 50.0,
                          percent: double.parse(content) / 100,
                          backgroundColor: Colors.grey,
                          progressColor: Colors.blue,
                          center: Text(
                            content,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                    )),
        ),
      )
    ],
  );
}
