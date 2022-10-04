import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/addtional/dialogbox.dart';
import 'package:ipsolution/src/navbar.dart';

import '../util/app_styles.dart';

class Member extends StatefulWidget {
  Member({super.key});

  @override
  State<Member> createState() => _MemberState();
}

int totalMember = 30;

class _MemberState extends State<Member> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentSortColumn = 0;

  bool _isAscending = true;

  bool selected = false;

  final List<Map> _products = List.generate(30, (i) {
    return {"id": i, "name": "User $i", "role": "Staff"};
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: Container(
            margin: EdgeInsets.only(
                top: height * 0.08, left: width * 0.02, right: width * 0.02),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () => scaffoldKey.currentState!.openDrawer(),
                  ),
                  Text("Member", style: Styles.title),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.black),
                    onPressed: () => {},
                  ),
                ],
              ),
              const Gap(20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      totalMember.toString() + " Member",
                      style: Styles.subtitle,
                    ),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: TextFormField(
                        initialValue: '',
                        style: const TextStyle(color: Colors.black),
                        cursorColor: Colors.black,
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
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        // onChanged: onSearch,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(5),
              Expanded(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: SizedBox(
                      width: width * 0.98,
                      child: SingleChildScrollView(
                        child: DataTable(
                          showCheckboxColumn: false,
                          sortColumnIndex: _currentSortColumn,
                          sortAscending: _isAscending,
                          headingRowColor:
                              MaterialStateProperty.all(Styles.buttonColor),
                          columns: [
                            DataColumn(
                                label: Text(
                                  'User',
                                  style: TextStyle(
                                      color: Styles.textColor,
                                      fontWeight: FontWeight.w700),
                                ),
                                // Sorting function
                                onSort: (columnIndex, _) {
                                  setState(() {
                                    _currentSortColumn = columnIndex;
                                    if (_isAscending == true) {
                                      _isAscending = false;
                                      // sort the product list in Ascending, order by Price
                                      _products.sort((productA, productB) =>
                                          productB['id']
                                              .compareTo(productA['id']));
                                    } else {
                                      _isAscending = true;
                                      // sort the product list in Descending, order by Price
                                      _products.sort((productA, productB) =>
                                          productA['id']
                                              .compareTo(productB['id']));
                                    }
                                  });
                                }),
                            DataColumn(
                                label: Text(
                                  'Username',
                                  style: TextStyle(
                                      color: Styles.textColor,
                                      fontWeight: FontWeight.w700),
                                ),
                                // Sorting function
                                onSort: (columnIndex, _) {
                                  setState(() {
                                    _currentSortColumn = columnIndex;
                                    if (_isAscending == true) {
                                      _isAscending = false;
                                      // sort the product list in Ascending, order by Price
                                      _products.sort((productA, productB) =>
                                          productB['name']
                                              .compareTo(productA['name']));
                                    } else {
                                      _isAscending = true;
                                      // sort the product list in Descending, order by Price
                                      _products.sort((productA, productB) =>
                                          productA['name']
                                              .compareTo(productB['name']));
                                    }
                                  });
                                }),
                            DataColumn(
                                label: Text(
                                  'Role',
                                  style: TextStyle(
                                      color: Styles.textColor,
                                      fontWeight: FontWeight.w700),
                                ),
                                // Sorting function
                                onSort: (columnIndex, _) {
                                  setState(() {
                                    _currentSortColumn = columnIndex;
                                    if (_isAscending == true) {
                                      _isAscending = false;
                                      // sort the product list in Ascending, order by Price
                                      _products.sort((productA, productB) =>
                                          productB['role']
                                              .compareTo(productA['role']));
                                    } else {
                                      _isAscending = true;
                                      // sort the product list in Descending, order by Price
                                      _products.sort((productA, productB) =>
                                          productA['role']
                                              .compareTo(productB['role']));
                                    }
                                  });
                                }),
                          ],
                          rows: _products.map((item) {
                            return DataRow(
                                cells: [
                                  DataCell(Text(item['id'].toString())),
                                  DataCell(Text(item['name'])),
                                  DataCell(Text(item['role'].toString()))
                                ],
                                onSelectChanged: (e) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DialogBox(
                                          id: item['id'].toString(),
                                          name: item['name'].toString(),
                                          role: item['role'].toString(),
                                        );
                                      });
                                });
                          }).toList(),
                        ),
                      ),
                    )),
              ),
            ])));
  }
}