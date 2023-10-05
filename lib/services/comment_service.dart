import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final CollectionReference commentsCollection =
      FirebaseFirestore.instance.collection('comments');

  Future<Rate> getCommentCountAndAverageRate(
      String documentId, int pointEstimatedTime) async {
    final querySnapshot = await commentsCollection
        .where('point_id', isEqualTo: documentId)
        .where('approved', isEqualTo: true)
        .get();

    final totalComments = querySnapshot.docs.length + 1;
    double estimatedTimeWaiting = pointEstimatedTime.toDouble();

    for (var doc in querySnapshot.docs) {
      estimatedTimeWaiting += doc['estimated_time'];
    }
    return Rate(
        estimatedTimeWaiting: estimatedTimeWaiting,
        totalComments: totalComments - 1);
  }

  Future<List<Comment>> getCommentsBy(String pointId) async {
    final querySnapshot = await commentsCollection
        .where('point_id', isEqualTo: pointId)
        .where('approved', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      if (doc.data() != null) {
        return Comment.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        throw Exception("Document data is null");
      }
    }).toList();
  }

  Future<DocumentReference> upsert(Comment comment) async {
    if (comment.documentId == null) {
      return await commentsCollection.add(comment.toJson());
    } else {
      final ref = commentsCollection.doc(comment.documentId);
      ref.update(comment.toJson());
      // TODO: Should control what to update
      return ref;
    }
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
  final String destName;

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
    required this.destName,
  });

  factory Comment.fromJson(String documentId, Map<String, dynamic> json) {
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
      destName: json['destination_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'point_id': pointId,
      'title': title,
      'content': content,
      'estimated_time': estimatedTime,
      'destination_latitude': destLat,
      'destination_longitude': destLng,
      'destination_name': destName,
      'updated_at': updatedAt,
      'approved': approved,
      'creator_mail': userMail,
    };
  }
}

class Rate {
  final double estimatedTimeWaiting;
  final int totalComments;

  Rate({required this.estimatedTimeWaiting, required this.totalComments});
}
