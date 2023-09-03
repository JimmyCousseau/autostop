import 'package:autostop/screens/auth_screen.dart';
import 'package:autostop/screens/comment_form_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/comment_service.dart';
import '../shared/comment_card.dart';

class CommentScreen extends StatefulWidget {
  final String pointDocumentId;

  const CommentScreen({super.key, required this.pointDocumentId});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  late Future<List<Comment>> _commentsFuture;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) {
                          if (FirebaseAuth.instance.currentUser != null) {
                            return CommentFormScreen(
                                userComment: _userComment,
                                pointDocumentId: widget.pointDocumentId);
                          }
                          return const AuthScreen();
                        },
                      ),
                    );
                  },
                  child: Text(FirebaseAuth.instance.currentUser != null
                      ? "Écrire un nouveau commentaire"
                      : "Se connecter pour pouvoir commenter")),
              const SizedBox(height: 16),
              Text('Commentaires:',
                  style: Theme.of(context).textTheme.headlineSmall),
              FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final comments = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        if (_userComment == null &&
                            comment.userMail ==
                                FirebaseAuth.instance.currentUser?.email) {
                          _userComment = comment;
                        }
                        return CommentCard(
                          comment: comment,
                        );
                      },
                    );
                  } else {
                    return const Text('No comments available.');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
