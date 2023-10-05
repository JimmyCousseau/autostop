import 'package:autostop/services/osm_service.dart';
import 'package:autostop/services/point_service.dart';
import 'package:autostop/shared/form_layer.dart';
import 'package:autostop/shared/search_city_form_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PointFormScreen extends StatefulWidget {
  final Point point;

  const PointFormScreen({super.key, required this.point});

  @override
  State<PointFormScreen> createState() => _PointFormScreenState();
}

class _PointFormScreenState extends State<PointFormScreen> {
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedTimeController;

  final _pointService = PointService();

  City? _destCity;

  @override
  void initState() {
    super.initState();

    _descriptionController =
        TextEditingController(text: widget.point.description);
    _estimatedTimeController = TextEditingController();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _estimatedTimeController.dispose();
    super.dispose();
  }

  void _sendPointForm() async {
    final navigator = Navigator.of(context);
    final description = _descriptionController.text.trim();
    if (_destCity == null) {
      _showSnackBar("Veuillez choisir une destination valide");
      return;
    }
    try {
      final dest = _destCity!;
      await _pointService.addPoint(Point(
        documentId: widget.point.documentId,
        latitude: widget.point.latitude,
        longitude: widget.point.longitude,
        name: dest.name,
        description: description,
        destLat: dest.pos.latitude,
        destLng: dest.pos.longitude,
        estimatedTime: int.tryParse(_estimatedTimeController.text.trim()) ?? 0,
        updatedAt: DateTime.now(),
        approved: false,
        creatorEmail:
            FirebaseAuth.instance.currentUser?.email ?? "CRITIC ERROR",
      ));
      navigator.pop();
      _showSnackBar(
          'Votre spot sera examiné par un modérateur dans les prochains jours, merci d\'avoir contribué !');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _showSnackBar('Une erreur est survenue');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
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
        title: Text(widget.point.documentId == null
            ? 'Créer un nouveau spot'
            : 'Modifier le spot direction ${widget.point.name}'),
      ),
      body: SingleChildScrollView(
        child: FormLayer(forms: [
          SearchCityFormField(onChanged: (city) {
            _destCity = city;
          }),
          if (widget.point.documentId != null)
            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: true,
              ),
              controller: _estimatedTimeController,
              decoration: const InputDecoration(
                  labelText: 'Temps d\'attente estimé (minutes)'),
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
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description *'),
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Merci de complèter la description du spot";
              }
              return null;
            },
          ),
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.start,
          //   children: [
          //     Text('Latitude: ${widget.point.latitude}'),
          //     Text('Longitude: ${widget.point.longitude}'),
          //   ],
          // ),
          ElevatedButton(
            onPressed: _sendPointForm,
            child: const Text('Sauvegarder'),
          ),
        ]),
      ),
    );
  }
}
