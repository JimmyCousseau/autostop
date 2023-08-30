import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');

  Future<Rate> getCommentCountAndAverageRate(String documentId) async {
    final querySnapshot = await commentsCollection
        .where('point_id', isEqualTo: documentId)
        .where('approved', isEqualTo: true)
        .get();

    final totalComments = querySnapshot.docs.length;
    double totalEstimatedTime = 0;

    for (var doc in querySnapshot.docs) {
      totalEstimatedTime += doc['estimated_time'];
    }
    final double estimatedTime = (totalComments > 0 && totalEstimatedTime >= 0)
        ? totalEstimatedTime / totalComments
        : 0.0;

    return Rate(estimatedTime: estimatedTime, totalComments: totalComments);
  }

  Future<List<Comment>> getCommentsForPoint(String pointId) async {
    final querySnapshot = await commentsCollection
        .where('point_id', isEqualTo: pointId)
        .where('approved', isEqualTo: true)
        .get();

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
  final int estimatedTime;
  final DateTime updatedAt;
  final bool approved;
  final double destLat;
  final double destLng;

  Comment({
    this.documentId,
    required this.userMail,
    required this.pointId,
    required this.content,
    required this.estimatedTime,
    required this.updatedAt,
    required this.title,
    required this.approved,
    required this.destLat,
    required this.destLng,
  });

  factory Comment.fromMap(String documentId, Map<String, dynamic> json) {
    return Comment(
      documentId: documentId,
      userMail: json['creator_mail'] ?? "",
      pointId: json['point_id'] ?? "",
      content: json['content'] ?? "",
      estimatedTime: json['estimated_time'] ?? 0,
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      title: json['title'] ?? "",
      approved: json['approved'] ?? false,
      destLat: json['destination_latitude'] ?? 0.0,
      destLng: json['destination_longitude'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point_id': pointId,
      'title': title,
      'content': content,
      'estimated_time': estimatedTime,
      'destination_latitude': destLat,
      'destination_longitude': destLng,
      'updated_at': updatedAt,
      'approved': approved,
      'creator_mail': userMail,
    };
  }
}

class Rate {
  final double estimatedTime;
  final int totalComments;

  Rate({required this.estimatedTime, required this.totalComments});
}
