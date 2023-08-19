import 'package:autostop/services/point_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.point.documentId == null
            ? 'Créer un nouveau spot'
            : 'Modifier le spot direction ${widget.point.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              ),
              const SizedBox(height: 16),
              Text('Latitude: ${widget.point.latitude}'),
              Text('longitude: ${widget.point.longitude}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final description = _descriptionController.text;
                    final p = Point(
                      latitude: widget.point.latitude,
                      longitude: widget.point.longitude,
                      name: name,
                      description: description,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      approved: false,
                    );
                    try {
                      if (p.documentId == null || p.documentId!.isEmpty) {
                        PointService().addPoint(p);
                      } else {
                        PointService().updatePoint(p);
                      }
                    } catch (e) {
                      const snackBar = SnackBar(
                          duration: Duration(milliseconds: 5000),
                          content: Text('Une erreur est survenue'));
                    }

                    Navigator.pop(context);
                    const snackBar = SnackBar(
                        duration: Duration(milliseconds: 5000),
                        content: Text(
                            'Votre spot sera examiné par un modérateur dans les prochains jours, merci d\'avoir contribué !'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
