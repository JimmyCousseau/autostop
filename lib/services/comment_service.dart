import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');

  Future<Map<String, dynamic>> getCommentCountAndAverageRate(
      String documentId) async {
    final querySnapshot =
        await commentsCollection.where('point_id', isEqualTo: documentId).get();

    final totalComments = querySnapshot.docs.length;
    double totalRate = 0;

    for (var doc in querySnapshot.docs) {
      totalRate += doc['rate'];
    }
    final averageRate =
        (totalComments > 0 && totalRate > 0) ? totalRate / totalComments : 0;
    return {
      'totalComments': totalComments,
      'averageRate': averageRate,
    };
  }

  Future<List<Comment>> getCommentsForPoint(String pointId) async {
    final querySnapshot =
        await commentsCollection.where('point_id', isEqualTo: pointId).get();

    return querySnapshot.docs.map((doc) {
      if (doc.data() != null) {
        return Comment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        throw Exception("Document data is null");
      }
    }).toList();
  }

  Future<void> createComment(Comment comment) async {
    await commentsCollection.add(comment.toMap());
  }
}

class Comment {
  String? documentId;
  final String userMail;
  final String pointId;
  final String title;
  final String content;
  final int rate;
  final DateTime updatedAt;
  final bool approved;

  Comment({
    this.documentId,
    required this.userMail,
    required this.pointId,
    required this.content,
    required this.rate,
    required this.updatedAt,
    required this.title,
    required this.approved,
  });

  factory Comment.fromMap(String documentId, Map<String, dynamic> json) {
    return Comment(
      documentId: documentId,
      userMail: json['user_mail'],
      pointId: json['point_id'],
      content: json['content'],
      rate: json['rate'],
      updatedAt: DateTime.parse(json['updated_at']),
      title: json['title'],
      approved: json['approved'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_mail': userMail,
      'point_id': pointId,
      'content': content,
      'rate': rate,
      'updated_at': updatedAt.toIso8601String(),
      'title': title,
      'approved': approved,
    };
  }
}
