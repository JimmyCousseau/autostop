import 'package:autostop/shared/form_layer.dart';
import 'package:autostop/shared/search_bar_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../services/comment_service.dart';
import '../services/osm_service.dart';

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
  late final TextEditingController _estimatedTimeController;

  final _commentService = CommentService();
  double _userRating = 0.0;
  City? _destCity;

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.userComment?.content ?? '');
    _titleController =
        TextEditingController(text: widget.userComment?.title ?? '');
    _userRating = widget.userComment?.estimatedTime.toDouble() ?? 0.0;
    _estimatedTimeController = TextEditingController();
  }

  void _validateAndSendComment() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (_userRating == 0) {
      _showMessage(
        scaffoldMessenger,
        "Veuillez sélectionner une évaluation en cliquant sur les étoiles",
      );
    } else if (_commentController.text.isEmpty) {
      _showMessage(
        scaffoldMessenger,
        "Veuillez remplir le champ commentaire",
      );
    } else if (_titleController.text.isEmpty) {
      _showMessage(
        scaffoldMessenger,
        "Veuillez mettre un titre",
      );
    } else if (_destCity == null) {
      _showMessage(
          scaffoldMessenger, "Veuillez choisir une destination valide");
    } else {
      try {
        LatLng point = _destCity!.pos;
        await _commentService.createComment(
          Comment(
            pointId: widget.pointDocumentId,
            estimatedTime: _userRating.toInt(),
            content: _commentController.text,
            updatedAt: DateTime.now(),
            title: _titleController.text,
            userMail: FirebaseAuth.instance.currentUser!.email!,
            approved: false,
            destLat: point.latitude,
            destLng: point.longitude,
          ),
        );
        navigator.pop(); // Close the comment screen

        _showMessage(
          scaffoldMessenger,
          'Votre commentaire sera examiné par un modérateur dans les prochains jours, merci d\'avoir contribué !',
        );
      } catch (e) {
        _showMessage(scaffoldMessenger, "Une erreur est survenue : $e");
      }
    }
  }

  void _showMessage(
      ScaffoldMessengerState scaffoldMessengerState, String message) {
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 5000),
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Nouveau commentaire"),
        ),
        body: FormLayer(forms: [
          TextFormField(
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            controller: _estimatedTimeController,
            decoration: const InputDecoration(
                labelText: 'Temps d\'attente estimé (minute)'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Merci de compléter le temps d'attente estimé";
              }
              final val = double.tryParse(value);
              if (val!.isNaN || val.isNegative) {
                return "Merci de mettre un nombre valide et non négatif";
              }
              return null;
            },
          ),
          Text("Destination", style: Theme.of(context).textTheme.titleLarge),
          if (_destCity == null)
            SearchBarDialog(
              onSelected: (city) {
                setState(() {
                  _destCity = city;
                });
              },
              showParameterIcon: false,
            ),
          if (_destCity != null)
            Row(children: [
              Text(_destCity!.name),
              IconButton(
                onPressed: () {
                  setState(() {
                    _destCity = null;
                  });
                },
                icon: const Icon(Icons.delete),
              )
            ]),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Titre',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Merci de complèter le titre";
              } else if (value.length > 200) {
                return "Le titre ne doit pas excèder 200 caractères";
              }
              return null;
            },
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Commentaire',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Merci de complèter le champs commentaire";
              } else if (value.length > 2000) {
                return "Le commentaire ne doit pas excèder 2000 caractères";
              }
              return null;
            },
            textCapitalization: TextCapitalization.sentences,
            maxLines: null,
            autocorrect: true,
          ),
          ElevatedButton(
              onPressed: _validateAndSendComment, child: const Text("Envoyer")),
        ]));
  }
}
