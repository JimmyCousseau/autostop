import 'package:autostop/shared/form_layer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordScreen({super.key});

  void _resetPassword(BuildContext context) async {
    final String email = _emailController.text.trim();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (email.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Email de réinitialisation envoyé')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      }
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
            content: Text('Veuillez entrer une adresse e-mail valide')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réinitialisation du mot de passe')),
      body: FormLayer(forms: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Adresse e-mail'),
        ),
        ElevatedButton(
          onPressed: () => _resetPassword(context),
          child: const Text('Réinitialiser le mot de passe'),
        ),
      ]),
    );
  }
}
