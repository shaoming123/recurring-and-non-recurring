import 'package:flutter/material.dart';
import 'package:ipsolution/databaseHandler/DbHelper.dart';
import 'package:ipsolution/model/user.dart';
import 'package:ipsolution/src/account.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../src/member.dart';

DbHelper dbHelper = DbHelper();
Future<SharedPreferences> _pref = SharedPreferences.getInstance();

Future updateSP(UserModel? user, bool add) async {
  final SharedPreferences sp = await _pref;

  if (add) {
    sp.setString("user_name", user!.user_name);
    sp.setString("password", user.password);
    // sp.setString("photoName", user.photoName!);
  } else {
    sp.remove('user_id');
    sp.remove('user_name');
    sp.remove('email');
    sp.remove('password');
  }
}

void updateAccount(
    int userid, String username, String password, context) async {
  UserModel userModel = UserModel(userid, username, password);

  await dbHelper.updateUser(userModel).then((value) {
    if (value == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated Successfully!"),
        ),
      );

      updateSP(userModel, true).whenComplete(() {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Account()));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error Update!"),
        ),
      );
    }
  }).catchError((error) {
    print(error);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Error"),
      ),
    );
  });
}

// Delete an item
void removeUser(int id, context) async {
  await dbHelper.deleteUser(id);
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Successfully deleted!'),
  ));
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const Member()),
  );
}
