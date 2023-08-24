import 'package:autostop/shared/star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/comment_service.dart';

class CommentFormScreen extends StatefulWidget {
  const CommentFormScreen(
      {super.key, required this.pointDocumentId, this.userComment});

  final String pointDocumentId;

  final Comment? userComment;

  @override
  State<CommentFormScreen> createState() => _CommentFormScreenState();
}

class _CommentFormScreenState extends State<CommentFormScreen> {
  late final TextEditingController _commentController;

  late final TextEditingController _titleController;

  String? _errorMessage;

  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.userComment?.content ?? '');
    _titleController =
        TextEditingController(text: widget.userComment?.title ?? '');
    _userRating = widget.userComment?.rate.toDouble() ?? 0.0;
  }

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
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      try {
        await CommentService().createComment(Comment(
          pointId: widget.pointDocumentId,
          rate: _userRating.toInt(),
          content: _commentController.text,
          updatedAt: DateTime.now(),
          title: _titleController.text,
          userMail: FirebaseAuth.instance.currentUser!.email!,
          approved: false,
        ));
        navigator.pop(); // Close the comment screen}
        const snackBar = SnackBar(
            duration: Duration(milliseconds: 5000),
            content: Text(
                'Votre commentaire sera examiné par un modérateur dans les prochains jours, merci d\'avoir contribué !'));
        scaffoldMessenger.showSnackBar(snackBar);
      } catch (e) {
        setState(() {
          _errorMessage = "Une erreur est survenue $e";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouveau commentaire"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: SizedBox(
            width: 400.0,
            child: Column(
              children: [
                const Text("Évaluation", style: TextStyle(fontSize: 16)),
                StarRating(
                  initialRating: _userRating,
                  showRate: false,
                  onChanged: (value) {
                    _userRating = value;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Merci de complèter le titre";
                    } else if (value.length > 200) {
                      return "Le titre ne doit pas excèder 200 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Commentaire',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Merci de complèter le champs commentaire";
                    } else if (value.length > 2000) {
                      return "Le commentaire ne doit pas excèder 2000 caractères";
                    }
                    return null;
                  },
                  maxLines: 3,
                  autocorrect: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: _sendComment, child: const Text("Envoyer")),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
