import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../shared/comment_card.dart';
import '../shared/star_rating.dart'; // Import your StarRating widget

class CommentScreen extends StatefulWidget {
  final String pointDocumentId;

  const CommentScreen({super.key, required this.pointDocumentId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  int _userRating = 0;
  late final TextEditingController _commentController;
  late final TextEditingController _titleController;
  String? _errorMessage;

  late Future<Map<String, dynamic>> _commentDataFuture;
  late Future<List<Map<String, dynamic>>> _commentsFuture;

  void _sendComment() async {
    if (_userRating == 0) {
      setState(() {
        _errorMessage =
            "Veuillez selectionner une évalutaion en cliquant sur les étoiles";
      });
    } else if (_commentController.text.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez remplir le champs commentaire";
      });
    } else if (_titleController.text.isEmpty) {
      setState(() {
        _errorMessage = "Veuillez mettre un titre";
      });
    } else {
      try {
        await CommentService().createComment(Comment(
          pointId: widget.pointDocumentId,
          rate: _userRating,
          content: _commentController.text,
          createdAt: DateTime.now(),
          title: _titleController.text,
          userMail: FirebaseAuth.instance.currentUser!.email!,
        ));

        Navigator.pop(context); // Close the comment screen}
      } catch (e) {
        setState(() {
          _errorMessage = "Une erreur est survenue ${e}";
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _commentDataFuture =
        CommentService().getCommentCountAndAverageRate(widget.pointDocumentId);
    _commentsFuture =
        CommentService().getCommentsForPoint(widget.pointDocumentId);
    _commentController = TextEditingController();
    _titleController = TextEditingController();
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
            FutureBuilder(
              future: _commentDataFuture,
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text("");
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final int commentCount = snapshot.data?['totalComments'];
                  double averageRate = snapshot.data?['averageRate'];
                  return StarRating(
                    initialRating: averageRate,
                    commentCount: commentCount,
                    onChanged: (value) => setState(() {
                      _userRating = value.toInt();
                    }),
                  );
                } else {
                  return const Text('No data available');
                }
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Commentaire',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _sendComment, child: const Text("Envoyer")),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
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
                          final comment = comments[index];
                          return CommentCard(
                            comment: Comment.fromJson(comment),
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
