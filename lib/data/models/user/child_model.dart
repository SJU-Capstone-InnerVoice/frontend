class Child {
  final String id;
  final String name;

  Child({required this.id, required this.name});

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['friendId'].toString(),
      name: json['friendName'],
    );
  }

  Map<String, String> toJson() {
    return {'id': id, 'name': name};
  }
}