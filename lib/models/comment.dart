class Comment {
  String? id;
  final String userMail;
  final String pointId;
  final String title;
  final String content;
  final int rate;
  final DateTime createdAt;

  Comment({
    required this.userMail,
    required this.pointId,
    required this.content,
    required this.rate,
    required this.createdAt,
    required this.title,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userMail: json['user_mail'],
      pointId: json['point_id'],
      content: json['content'],
      rate: json['rate'],
      createdAt: DateTime.parse(json['created_at']),
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_mail': userMail,
      'point_id': pointId,
      'content': content,
      'rate': rate,
      'created_at': createdAt.toIso8601String(),
      'title': title,
    };
  }
}
