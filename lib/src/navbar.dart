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
              'example@gmail.com',
              style: TextStyle(
                color: Styles.textColor,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
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
            leading: const Icon(Icons.calendar_month),
            title: const Text('Recurring'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Recurring())),
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: const Text('Non-Recurring'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const NonRecurring())),
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Report'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Report())
                
                ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_box_outlined),
            title: const Text('Account'),
            onTap: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Account())),
          ),
          ListTile(
            leading: const Icon(Icons.supervisor_account),
            title: const Text('Member'),
            onTap: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Member())),
          ),
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
