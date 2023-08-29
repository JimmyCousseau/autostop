import 'package:flutter/material.dart';

class FormLayer extends StatelessWidget {
  final List<Widget> forms;
  const FormLayer({super.key, required this.forms});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _transformWidgets(forms),
        ),
      ),
    );
  }

  List<Widget> _transformWidgets(List<Widget> widgets) {
    List<Widget> result = [];
    for (Widget w in widgets) {
      result.add(const SizedBox(height: 16));
      result.add(w);
    }
    return result;
  }
}
