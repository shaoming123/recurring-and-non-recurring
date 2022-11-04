import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:ipsolution/src/Login.dart';
import 'package:ipsolution/src/account.dart';
import 'package:ipsolution/src/dashboard.dart';
import 'package:ipsolution/src/member.dart';
import 'package:ipsolution/src/non_recurring.dart';
import 'package:ipsolution/src/recurrring.dart';
import 'package:ipsolution/src/report.dart';
import 'package:ipsolution/util/app_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../databaseHandler/DbHelper.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  Future<SharedPreferences> _pref = SharedPreferences.getInstance();
  late DbHelper dbHelper;
  String username = "";
  String email = "";
  String userRole = "";
  @override
  void initState() {
    super.initState();
    getUserData();

    dbHelper = DbHelper();
  }

  Future<void> getUserData() async {
    final SharedPreferences sp = await _pref;

    setState(() {
      username = sp.getString("user_name")!;
      userRole = sp.getString("role")!;
      email = sp.getString("email")!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Styles.navbar,
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(username,
                style: TextStyle(
                  color: Styles.textColor,
                )),
            accountEmail: Text(
              email,
              style: TextStyle(
                color: Styles.textColor,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: Container(
                child: ClipOval(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 4,
                          color: Theme.of(context).scaffoldBackgroundColor),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                            spreadRadius: 2,
                            blurRadius: 10,
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 10))
                      ],
                    ),
                    child: Image.network(
                      'https://invenioptl.com/wp-content/uploads/2022/07/logoip.png',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Styles.bgColor,
              // image: DecorationImage(
              //     fit: BoxFit.fill,
              //     image: AssetImage('assets/images/login/background.png')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Dashboard())),
          ),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text('Recurring'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Recurring())),
          ),
          ListTile(
            leading: const Icon(Icons.low_priority),
            title: const Text('Non-Recurring'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NonRecurring()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Report'),
            onTap: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Report()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_box_outlined),
            title: const Text('Account'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Account())),
          ),
          userRole == "Super Admin"
              ? ListTile(
                  leading: const Icon(Icons.supervisor_account),
                  title: const Text('Member'),
                  onTap: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => Member())),
                )
              : Container(),
          const Divider(),
          const Gap(50),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Login())),
          ),
        ],
      ),
    );
  }
}
