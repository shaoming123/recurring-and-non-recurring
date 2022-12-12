class Event {
  late String category;
  late String? uniqueNumber;
  late int? recurringId;
  late String subCategory;
  late String type;
  late String site;
  late String task;
  late String from;
  late String to;
  late String date;
  late String deadline;
  late String startTime;
  late String dueTime;
  late String person;
  late String duration;
  late String priority;
  late String recurringOpt;
  late String recurringEvery;
  // String? recurringUntil;
  String? remark;
  String? completeDate;
  late String status;
  late String color;
  String? checkRecurring = "false";
  String? dependent;
  // final String rule;

  Event(
      {this.recurringId,
      this.uniqueNumber,
      required this.category,
      required this.subCategory,
      required this.type,
      required this.site,
      required this.task,
      required this.from,
      required this.to,
      required this.date,
      required this.deadline,
      required this.startTime,
      required this.dueTime,
      required this.person,
      required this.duration,
      required this.priority,
      required this.recurringOpt,
      required this.recurringEvery,
      // this.recurringUntil,
      this.remark,
      this.completeDate,
      required this.status,
      required this.color,
      this.checkRecurring,
      this.dependent
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
      'date': date,
      'deadline': deadline,
      'startTime': startTime,
      'dueTime': dueTime,
      'person': person,
      'duration': duration,
      'priority': priority,
      'recurringOpt': recurringOpt,
      'recurringEvery': recurringEvery,
      // 'recurringUntil': recurringUntil,
      'remark': remark,
      'completeDate': completeDate,
      'status': status,
      'color': color,
      'uniqueNumber': uniqueNumber,
      'dependent': dependent,
      'checkRecurring': checkRecurring,
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
    date = map['date'];
    deadline = map['deadline'];
    startTime = map['startTime'];
    dueTime = map['dueTime'];
    person = map['person'];
    duration = map['duration'];
    priority = map['priority'];
    recurringOpt = map['recurringOpt'];
    recurringEvery = map['recurringEvery'];
    // recurringUntil = map['recurringUntil'];
    remark = map['remark'];
    completeDate = map['completeDate'];
    status = map['status'];
    color = map['color'];
    uniqueNumber = map['uniqueNumber'];
    dependent = map['dependent'];
    checkRecurring = map['checkRecurring'];

    // photoName = map['photoName'];
  }
}
