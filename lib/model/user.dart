import 'package:flutter/material.dart';

class UserModel {
  late int? user_id;
  late String user_name;
  late String password;
  late String email;
  late String role;
  late String? leadFunc;
  late String position;
  late String? site;
  late String? siteLead;
  late String active;
  // late String? photoName =
  //     'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png';

  UserModel({
    this.user_id,
    required this.user_name,
    required this.password,
    required this.email,
    required this.role,
    this.leadFunc,
    required this.position,
    this.site,
    this.siteLead,
    required this.active,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'user_id': user_id,
      'user_name': user_name,
      'password': password,
      'email': email,
      'role': role,
      'leadFunc': leadFunc,
      'position': position,
      'site': site,
      'siteLead': siteLead,
      'active': active,
      // 'photoName': photoName
    };
    return map;
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    user_id = map['user_id'];
    user_name = map['user_name'];
    password = map['password'];
    email = map['email'];
    role = map['role'];
    leadFunc = map['leadFunc'];
    site = map['site'];
    siteLead = map['siteLead'];
    active = map['active'];
    position = map['position'];
    // photoName = map['photoName'];
  }
}
