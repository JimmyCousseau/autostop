// import 'dart:convert';
// import 'package:http/http.dart' as http;

// import '../models/comment.dart';

// class CommentService {
//   static const String apiUrl =
//       'http://localhost:3000'; // Replace with your API URL

//   Future<List<Comment>> fetchComments() async {
//     final response = await http.get(Uri.parse('$apiUrl/comments'));

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => Comment.fromJson(data)).toList();
//     } else {
//       throw Exception('Failed to fetch comments');
//     }
//   }

//   Future<Map<String, dynamic>> getCommentCountAndAverageRate(
//       int pointId) async {
//     final response =
//         await http.get(Uri.parse('$apiUrl/comments/count-and-rate/$pointId'));

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to fetch comment count and average rate');
//     }
//   }

//   Future<Comment> createComment(Comment comment) async {
//     final response = await http.post(
//       Uri.parse('$apiUrl/comments'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(comment.toJson()),
//     );

//     if (response.statusCode == 201) {
//       return Comment.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to create comment');
//     }
//   }

//   Future<void> updateComment(Comment comment) async {
//     final response = await http.put(
//       Uri.parse('$apiUrl/comments/${comment.id}'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(comment.toJson()),
//     );

//     if (response.statusCode != 204) {
//       throw Exception('Failed to update comment');
//     }
//   }

//   Future<void> deleteComment(int id) async {
//     final response = await http.delete(Uri.parse('$apiUrl/comments/$id'));

//     if (response.statusCode != 204) {
//       throw Exception('Failed to delete comment');
//     }
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment.dart';

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

  Future<List<Map<String, dynamic>>> getCommentsForPoint(String pointId) async {
    final querySnapshot =
        await commentsCollection.where('point_id', isEqualTo: pointId).get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> createComment(Comment comment) async {
    await commentsCollection.add(comment.toJson());
  }

  Future<void> updateComment(Comment comment) async {
    await commentsCollection.doc(comment.documentId).update(comment.toJson());
  }
}
