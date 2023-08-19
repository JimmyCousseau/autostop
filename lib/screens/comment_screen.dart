import 'package:autostop/screens/comment_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../shared/comment_card.dart';
import '../shared/star_rating.dart'; // Import your StarRating widget

class CommentScreen extends StatefulWidget {
  final String pointDocumentId;
  final StarRating starRating;

  const CommentScreen(
      {super.key, required this.pointDocumentId, required this.starRating});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late Future<List<Map<String, dynamic>>> _commentsFuture;
  Comment? _userComment;

  @override
  void initState() {
    super.initState();
    _commentsFuture =
        CommentService().getCommentsForPoint(widget.pointDocumentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commentaires'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentFormScreen(
                          userComment: _userComment,
                          pointDocumentId: widget.pointDocumentId),
                    ),
                  );
                },
                child: const Text("Écrire un nouveau commentaire")),
            const SizedBox(height: 16),
            const Text('Autres commentaires:', style: TextStyle(fontSize: 18)),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final comments = snapshot.data!;
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = Comment.fromJson(comments[index]);
                          if (_userComment == null &&
                              comment.userMail ==
                                  FirebaseAuth.instance.currentUser?.email) {
                            _userComment = comment;
                          }
                          return CommentCard(
                            comment: comment,
                          );
                        },
                      ),
                    ],
                  );
                } else {
                  return const Text('No comments available.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
