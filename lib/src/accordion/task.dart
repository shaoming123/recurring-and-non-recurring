import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:ipsolution/src/dialogBox/eventEdit.dart';
import 'package:ipsolution/util/app_styles.dart';

class Task extends StatefulWidget {
  final String title;
  final String content;

  const Task({Key? key, required this.title, required this.content})
      : super(key: key);
  @override
  _TaskState createState() => _TaskState();
}

class _TaskState extends State<Task> {
  List<String> type = <String>['Late', 'Active', 'Completed', 'All'];
  String _selectedVal = "Late";
  bool _showContent = true;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 8,
      margin: const EdgeInsets.all(10),
      child: Column(children: [
        ListTile(
          title: Text(
            "Task Overview",
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
          tileColor: Styles.buttonColor,
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
                          child: TextField(
                            // controller: textcontroller,
                            style: const TextStyle(color: Colors.black),
                            cursorColor: Colors.black,
                            // onChanged: (value) {
                            //   setState(() {
                            //     // _searchResult = value;
                            //   });
                            // },
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
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container()
      ]),
    );
  }
}
