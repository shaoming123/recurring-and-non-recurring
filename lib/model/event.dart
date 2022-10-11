import 'package:flutter/material.dart';

class Event {
  final int? recurringId;
  final String category;
  final String subCategory;
  final String type;
  final String site;
  final String task;
  final String from;
  final String to;
  final String duration;
  final String priority;
  final String? backgroundColor;
  // final String rule;

  const Event({
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
    this.backgroundColor,
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
      'backgroundColor': backgroundColor,
    };
    return map;
  }
}
