import 'dart:io';

class MyImage {
  final String id;
  final String name;
  final String link;
  final int size;
  late File file;

  MyImage({required this.id, required this.name, required this.link, required this.size});

  factory MyImage.fromMap(Map<String, dynamic> data, String id) {
    return MyImage(
      id: id,
      name: data['name'],
      link: data['link'],
      size: data['size'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'link': link,
      'size': size,
    };
  }
}
