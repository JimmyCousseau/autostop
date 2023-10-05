import 'package:autostop/shared/form_layer.dart';
import 'package:autostop/shared/search_city_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  City? _destCity;

  @override
  void initState() {
    super.initState();
    _commentController =
        TextEditingController(text: widget.userComment?.content ?? '');
    _titleController =
        TextEditingController(text: widget.userComment?.title ?? '');
    _estimatedTimeController = TextEditingController(
        text: widget.userComment?.estimatedTime.toString());
  }

  void _validateAndSendComment() {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final int estimatedTime = int.tryParse(_estimatedTimeController.text)!;
    if (_destCity == null) {
      _showMessage(
          scaffoldMessenger, "Veuillez choisir une destination valide");
      return;
    }
    try {
      LatLng dest = _destCity!.pos;
      _commentService.upsert(
        Comment(
          pointId: widget.pointDocumentId,
          estimatedTime: estimatedTime,
          content: _commentController.text.trim(),
          updatedAt: DateTime.now(),
          title: _titleController.text.trim(),
          userMail: FirebaseAuth.instance.currentUser!.email!,
          approved: false,
          destLat: dest.latitude,
          destLng: dest.longitude,
          destName: _destCity!.name.trim(),
        ),
      );
      navigator.pop(); // Close the comment screen

      _showMessage(
        scaffoldMessenger,
        'Votre commentaire sera examiné par un modérateur dans les prochains jours, merci d\'avoir contribué !',
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _showMessage(scaffoldMessenger, "Une erreur est survenue");
    }
  }

  void _showMessage(
      ScaffoldMessengerState scaffoldMessengerState, String message) {
    scaffoldMessengerState.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
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
        body: SingleChildScrollView(
          child: FormLayer(forms: [
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
                final val = int.tryParse(value);
                if (val == null || val.isNegative || val == 0) {
                  return "Merci de mettre un nombre valide et non négatif";
                }
                return null;
              },
            ),
            SearchCityFormField(onChanged: (City? city) {
              setState(() {
                _destCity = city;
              });
            }),
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
                onPressed: _validateAndSendComment,
                child: const Text("Envoyer")),
          ]),
        ));
  }
}
