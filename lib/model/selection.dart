class TypeSelect {
  final int id;
  final String value;
  final String bold;

  TypeSelect({required this.id, required this.value, required this.bold});

  factory TypeSelect.fromJson(Map<String, dynamic> json) {
    return TypeSelect(id: json['id'], value: json['value'], bold: json['bold']);
  }
}
