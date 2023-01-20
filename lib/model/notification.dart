class NotificationModel {
  late int id;
  late String owner;
  late String assigner;
  late String task;
  late String deadline;
  late String type;
  late String noted;

  NotificationModel(
      {required this.id,
      required this.owner,
      required this.assigner,
      required this.task,
      required this.deadline,
      required this.type,
      required this.noted});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'owner': owner,
      'assigner': assigner,
      'type': type,
      'task': task,
      'deadline': deadline,
      'noted': noted,
    };
    return map;
  }

  NotificationModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    owner = map['owner'];
    assigner = map['assigner'];
    type = map['type'];
    deadline = map['deadline'];
    task = map['task'];
    noted = map['noted'];
  }
}
