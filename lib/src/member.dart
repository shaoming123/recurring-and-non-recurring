//@dart=2.9
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/manageUser.dart';
import 'package:ipsolution/src/dialogBox/addMember.dart';
import 'package:ipsolution/src/dialogBox/memberDetails.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/app_styles.dart';
import 'appbar.dart';
import '../util/checkInternet.dart';
import '../util/cloneData.dart';

class Member extends StatefulWidget {
  const Member({
    Key key,
  }) : super(key: key);

  @override
  State<Member> createState() => _MemberState();
}

class _MemberState extends State<Member> {
  final Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> _foundUsers = [];
  final int _currentSortColumn = 0;

  final bool _isAscending = true;

  bool selected = false;
  String userRole = '';
  String searchString = "";
  bool isEditing;
  bool _isLoading = true;
  bool isSwitched = false;
  List<Map<String, dynamic>> usersFiltered = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  DbHelper dbHelper = DbHelper();
  Future _future;
  @override
  void initState() {
    super.initState();
    // Controller().syncdata();
    _future = _refreshUsers();
  }

  Future _refreshUsers() async {
    final SharedPreferences sp = await _pref;

    await Internet.isInternet().then((connection) async {
      if (connection) {
        await Controller().addDataToSqlite();
      }
    });

    final data = await dbHelper.getItems();

    setState(() {
      userRole = sp.getString("role");
      _isLoading = false;
      List _allUsers = data;
      for (var item in _allUsers) {
        if (item["user_id"] != sp.getInt("user_id")) {
          _foundUsers.add(item);
          allUsers.add(item);
        }
      }
    });

    return _foundUsers;
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = allUsers;
    } else {
      results = allUsers
          .where((user) =>
              user["user_name"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              user["password"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    setState(() {
      _foundUsers = results;
    });
  }

  Future<void> toggleSwitch(value, int id) async {
    String active = '';
    String tableName = "user_details";
    setState(() {
      if (value == true) {
        active = 'Active';
      } else {
        active = 'Deactive';
      }
    });

    final response = await Controller()
        .switchToggle(active, id.toString(), tableName, "active");

    if (response.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Updated Successfully!"),
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
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Member()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Styles.bgColor,
        key: scaffoldKey,
        drawer: const Navbar(), //set gobal key defined above
        body: SingleChildScrollView(
          child: Container(
              height: height - height * 0.08,
              margin: EdgeInsets.only(
                  top: height * 0.08, left: width * 0.02, right: width * 0.02),
              child: Column(children: [
                Appbar(title: "Member", scaffoldKey: scaffoldKey),
                const Gap(20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_foundUsers.length} Member",
                        style: Styles.subtitle,
                      ),
                      SizedBox(
                        width: 180,
                        height: 40,
                        child: TextFormField(
                          onChanged: (value) {
                            _runFilter(value);
                          },
                          controller: searchController,
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
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(5),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Expanded(
                        child: Container(
                            margin: const EdgeInsets.only(bottom: 10, top: 10),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                            ),
                            child: SizedBox(
                              width: width,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: FutureBuilder(
                                      future: _future,
                                      builder:
                                          (context, AsyncSnapshot snapshot) {
                                        return snapshot.hasData
                                            ? SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: DataTable(
                                                    showCheckboxColumn: false,
                                                    sortColumnIndex:
                                                        _currentSortColumn,
                                                    sortAscending: _isAscending,
                                                    headingRowColor:
                                                        MaterialStateProperty
                                                            .all(
                                                      const Color(0xFF88a4d4),
                                                    ),
                                                    columns: [
                                                      DataColumn(
                                                        label: Text(
                                                          'User',
                                                          style: TextStyle(
                                                              color: Styles
                                                                  .textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),

                                                        // Sorting function
                                                        // onSort: (columnIndex, _) {
                                                        //   setState(() {
                                                        //     _currentSortColumn = columnIndex;
                                                        //     if (_isAscending == true) {
                                                        //       _isAscending = false;
                                                        //       // sort the product list in Ascending, order by Price
                                                        //       _products.sort((productA,
                                                        //               productB) =>
                                                        //           productB['id'].compareTo(
                                                        //               productA['id']));
                                                        //     } else {
                                                        //       _isAscending = true;
                                                        //       // sort the product list in Descending, order by Price
                                                        //       _products.sort((productA,
                                                        //               productB) =>
                                                        //           productA['id'].compareTo(
                                                        //               productB['id']));
                                                        //     }
                                                        //   });
                                                        // }
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              'Username',
                                                              style: TextStyle(
                                                                  color: Styles
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                        // Sorting function
                                                        // onSort: (columnIndex, _) {
                                                        //   setState(() {
                                                        //     _currentSortColumn = columnIndex;
                                                        //     if (_isAscending == true) {
                                                        //       _isAscending = false;
                                                        //       // sort the product list in Ascending, order by Price
                                                        //       _products.sort((productA,
                                                        //               productB) =>
                                                        //           productB['name'].compareTo(
                                                        //               productA['name']));
                                                        //     } else {
                                                        //       _isAscending = true;
                                                        //       // sort the product list in Descending, order by Price
                                                        //       _products.sort((productA,
                                                        //               productB) =>
                                                        //           productA['name'].compareTo(
                                                        //               productB['name']));
                                                        //     }
                                                        //   });
                                                        // }
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              'Email',
                                                              style: TextStyle(
                                                                  color: Styles
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                              'Role',
                                                              style: TextStyle(
                                                                  color: Styles
                                                                      .textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      DataColumn(
                                                        label: Text(
                                                          'Action',
                                                          style: TextStyle(
                                                              color: Styles
                                                                  .textColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        // Sorting function
                                                      )
                                                    ],
                                                    rows: List.generate(
                                                        _foundUsers.length,
                                                        (index) {
                                                      return DataRow(
                                                          cells: [
                                                            DataCell(Center(
                                                                child: Text(
                                                                    (index + 1)
                                                                        .toString()))),
                                                            DataCell(Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Center(
                                                                child: Text(
                                                                    _foundUsers[
                                                                            index]
                                                                        [
                                                                        "user_name"]),
                                                              ),
                                                            )),
                                                            DataCell(Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Center(
                                                                child: Text(
                                                                  _foundUsers[
                                                                          index]
                                                                      ["email"],
                                                                ),
                                                              ),
                                                            )),
                                                            DataCell(Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Center(
                                                                child: Text(
                                                                  _foundUsers[
                                                                          index]
                                                                      ["role"],
                                                                ),
                                                              ),
                                                            )),
                                                            DataCell(Row(
                                                              children: [
                                                                IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .edit),
                                                                  onPressed:
                                                                      () {
                                                                    showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return DialogBox(
                                                                              id: _foundUsers[index]["user_id"].toString(),
                                                                              isEditing: true);
                                                                        });
                                                                  },
                                                                ),
                                                                IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .delete),
                                                                    onPressed:
                                                                        () async {
                                                                      await Internet
                                                                              .isInternet()
                                                                          .then(
                                                                              (connection) async {
                                                                        if (connection) {
                                                                          await removeUser(
                                                                              _foundUsers[index]["user_id"],
                                                                              context);
                                                                        } else {
                                                                          ScaffoldMessenger.of(context)
                                                                              .showSnackBar(SnackBar(
                                                                            content:
                                                                                const Text("No Internet !"),
                                                                            behavior:
                                                                                SnackBarBehavior.floating,
                                                                            margin:
                                                                                const EdgeInsets.all(20),
                                                                            action:
                                                                                SnackBarAction(
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
                                                                    }),
                                                                Switch(
                                                                  value: _foundUsers[index]
                                                                              [
                                                                              "active"] ==
                                                                          'Active'
                                                                      ? true
                                                                      : false,
                                                                  onChanged:
                                                                      ((value) async {
                                                                    await Internet
                                                                            .isInternet()
                                                                        .then(
                                                                            (connection) async {
                                                                      if (connection) {
                                                                        await toggleSwitch(
                                                                            value,
                                                                            _foundUsers[index]["user_id"]);
                                                                      } else {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(SnackBar(
                                                                          content:
                                                                              const Text("No Internet !"),
                                                                          behavior:
                                                                              SnackBarBehavior.floating,
                                                                          margin:
                                                                              const EdgeInsets.all(20),
                                                                          action:
                                                                              SnackBarAction(
                                                                            label:
                                                                                'Dismiss',
                                                                            disabledTextColor:
                                                                                Colors.white,
                                                                            textColor:
                                                                                Colors.blue,
                                                                            onPressed:
                                                                                () {
                                                                              //Do whatever you want
                                                                            },
                                                                          ),
                                                                        ));
                                                                      }
                                                                    });
                                                                  }),
                                                                  activeColor:
                                                                      Colors
                                                                          .white,
                                                                  activeTrackColor:
                                                                      Colors
                                                                          .blue,
                                                                  inactiveThumbColor:
                                                                      Colors
                                                                          .white,
                                                                  inactiveTrackColor:
                                                                      Colors
                                                                          .grey,
                                                                )
                                                              ],
                                                            ))
                                                          ],
                                                          onSelectChanged: (e) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return DialogBox(
                                                                      id: _foundUsers[index]
                                                                              [
                                                                              "user_id"]
                                                                          .toString(),
                                                                      isEditing:
                                                                          false);
                                                                });
                                                          });
                                                    })),
                                              )
                                            : DataTable(
                                                headingRowColor:
                                                    MaterialStateProperty.all(
                                                  const Color(0xFF88a4d4),
                                                ),
                                                columns: [
                                                  DataColumn(
                                                    label: Text(
                                                      'User',
                                                      style: TextStyle(
                                                          color:
                                                              Styles.textColor,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Username',
                                                        style: TextStyle(
                                                            color: Styles
                                                                .textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Email',
                                                        style: TextStyle(
                                                            color: Styles
                                                                .textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Role',
                                                        style: TextStyle(
                                                            color: Styles
                                                                .textColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      '',
                                                      style: TextStyle(
                                                          color:
                                                              Styles.textColor,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    // Sorting function
                                                  )
                                                ],
                                                rows: const [],
                                              );
                                      }),
                                ),
                              ),
                            )),
                      ),
              ])),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Styles.buttonColor,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const AddMember();
                });
          },
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ));
  }
}
