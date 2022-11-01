import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/model/manageUser.dart';
import 'package:ipsolution/src/dialogBox/addMember.dart';
import 'package:ipsolution/src/dialogBox/memberDetails.dart';
import 'package:ipsolution/src/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/app_styles.dart';

class Member extends StatefulWidget {
  const Member({super.key});

  @override
  State<Member> createState() => _MemberState();
}

class _MemberState extends State<Member> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> _foundUsers = [];
  int _currentSortColumn = 0;

  bool _isAscending = true;

  bool selected = false;
  String userRole = '';
  late bool isEditing;
  bool _isLoading = true;
  bool isSwitched = false;
  List<Map<String, dynamic>> usersFiltered = [];
  TextEditingController searchController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() async {
    final SharedPreferences sp = await _pref;

    final data = await dbHelper.getItems();
    setState(() {
      _foundUsers = data;
      allUsers = data;
      userRole = sp.getString("role")!;
      _isLoading = false;
    });
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
    setState(() {
      if (value == true) {
        active = 'Active';
      } else {
        active = 'Deactive';
      }
    });

    final data = await dbHelper.updateUserActive(active, id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Updated Successfully!"),
      ),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Member()),
    );
  }

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
                      "${allUsers.length} Member",
                      style: Styles.subtitle,
                    ),
                    SizedBox(
                      width: 180,
                      height: 40,
                      child: TextFormField(
                        onChanged: (value) => _runFilter(value),
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
                                child: DataTable(
                                    showCheckboxColumn: false,
                                    sortColumnIndex: _currentSortColumn,
                                    sortAscending: _isAscending,
                                    headingRowColor: MaterialStateProperty.all(
                                      Color(0xFF88a4d4),
                                    ),
                                    columns: [
                                      DataColumn(
                                        label: Text(
                                          'User',
                                          style: TextStyle(
                                              color: Styles.textColor,
                                              fontWeight: FontWeight.w700),
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
                                        label: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Username',
                                            style: TextStyle(
                                                color: Styles.textColor,
                                                fontWeight: FontWeight.w700),
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
                                        label: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Password',
                                            style: TextStyle(
                                                color: Styles.textColor,
                                                fontWeight: FontWeight.w700),
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
                                        //           productB['role'].compareTo(
                                        //               productA['role']));
                                        //     } else {
                                        //       _isAscending = true;
                                        //       // sort the product list in Descending, order by Price
                                        //       _products.sort((productA,
                                        //               productB) =>
                                        //           productA['role'].compareTo(
                                        //               productB['role']));
                                        //     }
                                        //   }
                                        //   );
                                        // }
                                      ),
                                      DataColumn(
                                        label: Text(
                                          '',
                                          style: TextStyle(
                                              color: Styles.textColor,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        // Sorting function
                                      )
                                    ],
                                    rows: List.generate(
                                      _foundUsers.length,
                                      (index) => DataRow(
                                          cells: [
                                            DataCell(Center(
                                                child: Text(
                                                    (index + 1).toString()))),
                                            DataCell(Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(_foundUsers[index]
                                                    ["user_name"]),
                                              ),
                                            )),
                                            DataCell(Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  _foundUsers[index]
                                                      ["password"],
                                                ),
                                              ),
                                            )),
                                            userRole != 'Staff'
                                                ? DataCell(Row(
                                                    children: [
                                                      IconButton(
                                                        icon: Icon(Icons.edit),
                                                        onPressed: () {
                                                          showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return DialogBox(
                                                                    id: _foundUsers[index]
                                                                            [
                                                                            "user_id"]
                                                                        .toString(),
                                                                    isEditing:
                                                                        true);
                                                              });
                                                        },
                                                      ),
                                                      IconButton(
                                                          icon: Icon(
                                                              Icons.delete),
                                                          onPressed: () {
                                                            removeUser(
                                                                _foundUsers[
                                                                        index]
                                                                    ["user_id"],
                                                                context);
                                                          }),
                                                      Switch(
                                                        value: _foundUsers[
                                                                        index][
                                                                    "active"] ==
                                                                'Active'
                                                            ? true
                                                            : false,
                                                        onChanged: ((value) {
                                                          toggleSwitch(
                                                              value,
                                                              _foundUsers[index]
                                                                  ["user_id"]);
                                                        }),
                                                        activeColor:
                                                            Colors.white,
                                                        activeTrackColor:
                                                            Colors.blue,
                                                        inactiveThumbColor:
                                                            Colors.white,
                                                        inactiveTrackColor:
                                                            Colors.grey,
                                                      )
                                                    ],
                                                  ))
                                                : DataCell(Text(""))
                                          ],
                                          onSelectChanged: (e) {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return DialogBox(
                                                      id: _foundUsers[index]
                                                              ["user_id"]
                                                          .toString(),
                                                      isEditing: false);
                                                });
                                          }),
                                    )),
                              ),
                            ),
                          )),
                    ),
            ])),
        floatingActionButton: userRole != "Staff"
            ? FloatingActionButton(
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                ),
                backgroundColor: Styles.buttonColor,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AddMember();
                      });
                },
              )
            : Container());
  }
}
