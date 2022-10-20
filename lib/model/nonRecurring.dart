import 'package:flutter/material.dart';

class nonRecurring {
  late String category;
  late int? nonRecurringId;
  late String subCategory;
  late String type;
  late String site;
  late String task;
  late String owner;
  late String startDate;
  late String due;
  late String status;
  late String modify;
  String? remark;
  String? completeDate;

  // late String backgroundColor;
  // final String rule;

  nonRecurring({
    this.nonRecurringId,
    required this.category,
    required this.subCategory,
    required this.type,
    required this.site,
    required this.task,
    required this.owner,
    required this.due,
    required this.status,
    required this.startDate,
    required this.modify,
    this.remark,
    this.completeDate,

    // required this.backgroundColor,
    // required this.rule
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'nonRecurringId': nonRecurringId,
      'category': category,
      'subCategory': subCategory,
      'type': type,
      'site': site,
      'task': task,
      'owner': owner,
      'due': due,
      'startDate': startDate,
      'modify': modify,
      'remark': remark,
      'completeDate': completeDate,
      'status': status,
      // 'backgroundColor': backgroundColor,
    };
    return map;
  }

  nonRecurring.fromMap(Map<String, dynamic> map) {
    category = map['category'];
    subCategory = map['subCategory'];
    nonRecurringId = map['nonRecurringId'];
    type = map['type'];
    site = map['site'];
    task = map['task'];
    owner = map['owner'];
    startDate = map['startDate'];
    due = map['due'];
    modify = map['modify'];
    remark = map['remark'];
    completeDate = map['completeDate'];
    status = map['status'];
    // backgroundColor = map['backgroundColor'];
    // photoName = map['photoName'];
  }
}