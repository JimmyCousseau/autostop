import 'package:autostop/services/point_service.dart';
import 'package:autostop/shared/form_layer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PointFormScreen extends StatefulWidget {
  final Point point;

  const PointFormScreen({super.key, required this.point});

  @override
  State<PointFormScreen> createState() => _PointFormScreenState();
}

class _PointFormScreenState extends State<PointFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final _pointService = PointService();

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.point.name);
    _descriptionController =
        TextEditingController(text: widget.point.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _sendPointForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final description = _descriptionController.text;
      try {
        _pointService.addPoint(Point(
          documentId: widget.point.documentId,
          latitude: widget.point.latitude,
          longitude: widget.point.longitude,
          name: name,
          description: description,
          updatedAt: DateTime.now(),
          approved: false,
          creatorEmail:
              FirebaseAuth.instance.currentUser?.email ?? "ERROR CRITIQUE",
        ));
        Navigator.pop(context);
        _showSnackBar(
            'Votre spot sera examiné par un modérateur dans les prochains jours, merci d\'avoir contribué !');
      } catch (e) {
        _showSnackBar('Une erreur est survenue');
      }
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
        body: FormLayer(forms: [
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Merci de compléter la direction';
              }
              return null;
            },
            decoration: const InputDecoration(labelText: 'Direction'),
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 10,
            textCapitalization: TextCapitalization.sentences,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Latitude: ${widget.point.latitude}'),
              Text('longitude: ${widget.point.longitude}'),
            ],
          ),
          ElevatedButton(
            onPressed: _sendPointForm,
            child: const Text('Save'),
          ),
        ]));
  }
}
