import 'package:flutter/material.dart';

class Event {
  late String category;
  late int? recurringId;
  late String subCategory;
  late String type;
  late String site;
  late String task;
  late String from;
  late String to;
  late String person;
  late String duration;
  late String priority;
  late String recurringOpt;
  late String recurringEvery;
  late String recurringUntil;
  String? remark;
  String? completeDate;
  late String status;
  // late String backgroundColor;
  // final String rule;

  Event({
    this.recurringId,
    required this.category,
    required this.subCategory,
    required this.type,
    required this.site,
    required this.task,
    required this.from,
    required this.to,
    required this.person,
    required this.duration,
    required this.priority,
    required this.recurringOpt,
    required this.recurringEvery,
    required this.recurringUntil,
    this.remark,
    this.completeDate,
    required this.status,
    // required this.backgroundColor,
    // required this.rule
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'recurringId': recurringId,
      'category': category,
      'subCategory': subCategory,
      'type': type,
      'site': site,
      'task': task,
      'fromD': from,
      'toD': to,
      'person': person,
      'duration': duration,
      'priority': priority,
      'recurringOpt': recurringOpt,
      'recurringEvery': recurringEvery,
      'recurringUntil': recurringUntil,
      'remark': remark,
      'completeDate': completeDate,
      'status': status,
      // 'backgroundColor': backgroundColor,
    };
    return map;
  }

  Event.fromMap(Map<String, dynamic> map) {
    category = map['category'];
    subCategory = map['subCategory'];
    recurringId = map['recurringId'];
    type = map['type'];
    site = map['site'];
    task = map['task'];
    from = map['fromD'];
    to = map['toD'];
    person = map['person'];
    duration = map['duration'];
    priority = map['priority'];
    recurringOpt = map['recurringOpt'];
     recurringEvery = map['recurringEvery'];
    recurringUntil = map['recurringUntil'];
    remark = map['remark'];
    completeDate = map['completeDate'];
    status = map['status'];
    // backgroundColor = map['backgroundColor'];
    // photoName = map['photoName'];
  }
}
