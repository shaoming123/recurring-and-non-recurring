import 'package:badges/badges.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:ipsolution/src/dialogBox/eventAdd.dart';
import 'package:ipsolution/util/app_styles.dart';

class TeamTask extends StatefulWidget {
  const TeamTask({Key? key}) : super(key: key);
  @override
  State<TeamTask> createState() => _TeamTaskState();
}

final textcontroller = TextEditingController();
List<String> type = <String>['Late', 'Active', 'Completed', 'All'];
String _selectedVal = "Late";
bool _showContent = false;

class _TeamTaskState extends State<TeamTask> {
  double _animatedHeight = 0.0;
  bool showTable = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text(
            "Team Status Overview",
            style:
                TextStyle(color: Styles.textColor, fontWeight: FontWeight.w700),
          ),
          trailing: IconButton(
            icon: Icon(
                _showContent ? Icons.arrow_drop_up : Icons.arrow_drop_down),
            onPressed: () {
              setState(() {
                _showContent = !_showContent;
              });
            },
          ),
          tileColor: Color(0xFF88a4d4),
        ),
        _showContent
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Styles.bgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: 180,
                          height: 40,
                          child: TextFormField(
                            controller: textcontroller,
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            onChanged: (value) {
                              setState(() {
                                // _searchResult = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: "Search",
                              hintStyle: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                              isDense: true,
                              suffixIcon:
                                  const Icon(Icons.search, color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2.0,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  style: BorderStyle.none,
                                ),
                              ),
                              // filled: true,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: Styles.bgColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: (() {}),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Ink(
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Styles.bgColor,
                                ),
                                child: Center(
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
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 30, top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.blueGrey,
                              width: 1,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          iconSize: 30,
                          isExpanded: true,
                          value: _selectedVal,
                          items: type
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _animatedHeight = 85;
                            });
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      height: _animatedHeight,
                      color: Colors.transparent,
                      width: width,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.blueGrey,
                                width: 1,
                                style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2(
                              iconSize: 30.0,
                              isExpanded: true,
                              value: _selectedVal,
                              items: type
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  showTable = true;
                                });
                              },
                              icon: Visibility(
                                  visible:
                                      _animatedHeight != 0.0 ? true : false,
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                  ))),
                        ),
                      ),
                    ),
                    showTable
                        ? DefaultTabController(
                            length: 4,
                            child: SizedBox(
                              height: 500,
                              child: Column(
                                children: <Widget>[
                                  TabBar(
                                    indicatorColor: Styles.primaryColor,
                                    indicatorWeight: 3,
                                    padding: EdgeInsets.zero,
                                    indicatorPadding: EdgeInsets.zero,
                                    labelPadding: EdgeInsets.zero,
                                    labelStyle: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold),
                                    unselectedLabelStyle: const TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold),
                                    labelColor: Styles.primaryColor,
                                    unselectedLabelColor: Colors.black,
                                    tabs: <Widget>[
                                      Tab(
                                        icon: Badge(
                                          badgeColor: Colors.indigo,
                                          shape: BadgeShape.square,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          position: BadgePosition.topEnd(
                                              top: -12, end: -20),
                                          padding: const EdgeInsets.all(5),
                                          badgeContent: const Text(
                                            '0',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const Text("Late"),
                                        ),
                                      ),
                                      Tab(
                                        icon: Badge(
                                          badgeColor: Colors.indigo,
                                          shape: BadgeShape.square,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          position: BadgePosition.topEnd(
                                              top: -12, end: -20),
                                          padding: const EdgeInsets.all(5),
                                          badgeContent: const Text(
                                            '0',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const Text("Active"),
                                        ),
                                      ),
                                      Tab(
                                        icon: Badge(
                                          badgeColor: Colors.indigo,
                                          shape: BadgeShape.square,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          position: BadgePosition.topEnd(
                                              top: -12, end: -20),
                                          padding: const EdgeInsets.all(5),
                                          badgeContent: const Text(
                                            '0',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const Text("Completed"),
                                        ),
                                      ),
                                      Tab(
                                        icon: Badge(
                                          badgeColor: Colors.indigo,
                                          shape: BadgeShape.square,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          position: BadgePosition.topEnd(
                                              top: -12, end: -20),
                                          padding: const EdgeInsets.all(5),
                                          badgeContent: const Text(
                                            '0',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          child: const Text("All"),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: TabBarView(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: <Widget>[
                                        lateView(),
                                        activeView(),
                                        completeView(),
                                        allView(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
              )
            : Container()
      ]),
    );
  }

  Widget lateView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(Styles.buttonColor),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Task')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Sub-Category')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Stage')),
            DataColumn(label: Text('Days Left')),
            DataColumn(label: Text('Due')),
            DataColumn(label: Text('Remark')),
            DataColumn(label: Text('Last Mod.')),
            DataColumn(label: Text('Action')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
            DataRow(cells: [
              DataCell(Text('#101')),
              DataCell(Text('Dart Internals')),
              DataCell(Text('Alex Wick')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
          ]),
    );
  }

  Widget activeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(Styles.buttonColor),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Task')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Sub-Category')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Stage')),
            DataColumn(label: Text('Days Left')),
            DataColumn(label: Text('Due')),
            DataColumn(label: Text('Remark')),
            DataColumn(label: Text('Last Mod.')),
            DataColumn(label: Text('Action')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
            DataRow(cells: [
              DataCell(Text('#101')),
              DataCell(Text('Dart Internals')),
              DataCell(Text('Alex Wick')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
          ]),
    );
  }

  Widget completeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(Styles.buttonColor),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Task')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Sub-Category')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Stage')),
            DataColumn(label: Text('Days Left')),
            DataColumn(label: Text('Due')),
            DataColumn(label: Text('Remark')),
            DataColumn(label: Text('Last Mod.')),
            DataColumn(label: Text('Action')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
            DataRow(cells: [
              DataCell(Text('#101')),
              DataCell(Text('Dart Internals')),
              DataCell(Text('Alex Wick')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
          ]),
    );
  }

  Widget allView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateProperty.all(Styles.buttonColor),
          showCheckboxColumn: false,
          columns: const [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Task')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Sub-Category')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Site')),
            DataColumn(label: Text('Stage')),
            DataColumn(label: Text('Days Left')),
            DataColumn(label: Text('Due')),
            DataColumn(label: Text('Remark')),
            DataColumn(label: Text('Last Mod.')),
            DataColumn(label: Text('Action')),
          ],
          rows: const [
            DataRow(cells: [
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
            DataRow(cells: [
              DataCell(Text('#101')),
              DataCell(Text('Dart Internals')),
              DataCell(Text('Alex Wick')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
              DataCell(Text('#100')),
              DataCell(Text('Flutter Basics')),
              DataCell(Text('David John')),
            ]),
          ]),
    );
  }
}
