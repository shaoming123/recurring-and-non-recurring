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
  late String duration;
  late String priority;
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
    required this.duration,
    required this.priority,
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
      'duration': duration,
      'priority': priority,
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
    duration = map['duration'];
    priority = map['priority'];
    // backgroundColor = map['backgroundColor'];
    // photoName = map['photoName'];
  }
}
