class Todomodel {
  final int id;
  final String title;
  final String content;
  final String enddate;

  Todomodel({
    required this.id,
    required this.title,
    required this.content,
    required this.enddate,
  });

  factory Todomodel.fromJson(Map<String, dynamic> json) {
    return Todomodel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      enddate: json['enddate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content, 'enddate': enddate};
  }
}
