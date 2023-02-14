class nonRecurring {
  late String category;
  late int nonRecurringId;
  late String subCategory;
  late String type;
  late String site;
  late String task;
  late String owner;
  late String startDate;
  late String due;
  late String status;
  late String modify;
  late String checked;
  late String personCheck;
  String? remark;
  String? completeDate;

  nonRecurring({
   required this.nonRecurringId,
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
    required this.checked,
    required this.personCheck,
    this.remark,
    this.completeDate,
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
      'checked': checked,
      'personCheck': personCheck,
      'completeDate': completeDate,
      'status': status,
    };
    return map;
  }

  nonRecurring.fromMap(Map<String, dynamic> map) {
    category = map['category'];
    subCategory = map['subcategory'];
    nonRecurringId = int.parse(map['id']);
    type = map['type'];
    site = map['site'];
    task = map['task'];
    owner = map['owner'];
    startDate = map['createdDate'];
    due = map['deadline'];
    modify = map['lastMod'];
    remark = map['remarks'];
    completeDate = map['completedDate'];

    checked = map['checked'];
    personCheck = map['personCheck'];
    status = map['status'];
  }
}
