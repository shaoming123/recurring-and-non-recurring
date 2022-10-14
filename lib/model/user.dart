import 'package:flutter/material.dart';

class UserModel {
  late int? user_id;
  late String user_name;
  late String password;
  // late String? photoName =
  //     'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png';

  UserModel(this.user_id, this.user_name, this.password);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_name': user_name,
      'password': password,
      // 'photoName': photoName
    };
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    user_id = map['user_id'];
    user_name = map['user_name'];
    password = map['password'];
    // photoName = map['photoName'];
  }
}
