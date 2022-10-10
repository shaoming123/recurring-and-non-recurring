import 'package:flutter/material.dart';

class UserModel {
  late String user_id;
  late String user_name;
  late String password;

  UserModel(this.user_id, this.user_name, this.password);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_id': user_id,
      'user_name': user_name,
      'password': password
    };
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    user_id = map['user_id'];
    user_name = map['user_name'];
    password = map['password'];
  }
}
