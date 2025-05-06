class CharacterImage {
  final String id;
  final String name;
  final String imageUrl;
  final String type;

  CharacterImage({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
  });

  factory CharacterImage.fromJson(Map<String, dynamic> json) {
    return CharacterImage(
      id: json['id'].toString(),
      name: json['name'],
      imageUrl: json['imageUrl'],
      type: json['type'],
    );
  }
}